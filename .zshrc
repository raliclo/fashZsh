#!/bin/zsh
## Study REF-> https://explainshell.com/

# ==============================================================================
# 🌍 GLOBAL ENVIRONMENTAL VARIABLES / 全域環境變數設定
# ==============================================================================
export LC_ALL=en_US.UTF-8
export LoginDay=$(date +%F)

# Authors / 核心作者 : 
# [Ralic Lo (ralic.lo@gmail.com)
# [NATHANIEL LANDAU] https://natelandau.com/nathaniel-landau-resume/


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
