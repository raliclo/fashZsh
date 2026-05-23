# 🚀 跨平台優化 Zsh 配置 (fashZsh)

![Zsh Support](https://img.shields.io/badge/Shell-Zsh%205.0+-blue?style=for-the-badge&logo=gnu-bash)
![Platform Support](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS-orange?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

本專案包含一個經過深度優化、具備**跨平台環境動態偵測**、**編譯器工具鏈即時切換**，以及**防游標錯亂雙行提示字元**的 `.zshrc` 設定檔，專為 Linux 與 macOS (Darwin) 的現代開發工作流量身打造。

---

## ✨ 核心特色

### 1. 🌍 跨平台動態偵測與效能優化
* **硬體架構感知**：自動偵測作業系統（`Linux` 或 `Darwin`），解析 `/proc/cpuinfo` 或 `sysctl` 讀取邏輯 CPU 核心數，並動態將平行編譯執行緒數設定為 `$((核心數 * 2))`（存於 `$PACORES` 變數）。
* **路徑與工具自動對齊**：完美相容 Linuxbrew 與 macOS 原生 Homebrew 的環境路徑，自動處理 `$BREW_PREFIX` 以及 `readlink` / `greadlink` 的動態綁定。

### 2. 🛠️ 編譯器環境動態切換工具 (`setcc`)
內建 `setcc` 工具函式，讓您在同一個終端機視窗中，一鍵即時切換並導出（Export）完整的編譯環境變數（包含 `CC`、`CXX`、`FC`、`CPP`、`GCC_FLAGS` 等）：
* `setcc gcc`：切換至系統預設的 GCC 環境（預設值）。
* `setcc gccx`：切換至自訂版本的 GCC 環境（例如透過 Homebrew 安裝的 `gcc-7` 或更新版本）。
* `setcc clang`：切換至 macOS 標準或自訂的 Clang/LLVM 編譯環境。
* `setcc mpicc`：切換至高效能平行運算專用的 MPI (Message Passing Interface) 環境。

### 3. 🎨 防錯亂雙行美化提示字元 (Anti-Glitch Prompt)
* **防錯亂機制**：全面採用 Zsh 專屬的 `%{%}` 顏色控制碼包裹技術，徹底解決傳統終端機在輸入長指令換行、或利用上下鍵搜尋歷史紀錄時，游標會莫名錯位、字元重疊的 Bug。
* **清晰視覺排版**：上方提供一條完整的視覺分隔線與高亮當前絕對路徑（`%d`），下方獨立保留 `=>` 輸入區，讓您的打字空間永遠不會被過長的路徑擠壓。

---

## 🚀 快速安裝與使用

### 步驟 1：備份您現有的設定檔
在替換前，強烈建議先備份您原本的 `.zshrc`：
```bash
mv ~/.zshrc ~/.zshrc.bak
```

### 步驟 2：複製此設定檔
將本專案的 `zshrc` 內容複製到您的家目錄（Home Directory）下：
```bash
cp zshrc ~/.zshrc
```

### 步驟 3：重新載入 Zsh 環境
```bash
source ~/.zshrc
```

## 🔧 工具函式與實用別名 (Utility Functions & Aliases)

### 📂 目錄導覽增強功能 (Directory Navigation)
* `cd()` : 覆寫系統內建的 `cd` 指令。在切換至新路徑前，會自動將上一層目錄路徑暫存至全域 `$prevfolder` 變數中。
* `prev` : 瞬間返回並切換至上一個停留的目錄路徑（`$prevfolder`）。方便您在兩個工作的專案資料夾之間來回快速彈跳切換。
* `orig` : 瞬間返回最初開啟此終端機視窗時的初始登入目錄路徑（`$termfolder`）。

### 🛠️ 常用核心別名 (Core Aliases)
* `f` : *(僅限 macOS)* 瞬間在當前終端機工作目錄下打開圖形化的 Finder 視窗。
* `sll` : 快速使用 Sublime Text （`subl`）打開指定的檔案或資料夾。
* `cgrep` : 強制在所有管道（Pipeline）的 `grep` 搜尋結果中啟用標準顏色高亮。
* `xxargs` : 自動綁定當前系統最高硬體執行緒數的平行化 `xargs` 工具（`xargs -n 1 -P $PACORES`）。
* `make` : 利用延遲變數展開技術，自動依據平行化配置進行火力全開的編譯（`make $MAKEJOBS`）。

### 📝 切換預設終端機編輯器
使用 `cheditor` 函式可以快速更新您的 `$EDITOR` 與 `$TEXT_Editor` 環境變數（無參數時預設為 `subl`）：
```bash
cheditor vi       # 將預設編輯器切換為 vi
cheditor nano     # 將預設編輯器切換為 nano
```

## 👥 貢獻者與致謝 (Authors & Acknowledgments)

本配置啟發並參考了以下優秀開發者的工具腳本與技術指導：

* **Ralic Lo** (raliclo@gmail.com) — 核心架構設計與動態環境配置。
* **Nathaniel Landau** ([個人網站 / 履歷](https://natelandau.com/nathaniel-landaus-resume/)) — 強健的 Bash/Zsh 腳本結構設計。
* 語法與指令邏輯分析推薦工具：[ExplainShell](https://explainshell.com/)。

---

## 📄 授權條款 (License)

本專案採用 **MIT 授權條款**。

歡迎自由複製、修改、分發，或將其整合至您個人的 dotfiles 配置中。詳細資訊請參閱根目錄下的 `LICENSE` 檔案。
