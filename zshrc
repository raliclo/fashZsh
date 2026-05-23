#!/bin/zsh
## Study REF-> https://explainshell.com/

# ==============================================================================
# 🌍 GLOBAL ENVIRONMENTAL VARIABLES / 全域環境變數設定
# ==============================================================================
export LC_ALL=en_US.UTF-8
export LoginDay=$(date +%F)

# Authors / 核心作者 : 
# [Ralic Lo (ralic.lo@gmail.com)
# [NATHANIEL LANDAU] (https://natelandau.com/nathaniel-landaus-resume/)


# ==============================================================================
# 💻 1. DYNAMIC PLATFORM DETECTION / 平台動態偵測與核心數配置
# ==============================================================================
# Detects OS to configure CPU cores ($PACORES), Homebrew paths, and system commands.
# 偵測作業系統以動態配置 CPU 核心線程數 ($PACORES)、Homebrew 路徑與系統相依指令。
if [ "$(uname -s)" = "Linux" ]; then
    # Linux: Parse /proc/cpuinfo to calculate hyper-threaded cores
    # Linux 環境：解析 /proc/cpuinfo 並將邏輯核心數乘以 2 以優化編譯
    SETCC="gcc"
    GCC_VER=15
    PACORES=$(grep -c ^processor /proc/cpuinfo)
    PACORES=$(( PACORES * 2 )) 
    UsrPATH="/home"
    UsrNAME=$(whoami)
    export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
    export BREW_PREFIX="/home/linuxbrew/.linuxbrew"
    alias make="make \$MAKEJOBS" 
    COLOR_FLAG="--color=auto"
    READLINK="readlink"
elif [ "$(uname -s)" = "Darwin" ]; then
    # macOS: Use sw_vers and sysctl for OS version and CPU cores
    # macOS 環境：使用 sw_vers 與 sysctl 取得系統版本與硬體核心數
    export MACOSX_DEPLOYMENT_TARGET=$(sw_vers -productVersion)
    SETCC="gcc"
    GCC_VER=15
    PACORES=$(sysctl -n hw.ncpu)
    PACORES=$(( PACORES * 2 ))
    UsrPATH="/Users"
    UsrNAME=$(whoami)
    alias f='open -a Finder ./'               
    READLINK="greadlink" # Requires coreutils via Homebrew / 建議使用 Homebrew 安裝 coreutils
    system_VER=64
    export JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null)
    export BREW_PREFIX="/usr/local"
    export BLOCKSIZE=4096
    COLOR_FLAG="-G"
fi

# Set Homebrew optimization prefix / 設定 Homebrew 套件優化路徑字首
export OPT_PREFIX="$BREW_PREFIX/opt" 


# ==============================================================================
# 🛠️ 2. FUNCTION DEFINITIONS / 工具函式定義
# ==============================================================================

# ------------------------------------------------------------------------------
# FUNCTION: setcc()
# DESCRIPTION: Dynamically switches toolchains & compiler flags (GCC/Clang/MPI).
# 功能描述：動態切換編譯器工具鏈與優化參數設定（支援 GCC、Clang 與 MPI）。
# ------------------------------------------------------------------------------
function setcc() {
    # Initialize with default 'gcc' if $SETCC is empty
    # 若 $SETCC 為空，則初始化賦予預設值 "gcc"
    : "${SETCC:=gcc}"
    
    if [[ $# -eq 1 ]] ; then
        SETCC=$1
    fi
    
    echo "$(tput setaf 6)[Info] Configuring compiler environment... / 正在配置編譯器環境...$(tput sgr0)"
    
    case $SETCC in
        "gcc") ## DEFAULT GNU COMPILER / 預設 GNU 編譯器 ##
            echo "$(tput setaf 3)-> Switching to System Default GCC Environment / 已切換至系統預設 GCC 環境$(tput sgr0)"
            export GCC_FLAGS=" -mmovbe  -m128bit-long-double -msseregparm -mfpmath=sse+387 -mfpmath=both -lpthread"
            export FC="gfortran" CC="gcc" CXX="g++" 
            export CPP="gcc -E" CXXCPP="gcc -E" 
        ;;
        "gccx") ## CUSTOM GCC VERSION / 自訂版本 GNU 編譯器 ##
            echo "$(tput setaf 3)-> Switching to Custom GCC-$GCC_VER Environment / 已切換至自訂 GCC-$GCC_VER 環境$(tput sgr0)"
            export GCC_FLAGS="-mmovbe  -m128bit-long-double -msseregparm -mfpmath=sse+387 -mfpmath=both  -lpthread"
            export FC="gfortran-$GCC_VER" CC="gcc-$GCC_VER" CXX="g++-$GCC_VER"
            export CPP="gcc-$GCC_VER -E" CXXCPP="g++-$GCC_VER -E"
            export HOMEBREW_CC="gcc-$GCC_VER"
        ;;
        "clang")  ## CLANG/LLVM COMPILER / Clang 與 LLVM 編譯器 ##
            echo "$(tput setaf 3)-> Switching to Clang/LLVM Environment / 已切換至 Clang/LLVM 編譯環境$(tput sgr0)"
            export FC="gfortran" CC="cc" CXX="c++" 
            export CPP="clang -E" CXXCPP="clang++ -E"
            export HOMEBREW_CC="clang"
        ;;
        "mpicc") ## MPI HIGH-PERFORMANCE COMPUTING / HPC 高效能平行運算 MPI ##
            echo "$(tput setaf 3)-> Switching to MPI Environment / 已切換至 MPI 高效能平行運算環境$(tput sgr0)"
            export FC="mpifort" CC="mpicc" CXX="mpicxx" 
            export CPP="mpicc -E " CXXCPP="mpicxx -E"  
            export MPIFC="mpifort" MPICC="mpicc" MPICPP="mpicc -E" MPICXX="mpicxx"
            export HOMEBREW_CC="mpicc" HOMEBREW_CXX="mpicxx"
        ;;
        *) ## UNKNOWN OPTION FALLBACK / 未知選項防禦機制 ##
            echo "$(tput setaf 1)[Warning] Unknown compiler option: '$SETCC'. No settings applied. / 未知的編譯器選項，未套用任何變更。$(tput sgr0)"
        ;;
    esac
    
    # Status output summary / 終端機狀態輸出總結
    printf "%s[Success] setcc completed. CURRENT SETCC=%s, PACORES=%s%s\n" \
        "$(tput setaf 2)" "$SETCC" "$PACORES" "$(tput sgr0)"
}

# ------------------------------------------------------------------------------
# FUNCTION: cheditor()
# DESCRIPTION: Changes the default terminal text editor environment variable.
# 功能描述：快速變更終端機的預設文字編輯器環境變數（預設為 Sublime Text）。
# ------------------------------------------------------------------------------
function cheditor() {
    echo "[Info] cheditor: Script to change your default terminal editor / 正在切換預設終端機編輯器"
    if [[ $# -eq 0 ]] ; then
        local VAR_EDITOR=subl   
    else
        local VAR_EDITOR="$@"
    fi
    export TEXT_Editor=$VAR_EDITOR
    export EDITOR=$VAR_EDITOR
}


# ==============================================================================
# 🎨 3. INTERACTIVE PROMPT SETUP (PS1) / 雙行美化提示字元設定
# ==============================================================================
# Enable prompt expansion for dynamic variables
# 啟用 PROMPT_SUBST，確保 Zsh 提示字元中的變數與函式能在每次顯示時動態展開
setopt PROMPT_SUBST

# Fetch user identity and hostname / 取得使用者身分與主機名稱
USER=$(id -un)
HOSTNAME=$(uname -n)

# Escape non-printable control characters with %{ ... %} to prevent cursor drifting bugs.
# 使用 Zsh 專屬的 %{ ... %} 包裹 tput 顏色控制碼，完美防止長指令換行時游標錯位或重疊。
local BOLD="%{$(tput bold)%}"
local CYAN="%{$(tput setaf 6)%}"
local BLUE="%{$(tput setaf 4)%}"
local RESET="%{$(tput sgr0)%}"

# PS1 Multi-line Layout Design / 雙行排版設計
# Upper line: Full horizontal divider line followed by working directory, host, and user info.
# Lower line: Clean input area starting with '=>'.
export PS1='________________________________________________________________________________
${BOLD}${CYAN}%d ${CYAN}@${HOSTNAME} ${BLUE}(${USER})${RESET}
=>'

# Synchronize setup to sudo sessions / 將提示字元設定同步套用至 sudo 權限環境
export SUDO_PS=$PS1


# ==============================================================================
# 📂 DIRECTORY NAVIGATION ENHANCEMENTS / 目錄導覽功能增強
# ==============================================================================

# ------------------------------------------------------------------------------
# FUNCTION: cd()
# DESCRIPTION: Overrides the built-in 'cd' to automatically save the previous 
#              directory path ($prevfolder) before switching to the new one.
#              (Tip: To always list directory contents upon 'cd', 'ls' can be added).
# 功能描述：覆寫系統內建的 'cd' 指令。在切換至新目錄前，會自動將「當前路徑」
#          暫存至 $prevfolder 變數中，以便進行來回快速切換。
# ------------------------------------------------------------------------------
cd() { 
    prevfolder=$(pwd)
    builtin cd "$@"
    # If you want to automatically 'ls' after every 'cd', uncomment the line below:
    ls ${COLOR_FLAG}
} 

# Record the initial login directory snapshot
# 紀錄剛開啟終端機時的初始登入路徑快照
termfolder=$(pwd)

# ------------------------------------------------------------------------------
# ALIASES: orig & prev
# DESCRIPTION: Shortcuts for quick directory navigation.
#              - orig: Instantly jump back to the terminal-login root directory.
#              - prev: Toggle/switch back to the immediately preceding directory.
# 別名設定：快速目錄導覽捷徑。
#          - orig: 瞬間返回開啟此終端機視窗時的初始登入目錄。
#          - prev: 在最近切換的兩個資料夾目錄之間，進行快速來回切換 (2017/07/30)。
# ------------------------------------------------------------------------------
alias orig='cd $termfolder' 
alias prev='cd $prevfolder'


# ==============================================================================
# 📂 FILE AND FOLDER MANAGEMENT / 檔案與資料夾管理
# ==============================================================================

# ------------------------------------------------------------------------------
# ALIAS: nofiles
# DESCRIPTION: Counts and displays the total number of non-hidden files in the 
#              current directory using efficient Zsh glob modifiers.
# 功能描述：計算並顯示當前目錄下的「非隱藏檔案」總數。此指令採用 Zsh 內建的 
#          球狀擴充（Globbing）機制，比傳統的 'ls' 遞迴更有效率。
# ------------------------------------------------------------------------------
alias nofiles='echo "Total files in directory: $(print -l *(.) | wc -l)"'

# ------------------------------------------------------------------------------
# ALIAS: make1mb / make5mb / make10mb
# DESCRIPTION: Creates a dummy file of a specified size (1MB, 5MB, or 10MB) 
#              filled with zeros using the macOS native 'mkfile' utility.
#              (Note: Size suffixes must be uppercase like M or G on macOS).
# 功能描述：使用 macOS 內建的 'mkfile' 工具建立指定大小（1MB、5MB 或 10MB）
#          的測試空檔案（內容全為零）。注意：macOS 系統的單位必須大寫。
# ------------------------------------------------------------------------------
alias make1mb='mkfile 1M ./1MB.dat'
alias make5mb='mkfile 5M ./5MB.dat'
alias make10mb='mkfile 10M ./10MB.dat'

# ------------------------------------------------------------------------------
# ALIAS: fsize
# DESCRIPTION: Lists all files in the current directory, detailed with human-
#              readable sizes, and automatically sorted from largest to smallest.
# 功能描述：列出當前目錄下的所有檔案詳細資訊，並自動依據檔案大小「由大到小」
#          進行排序，且檔案大小會以易讀的單位（如 KB, MB）顯示。
# ------------------------------------------------------------------------------
alias fsize='ls -lh *(oL.)'

# ------------------------------------------------------------------------------
# FUNCTION: trash()
# DESCRIPTION: Safely moves specified files or folders to the macOS native 
#              Trash folder (~/.Trash) instead of permanently deleting them.
# 功能描述：安全刪除工具。將指定的檔案或資料夾移至 macOS 內建的「垃圾桶」
#          （~/.Trash），避免因誤用系統的 'rm' 指令而導致檔案永久遺失。
# ------------------------------------------------------------------------------
trash () { 
    command mv "$@" ~/.Trash ; 
}

# ==============================================================================
# 📦 ARCHIVE EXTRACTION UTILITIES / 壓縮檔解包自動化工具
# ==============================================================================

# ------------------------------------------------------------------------------
# FUNCTION: extract()
# DESCRIPTION: A smart, single-command utility to automatically detect and 
#              extract almost all known archive formats based on their extensions.
#              (Supports: .tar.lz4, .tar.xz, .tar.bz2, .tar.gz, .bz2, .rar, .gz, 
#               .tar, .tbz2, .tgz, .zip, .Z, .xz, .7z, .lz4, .lzma)
# 功能描述：智慧型萬用解壓功能。只需單一指令，即可自動根據副檔名判別並解開絕
#          大多數常見的壓縮檔格式，省去記憶各種不同解壓參數的麻煩。
# ------------------------------------------------------------------------------
extract () {
    if [ -f "$1" ] ; then
        case "$1" in
            *.tar.lz4)   lz4 -d "$1" -c | tar xf - ;;
            *.tar.xz)    tar xf "$1"      ;;
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.xz)        xz -d "$1"       ;;
            *.7z)        7z x "$1"        ;;
            *.lz4)       unlz4 "$1"       ;;
            *.lzma)      tar --lzma -xvf "$1" ;;
            *.lz4a)      unlz4a "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ==============================================================================
# 🗜️ PARALLEL LZ4 DIRECTORY COMPRESSION / 多核心 LZ4 目錄平行壓縮工具
# ==============================================================================

# ------------------------------------------------------------------------------
# FUNCTION: ffilter()
# DESCRIPTION: Escapes spaces, single quotes, and double quotes in file paths 
#              passed via standard input. Often used as a reliable fallback 
#              when 'find -print0' or standard xargs arguments fail.
# 功能描述：路徑字元跳脫過濾器。自動將標準輸入（stdin）中的空白字元、單引號、
#          雙引號加上反斜線（\）進行跳脫，專門用來解決路徑包含特殊字元時，
#          'find -print0' 或 xargs 處理失敗的痛點。
# ------------------------------------------------------------------------------
function ffilter() {
    sed -e "s/'/\\\'/g" -e 's/"/\\"/g' -e 's/ /\\ /g' 
}

# ------------------------------------------------------------------------------
# FUNCTION: lz4a()
# DESCRIPTION: Compresses a directory recursively using maximum LZ4 compression 
#              (-9m) utilized across multiple CPU cores ($PACORES). It mirrors 
#              the directory structure in a hidden '.lz4a' folder, archives it 
#              into a '.lz4a' file, and compares the final sizes.
# 功能描述：多核心平行資料夾壓縮。利用系統核心數（需預先設定 $PACORES 變數）
#          平行調用 'lz4 -9m' 最高壓縮率，將指定資料夾內的檔案批次壓縮。
#          過程中會暫存於隱藏的 '.lz4a' 目錄，最後打包為 '.lz4a' 封存檔
#          並輸出前後的檔案大小對比。
# ------------------------------------------------------------------------------
function lz4a() {
    find "$1" -type d -print0 | xargs -n 1 -P $PACORES -0 -I'{}' mkdir -p './.lz4a/{}'
    find "$1" -type f | ffilter | xargs -n 1 -P $PACORES lz4 -9m
    find "$1" -name '*.lz4' -print0 | xargs -n 1 -P $PACORES -0 -I'{}' mv '{}' './.lz4a/{}'
    tar -cf "$1.lz4a" ".lz4a/$1" 
    rm -rf .lz4a
    du -sh "$1"
    du -sh "$1.lz4a"
}

# ------------------------------------------------------------------------------
# FUNCTION: unlz4a()
# DESCRIPTION: Decompresses a '.lz4a' archive created by lz4a(). It extracts 
#              the tarball, multi-threads the unlz4 decompression across cores, 
#              restores files back to their original paths, and cleans up.
# 功能描述：多核心平行資料夾解壓縮。用來解開由 'lz4dir' 產生的 '.lz4a' 
#          壓縮檔。首先解開 tar 結構，再透過多核心平行執行 'unlz4' 解壓並
#          刪除來源隱藏檔（--rm），最後將檔案還原至當前目錄並清理暫存。
# ------------------------------------------------------------------------------
function unlz4a() {
    tar -xf "$1"
    find .lz4a -type f | ffilter | xargs -n 1 -P $PACORES unlz4 -m --rm
    mv .lz4a/* . 
    rm -rf .lz4a
}

# ==============================================================================
# 🚀 4. STARTUP SCRIPT MANAGEMENT (HOISTING) / 啟動腳本生命週期管理
# ==============================================================================

# Executed immediately at the beginning of setup / 於配置開頭最先執行的基礎設定
function START_UP@BEGIN() {
    echo "[Info] Running boot scripts... / 正在執行初始引導腳本..."     
    # Bind xargs to scale perfectly with system core threads / 平行化 xargs 執行緒動態綁定
    alias xxargs="xargs -n 1 -P $PACORES"
    alias sll=subl
}

# Executed at the end of setup to finalize environment injection / 於配置末尾執行，完成最終環境導入
function START_UP@END() {
    # Silence missing boot functions to prevent execution noise
    # 將未定義的基礎函式隱藏導向，防止產生不必要的終端機錯誤報錯
    printlibs > /dev/null 2>&1
    bootlibs >/dev/null 2>&1
    setcc          # Apply chosen toolchain setup / 導入選定的編譯器工具鏈
    cheditor vi > /dev/null # Fallback text editor to vi / 設定預設後備編輯器為 vi
    export MAKEJOBS="-j16"  # Parallel compilation limit / 限制平行編譯最大執行緒數
    alias cgrep="grep --color=always"
    # printenv       # Output environment map on terminal login / 登入時印出當前環境變數快照
}

# Execute sequence / 依序觸發生命週期函式
START_UP@BEGIN
START_UP@END