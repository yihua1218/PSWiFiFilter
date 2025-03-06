# WiFiFilter

[English](#english) | [繁體中文](#繁體中文)

## English

### Overview
WiFiFilter provides platform-specific solutions for managing Wi-Fi SSID visibility on both Windows and macOS systems. Each platform has its own implementation due to different network management systems.

### Platform-Specific Scripts

#### Windows (PSWiFiFilter.ps1)
- Uses Windows' built-in network filtering system (netsh)
- Directly controls SSID visibility at system level
- Changes persist across system reboots
- Requires Administrator privileges

#### macOS (macOSWiFiFilter.sh)
- Uses macOS network preferences system
- Manages preferred networks list
- Networks must be added to System Preferences first
- Requires root privileges (sudo)

### Features
- Hide unwanted Wi-Fi SSIDs
- Whitelist specific SSIDs to make them visible
- Maintain a growing list of hidden SSIDs across runs
- Support pre-configured allowed SSIDs list
- Color-coded interface for better usability
- Comprehensive error handling
- Cross-platform support

### Requirements

#### Windows Version (PSWiFiFilter.ps1)
- Windows operating system
- PowerShell
- Administrator privileges
- Active Wi-Fi adapter

#### macOS Version (macOSWiFiFilter.sh)
- macOS operating system
- Terminal access
- Root privileges (sudo)
- Active Wi-Fi adapter
- Networks must be added to System Preferences first

### Installation

#### Windows
1. Clone this repository or download `PSWiFiFilter.ps1`
2. Right-click on PowerShell and select "Run as Administrator"
3. Navigate to the script location
4. Execute: `.\PSWiFiFilter.ps1`

#### macOS
1. Clone this repository or download `macOSWiFiFilter.sh`
2. Open Terminal
3. Navigate to the script location
4. Make the script executable: `chmod +x macOSWiFiFilter.sh`
5. Execute: `sudo ./macOSWiFiFilter.sh`

### Usage

#### Windows
1. Run the script with Administrator privileges
2. The script will:
   - Show all available Wi-Fi networks
   - Let you choose which networks to allow
   - Hide all other networks
   - Save your preferences

#### macOS
1. First add networks in System Preferences:
   - Open System Preferences > Network > Wi-Fi > Advanced
   - Add networks you want to manage to your preferred networks list
2. Run the script with sudo privileges
3. The script will:
   - Show all networks from your preferred networks list
   - Let you choose which networks to keep visible
   - Configure network preferences accordingly

### File Management
Both versions manage two key files:

1. `allowed_ssids.txt`:
   - Contains SSIDs you want to keep visible
   - Can be edited manually before running the script
   - SSIDs listed here will never appear in hidden_ssids.txt

2. `hidden_ssids.txt`:
   - Maintains a growing list of all discovered SSIDs
   - Automatically adds new networks while preserving existing ones
   - Excludes any SSIDs that are in allowed_ssids.txt
   - Serves as a reference for networks you might want to allow later

### Platform Differences

#### Windows Implementation
- Direct control of network visibility
- Works with any detected network
- Changes affect system-level network filtering
- Changes persist across reboots

#### macOS Implementation
- Works through network preferences system
- Networks must be pre-added to System Preferences
- Changes affect network auto-join behavior
- Manages preferred networks list

### License
This project is licensed under the MIT License. See the LICENSE file for details.

---

## 繁體中文

### 概述
WiFiFilter 為 Windows 和 macOS 系統提供平台特定的 Wi-Fi SSID 可見性管理解決方案。由於網路管理系統的差異，每個平台都有其特定的實現方式。

### 平台特定腳本

#### Windows (PSWiFiFilter.ps1)
- 使用 Windows 內建的網路過濾系統 (netsh)
- 直接在系統層級控制 SSID 可見性
- 變更在系統重新啟動後仍然保持
- 需要管理員權限

#### macOS (macOSWiFiFilter.sh)
- 使用 macOS 網路偏好設定系統
- 管理偏好網路清單
- 網路必須先加入系統偏好設定
- 需要 root 權限 (sudo)

### 功能特點
- 隱藏不需要的 Wi-Fi SSID
- 將特定 SSID 加入白名單以使其可見
- 持續累積已發現的隱藏 SSID 清單
- 支援預先配置允許的 SSID 清單
- 具有顏色標示的介面，提高易用性
- 完整的錯誤處理
- 跨平台支援

### 系統需求

#### Windows 版本（PSWiFiFilter.ps1）
- Windows 作業系統
- PowerShell
- 管理員權限
- 可用的 Wi-Fi 網路卡

#### macOS 版本（macOSWiFiFilter.sh）
- macOS 作業系統
- 終端機存取
- Root 權限（sudo）
- 可用的 Wi-Fi 網路卡
- 網路必須先加入系統偏好設定

### 安裝方式

#### Windows
1. 複製此存儲庫或下載 `PSWiFiFilter.ps1`
2. 在 PowerShell 上按右鍵，選擇「以系統管理員身分執行」
3. 導航至腳本所在位置
4. 執行：`.\PSWiFiFilter.ps1`

#### macOS
1. 複製此存儲庫或下載 `macOSWiFiFilter.sh`
2. 開啟終端機
3. 導航至腳本所在位置
4. 設定腳本執行權限：`chmod +x macOSWiFiFilter.sh`
5. 執行：`sudo ./macOSWiFiFilter.sh`

### 使用方法

#### Windows
1. 以管理員權限執行腳本
2. 腳本將會：
   - 顯示所有可用的 Wi-Fi 網路
   - 讓您選擇要允許的網路
   - 隱藏其他所有網路
   - 儲存您的偏好設定

#### macOS
1. 首先在系統偏好設定中加入網路：
   - 打開系統偏好設定 > 網路 > Wi-Fi > 進階
   - 將要管理的網路加入偏好網路清單
2. 使用 sudo 權限執行腳本
3. 腳本將會：
   - 顯示偏好網路清單中的所有網路
   - 讓您選擇要保持可見的網路
   - 相應配置網路偏好設定

### 檔案管理
兩個版本都管理兩個主要檔案：

1. `allowed_ssids.txt`：
   - 包含您想要保持可見的 SSID
   - 可以在執行腳本前手動編輯
   - 此處列出的 SSID 永不會出現在 hidden_ssids.txt 中

2. `hidden_ssids.txt`：
   - 持續累積所有發現的 SSID 清單
   - 自動新增新網路同時保留現有項目
   - 排除任何在 allowed_ssids.txt 中的 SSID
   - 作為日後可能想要允許的網路參考清單

### 平台差異

#### Windows 實現
- 直接控制網路可見性
- 可與任何偵測到的網路配合使用
- 變更影響系統層級的網路過濾
- 變更在重新啟動後仍然保持

#### macOS 實現
- 透過網路偏好設定系統運作
- 網路必須先加入系統偏好設定
- 變更影響網路自動加入行為
- 管理偏好網路清單

### 授權條款
本專案採用 MIT 授權條款。詳情請參閱 LICENSE 檔案。
