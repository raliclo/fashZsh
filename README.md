# 🚀 Cross-Platform Optimized Zsh Configuration

![Zsh Support](https://img.shields.io/badge/Shell-Zsh%205.0+-blue?style=for-the-badge&logo=gnu-bash)
![Platform Support](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS-orange?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

This repository contains a highly optimized, cross-platform `.zshrc` configuration featuring **dynamic environment detection**, **on-the-fly compiler switching**, and an **anti-glitch multi-line prompt** tailored for modern workflows on both Linux and macOS (Darwin).

---

## ✨ Core Features

### 1. 🌍 Dynamic Cross-Platform Detection & Optimization
* **Hardware Awareness**: Automatically detects the operating system (`Linux` or `Darwin`), parses `/proc/cpuinfo` or `sysctl` to count logical CPU cores, and dynamically sets parallel compilation threads to `$((Cores * 2))` via `$PACORES`.
* **Path & Tool Alignment**: Adapts smoothly to pathing environments used by either Linuxbrew or native macOS Homebrew (e.g., dynamically handles `$BREW_PREFIX` and `readlink`/`greadlink`).

### 2. 🛠️ Dynamic Compiler Environment Switcher (`setcc`)
The built-in `setcc` utility function allows you to switch and export a complete set of compilation variables (`CC`, `CXX`, `FC`, `CPP`, `GCC_FLAGS`, etc.) instantly within the same terminal session:
* `setcc gcc`: Switches to the system default GCC environment (Default).
* `setcc gccx`: Switches to a custom-version GCC environment (e.g., `gcc-7`).
* `setcc clang`: Switches to the standard or custom Clang/LLVM environment.
* `setcc mpicc`: Switches to the High-Performance Computing (HPC) dedicated MPI (Message Passing Interface) environment.

### 3. 🎨 Anti-Glitch Multi-Line Prompt
* **Glitch Prevention**: Leverages Zsh's unique `%{%}` color control-code wrapping. This completely solves the common glitch in traditional terminal setups where the cursor gets misplaced, overlaps, or breaks during long command wraps or reverse history searches.
* **Clear Navigation**: The upper section features a complete visual divider line alongside a highlighted absolute directory path (`%d`), leaving the lower line dedicated to a clean `=>` prompt so your typing space is never cramped by long paths.

---

## 🚀 Quick Start & Installation

### Step 1: Backup Your Current Configuration
Before making any changes, it is highly recommended to back up your existing `.zshrc`:
```bash
mv ~/.zshrc ~/.zshrc.bak
```

### Step 2: Copy This Configuration
Copy the contents of this repository's `zshrc` into your home directory:
```bash
cp zshrc ~/.zshrc
```

### Step 3: Reload Zsh
```bash
source ~/.zshrc
```

## 🔧 Utility Functions & Aliases

### Common Aliases
* `f` : *(macOS only)* Instantly open the current terminal directory in a Finder window.
* `sll` : Quick-launch/open files and folders using Sublime Text.
* `cgrep` : Force-enables color highlights on all `grep` search results.
* `xxargs` : Dynamically binds a parallelized `xargs` utility utilizing your system's maximum hardware thread capacity (`xargs -n 1 -P $PACORES`).
* `make` : Leverages lazy evaluation to automatically scale with your parallelism configuration (`make $MAKEJOBS`).

### Changing the Default Terminal Editor
Use the `cheditor` function to quickly update your `$EDITOR` environment variable:
```bash
cheditor vi       # Switch default editor to vi
cheditor nano     # Switch default editor to nano
```

## 👥 Authors & Acknowledgments

This configuration was inspired by and built upon excellent dotfiles, utility scripts, and technical guidance provided by the following authors:

* **Ralic Lo** (ralic.lo@gmail.com) - Core architecture design and dynamic environment setups.
* **Nathaniel Landau** ([Website / Resume](https://natelandau.com/nathaniel-landau-resume/)) - Robust bash/zsh shell scripting structures.
* Syntax and command logic insights driven by: [ExplainShell](https://explainshell.com/)

---

## 📄 License

This project is licensed under the **MIT License**. 

Feel free to copy, modify, distribute, or incorporate this configuration into your own personal dotfiles setup. For more details, please refer to the `LICENSE` file in the repository root.
