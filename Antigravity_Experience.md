# 10 分鐘完成 PowerShell 轉 C# WPF GUI 工具：Antigravity + Gemini 3 Pro 實戰體驗

身為軟體工程師，我們常說「時間就是金錢」，但真正能大幅縮短開發時間的工具卻不多。今天我想分享一個令人驚豔的體驗：使用 **Antigravity** 搭配 **Gemini 3 Pro**，在短短 **10 分鐘**內，將一個原本只有命令列介面的 PowerShell Wi-Fi 過濾腳本，重構成為一個功能完整的 Windows WPF 圖形化介面應用程式。

## 極速開發流程

原本的 `PSWiFiFilter` 是一個實用的腳本，但缺乏親和力。我向 Antigravity 提出需求：「幫我用 C# 最新的 dotnet 框架，把這個腳本改寫成有 Windows 圖形化介面的工具。」

Antigravity 迅速理解了需求，並自動規劃了完整的實作路徑：
1.  **專案初始化**：建立 WPF 專案結構。
2.  **核心邏輯移植**：將 `netsh` 指令封裝為 C# 類別。
3.  **UI/UX 設計**：使用 XAML 設計出包含掃描、白名單管理、過濾應用等功能的介面。
4.  **功能實作**：綁定 ViewModel，實現 MVVM 架構。

這一切都在幾分鐘內自動生成代碼並寫入檔案。

## 視覺化除錯：截圖即解法

最讓我印象深刻的是除錯過程。在開發途中，我們遇到了兩次編譯或執行錯誤：
1.  **啟動即崩潰**：程式一執行就閃退。
2.  **XAML 資源錯誤**：`StaticResource` 解析失敗。

以往這需要花時間看 Log、設斷點。但在 Antigravity 的環境下，我**直接將錯誤畫面的截圖貼上**，甚至不需要詳細描述錯誤訊息。Antigravity 結合 Gemini 3 Pro 的強大視覺理解能力，瞬間就「看」懂了問題所在：
*   它發現了 `StaticResource` 的定義順序問題，並自動修正了 XAML 結構。
*   它建議添加全域例外處理 (Global Exception Handling) 來捕捉閃退原因。

## 結論：軟體工程師的超級利器

從需求提出到功能完備、甚至包含 `README.md` 文件撰寫與圖片嵌入，整個過程流暢且高效。Antigravity 不僅僅是一個代碼生成器，它更像是一個經驗豐富的**結對程式設計師 (Pair Programmer)**。

如果你希望從繁瑣的 boilerplate code 中解放，專注於更有價值的邏輯設計，或者希望有一個能「看懂」你螢幕錯誤的強大助手，**Antigravity + Gemini 3 Pro** 絕對是你不可或缺的開發利器。

---
*#Antigravity #Gemini3Pro #AIcoding #DotNet #WPF #Productivity*
