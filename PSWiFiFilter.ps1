<#
    .SYNOPSIS
    PSWiFiFilter - A PowerShell script to manage Wi-Fi SSID visibility on Windows.

    .DESCRIPTION
    This script allows users to control which Wi-Fi SSIDs are visible on their Windows system.
    It initially shows all SSIDs and then lets users whitelist specific networks they want to keep visible.

    .NOTES
    MIT License

    Copyright (c) 2025 PSWiFiFilter Contributors

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
#>

#Requires -RunAsAdministrator

# Error handling function
function Write-ErrorMessage {
    param(
        [string]$Message
    )
    Write-Host $Message -ForegroundColor Red
}

# Success message function
function Write-SuccessMessage {
    param(
        [string]$Message
    )
    Write-Host $Message -ForegroundColor Green
}

# Warning message function
function Write-WarningMessage {
    param(
        [string]$Message
    )
    Write-Host $Message -ForegroundColor Yellow
}

# Function to get available SSIDs
function Get-AvailableSSIDs {
    try {
        $networkOutput = netsh wlan show networks
        if ($LASTEXITCODE -ne 0) {
            Write-ErrorMessage "Failed to retrieve Wi-Fi networks. Please ensure Wi-Fi is enabled."
            return @()
        }

        $ssids = @()
        $lines = $networkOutput -split "`n"
        foreach ($line in $lines) {
            if ($line -match "SSID\s+\d+\s+:\s+(.+)") {
                $ssids += $matches[1].Trim()
            }
        }

        if ($ssids.Count -eq 0) {
            Write-WarningMessage "No Wi-Fi networks found. Please ensure Wi-Fi is enabled and networks are in range."
            return @()
        }

        return $ssids
    }
    catch {
        Write-ErrorMessage "Error retrieving Wi-Fi networks: $_"
        return @()
    }
}

# Function to remove all SSID filters
function Remove-AllSSIDFilters {
    try {
        Write-Host "Making all SSIDs visible..." -ForegroundColor Cyan
        
        # Get current filters
        $filters = netsh wlan show filters
        
        # Remove deny-all filters for both network types
        netsh wlan delete filter permission=denyall networktype=infrastructure | Out-Null
        netsh wlan delete filter permission=denyall networktype=adhoc | Out-Null
        
        # Parse and remove individual SSID filters
        $lines = $filters -split "`n"
        foreach ($line in $lines) {
            if ($line -match "SSID\s+:\s+(.+)") {
                $ssid = $matches[1].Trim()
                # Try to remove both allow and block filters for the SSID
                netsh wlan delete filter permission=allow ssid="$ssid" networktype=infrastructure | Out-Null
                netsh wlan delete filter permission=block ssid="$ssid" networktype=infrastructure | Out-Null
            }
        }

        Write-SuccessMessage "Successfully removed all SSID filters"
        return $true
    }
    catch {
        Write-WarningMessage "Some filters could not be removed, but continuing anyway: $_"
        return $true # Continue anyway
    }
}

# Function to hide all SSIDs
function Hide-AllSSIDs {
    try {
        Write-Host "Hiding all SSIDs..." -ForegroundColor Cyan
        $result = netsh wlan add filter permission=denyall networktype=infrastructure
        if ($LASTEXITCODE -ne 0) {
            Write-ErrorMessage "Failed to hide all SSIDs: $result"
            return $false
        }
        Write-SuccessMessage "Successfully hidden all SSIDs"
        return $true
    }
    catch {
        Write-ErrorMessage "Error hiding SSIDs: $_"
        return $false
    }
}

# Function to allow specific SSID
function Add-AllowedSSID {
    param(
        [string]$SSID
    )
    try {
        $result = netsh wlan add filter permission=allow ssid="$SSID" networktype=infrastructure
        if ($LASTEXITCODE -ne 0) {
            if ($result -match "already exists") {
                Write-WarningMessage "SSID '$SSID' filter already exists, skipping..."
                return $true # Return true as the SSID is effectively allowed
            }
            Write-WarningMessage "Failed to allow SSID '$SSID': $result"
            return $false
        }
        Write-SuccessMessage "Successfully allowed SSID: $SSID"
        return $true
    }
    catch {
        if ($_.Exception.Message -match "already exists") {
            Write-WarningMessage "SSID '$SSID' filter already exists, skipping..."
            return $true
        }
        Write-WarningMessage "Error allowing SSID '$SSID': $_"
        return $false
    }
}

# Function to save SSIDs to file
function Save-SSIDsToFile {
    param(
        [string]$FilePath,
        [array]$SSIDs
    )
    try {
        $SSIDs | Sort-Object -Unique | Out-File -FilePath $FilePath -Encoding UTF8 -Force
        Write-SuccessMessage "Successfully saved SSIDs to $FilePath"
        return $true
    }
    catch {
        Write-ErrorMessage "Error saving SSIDs to file '$FilePath': $_"
        return $false
    }
}

# Function to read SSIDs from file
function Read-SSIDsFromFile {
    param(
        [string]$FilePath
    )
    try {
        if (Test-Path $FilePath) {
            $SSIDs = Get-Content -Path $FilePath -Encoding UTF8 | Where-Object { $_ -match '\S' }
            return $SSIDs
        }
        return @()
    }
    catch {
        Write-WarningMessage "Error reading SSIDs from file '$FilePath': $_"
        return @()
    }
}

# Function to update hidden SSIDs list
function Update-HiddenSSIDsList {
    param(
        [string]$HiddenFilePath,
        [array]$NewSSIDs,
        [array]$AllowedSSIDs
    )
    try {
        # Read existing hidden SSIDs
        $existingHidden = Read-SSIDsFromFile -FilePath $HiddenFilePath
        
        # Combine existing and new SSIDs
        $allSSIDs = @($existingHidden) + @($NewSSIDs)
        
        # Remove any SSIDs that are in the allowed list
        $filteredSSIDs = $allSSIDs | Where-Object { $AllowedSSIDs -notcontains $_ } | Sort-Object -Unique
        
        # Save the updated list
        Save-SSIDsToFile -FilePath $HiddenFilePath -SSIDs $filteredSSIDs | Out-Null
        
        return $filteredSSIDs
    }
    catch {
        Write-WarningMessage "Error updating hidden SSIDs list: $_"
        return $NewSSIDs
    }
}

# Function to display final statistics
function Show-Statistics {
    param(
        [int]$TotalSSIDs,
        [int]$HiddenSSIDs,
        [int]$VisibleSSIDs
    )
    Write-Host "`nFinal Statistics:" -ForegroundColor Cyan
    Write-Host "================" -ForegroundColor Cyan
    Write-Host "Total SSIDs Found: " -NoNewline -ForegroundColor White
    Write-Host $TotalSSIDs -ForegroundColor Yellow
    Write-Host "SSIDs Hidden: " -NoNewline -ForegroundColor White
    Write-Host $HiddenSSIDs -ForegroundColor Red
    Write-Host "SSIDs Visible: " -NoNewline -ForegroundColor White
    Write-Host $VisibleSSIDs -ForegroundColor Green
}

# Main execution begins here
Write-Host "`nPSWiFiFilter - Wi-Fi SSID Management Tool" -ForegroundColor Cyan
Write-Host "======================================`n" -ForegroundColor Cyan

# Setup file paths
$scriptPath = $PSScriptRoot
if (-not $scriptPath) {
    $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}
$allowedFile = Join-Path $scriptPath "allowed_ssids.txt"
$hiddenFile = Join-Path $scriptPath "hidden_ssids.txt"

# First make all SSIDs visible
Remove-AllSSIDFilters
Start-Sleep -Seconds 2  # Wait for network list to update

# Get current SSIDs
$availableSSIDs = Get-AvailableSSIDs
if ($availableSSIDs.Count -eq 0) {
    Write-ErrorMessage "No Wi-Fi networks found. Exiting..."
    exit 1
}
$totalSSIDs = $availableSSIDs.Count

# Display available SSIDs
Write-Host "`nAvailable Wi-Fi Networks:" -ForegroundColor Cyan
foreach ($ssid in $availableSSIDs) {
    Write-Host "  * $ssid"
}

# Check for existing allowed SSIDs
$existingAllowedSSIDs = Read-SSIDsFromFile -FilePath $allowedFile
if ($existingAllowedSSIDs.Count -gt 0) {
    Write-Host "`nFound existing allowed SSIDs:" -ForegroundColor Yellow
    foreach ($ssid in $existingAllowedSSIDs) {
        Write-Host "  * $ssid"
    }
    $response = Read-Host "`nWould you like to use these SSIDs? (y/n)"
    if ($response.ToLower() -eq 'y') {
        $allowedSSIDs = @()
        if (Hide-AllSSIDs) {
            foreach ($ssid in $existingAllowedSSIDs) {
                if (Add-AllowedSSID -SSID $ssid) {
                    $allowedSSIDs += $ssid
                }
            }
            Write-Host "`nApplied $($allowedSSIDs.Count) out of $($existingAllowedSSIDs.Count) existing allowed SSIDs." -ForegroundColor Green
        }
    }
    else {
        $allowedSSIDs = @()
    }
}
else {
    $allowedSSIDs = @()
}

# If not using existing allowed SSIDs, get user input
if ($allowedSSIDs.Count -eq 0) {
    if (Hide-AllSSIDs) {
        Write-Host "`nEnter SSIDs to allow (type 'done' when finished):" -ForegroundColor Cyan
        while ($true) {
            $input = Read-Host "Enter SSID"
            if ($input.ToLower() -eq 'done') {
                break
            }
            if ($availableSSIDs -contains $input) {
                if (Add-AllowedSSID -SSID $input) {
                    $allowedSSIDs += $input
                }
            }
            else {
                Write-WarningMessage "SSID '$input' is not in the list of available networks. Please try again."
            }
        }
    }
}

# Save allowed SSIDs list
Save-SSIDsToFile -FilePath $allowedFile -SSIDs $allowedSSIDs | Out-Null

# Update hidden SSIDs list (merges with existing, removes allowed SSIDs)
$hiddenSSIDs = Update-HiddenSSIDsList -HiddenFilePath $hiddenFile -NewSSIDs $availableSSIDs -AllowedSSIDs $allowedSSIDs

# Display summary
Write-Host "`nOperation Summary:" -ForegroundColor Cyan
Write-Host "----------------" -ForegroundColor Cyan
Write-Host "Allowed SSIDs ($($allowedSSIDs.Count)):" -ForegroundColor Green
$allowedSSIDs | ForEach-Object { Write-Host "  * $_" -ForegroundColor Green }
Write-Host "`nHidden SSIDs ($($hiddenSSIDs.Count)):" -ForegroundColor Yellow
$hiddenSSIDs | ForEach-Object { Write-Host "  * $_" -ForegroundColor Yellow }

Write-Host "`nFile Locations:" -ForegroundColor Cyan
Write-Host "  * Allowed SSIDs: $allowedFile"
Write-Host "  * Hidden SSIDs: $hiddenFile"

# Show current network status
Write-Host "`nCurrent Network Status:" -ForegroundColor Cyan
Write-Host "--------------------" -ForegroundColor Cyan
netsh wlan show networks | Out-Host

# Show final statistics
Show-Statistics -TotalSSIDs $totalSSIDs -HiddenSSIDs $hiddenSSIDs.Count -VisibleSSIDs $allowedSSIDs.Count

Write-SuccessMessage "`nPSWiFiFilter completed successfully!"
