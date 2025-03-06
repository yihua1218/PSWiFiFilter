# PSWiFiFilter

[English](#english) | [繁體中文](#繁體中文)

## English

### Overview
PSWiFiFilter is a PowerShell script for managing Wi-Fi SSID visibility on Windows systems. It allows users to hide all Wi-Fi networks by default and selectively show only the networks they choose to see.

### Features
- Show all Wi-Fi SSIDs at startup for easy selection
- Whitelist specific SSIDs to make them visible
- Save available SSIDs for future reference
- Support pre-configured allowed SSIDs list
- Color-coded interface for better usability
- Comprehensive error handling
- Administrator privileges check

### Requirements
- Windows operating system
- PowerShell
- Administrator privileges
- Active Wi-Fi adapter

### Installation
1. Clone this repository or download `PSWiFiFilter.ps1`
2. Ensure the script has execute permissions

### Usage
1. Right-click on PowerShell and select "Run as Administrator"
2. Navigate to the script location
3. Execute the script:
```powershell
.\PSWiFiFilter.ps1
```
4. The script will:
   - First make all Wi-Fi networks visible
   - Display and save all available Wi-Fi networks to `hidden_ssids.txt`
   - Check for existing allowed SSIDs in `allowed_ssids.txt` (if present)
   - Let you choose to:
     - Use existing allowed SSIDs from `allowed_ssids.txt`
     - Or enter new SSIDs to allow
   - Apply filters to show only allowed SSIDs

### Advanced Usage
You can prepare your allowed SSIDs list before running the script:

1. Run the script once to generate `hidden_ssids.txt` with all available networks
2. Create or edit `allowed_ssids.txt` in the same directory
3. Add the SSIDs you want to see (one per line)
4. Run the script again and choose to use your prepared list

### Output Files
The script creates two files in its directory:
- `allowed_ssids.txt`: List of visible Wi-Fi networks
- `hidden_ssids.txt`: List of hidden Wi-Fi networks

### License
This project is licensed under the MIT License. See the LICENSE file for details.

---

## 繁體中文

### 概述
PSWiFiFilter 是一個用於管理 Windows 系統上 Wi-Fi SSID 可見性的 PowerShell 腳本。它可以預設隱藏所有 Wi-Fi 網路，並選擇性地只顯示使用者想看到的網路。

### 功能特點
- 啟動時顯示所有 Wi-Fi SSID 方便選擇
- 將特定 SSID 加入白名單以使其可見
- 儲存可用的 SSID 清單供日後參考
- 支援預先配置允許的 SSID 清單
- 具有顏色標示的介面，提高易用性
- 完整的錯誤處理
- 管理員權限檢查

### 系統需求
- Windows 作業系統
- PowerShell
- 管理員權限
- 可用的 Wi-Fi 網路卡

### 安裝方式
1. 複製此存儲庫或下載 `PSWiFiFilter.ps1`
2. 確保腳本具有執行權限

### 使用方法
1. 在 PowerShell 上按右鍵，選擇「以系統管理員身分執行」
2. 導航至腳本所在位置
3. 執行腳本：
```powershell
.\PSWiFiFilter.ps1
```
4. 腳本將會：
   - 首先顯示所有 Wi-Fi 網路
   - 顯示並儲存所有可用的 Wi-Fi 網路到 `hidden_ssids.txt`
   - 檢查 `allowed_ssids.txt`（若存在）中已允許的 SSID
   - 讓您選擇：
     - 使用 `allowed_ssids.txt` 中現有的允許 SSID
     - 或輸入新的 SSID 以允許
   - 套用過濾器只顯示允許的 SSID

### 進階使用方法
您可以在執行腳本之前準備允許的 SSID 清單：

1. 執行一次腳本以生成包含所有可用網路的 `hidden_ssids.txt`
2. 在同一目錄下創建或編輯 `allowed_ssids.txt`
3. 新增您想要看到的 SSID（每行一個）
4. 再次執行腳本並選擇使用您準備好的清單

### 輸出檔案
腳本會在其目錄中創建兩個檔案：
- `allowed_ssids.txt`：可見 Wi-Fi 網路清單
- `hidden_ssids.txt`：隱藏 Wi-Fi 網路清單

### 授權條款
本專案採用 MIT 授權條款。詳情請參閱 LICENSE 檔案。
