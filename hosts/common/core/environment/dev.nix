# Development tools configuration
# Defines development-specific packages and tools
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    #
    # Build systems and analysis tools
    #
    gnumake # Make build tool
    linuxPackages_latest.perf # Performance analysis tool

    #
    # Language servers for IDE features
    #
    # C/C++
    clang-tools # C/C++ language server and tools
    # Nix
    nil # Nix language server
    # Bash
    nodePackages_latest.bash-language-server
    # Python
    pyright # Python type checker and language server
    # TOML
    taplo # TOML language server and formatter
    # YAML
    yaml-language-server # YAML language server

    #
    # Code formatters
    #
    alejandra # Nix formatter
    shfmt # Shell script formatter
    stylua # Lua formatter
    black # Python formatter
    nodePackages_latest.prettier # Multi-language formatter
    prettierd # Prettier as a daemon
    nixfmt-plus # Enhanced Nix formatter

    #
    # Linters
    #
    actionlint # GitHub Actions workflow linter

    #
    # Compilers
    #
    clang # C/C++ compiler (LLVM)
    gcc # GNU Compiler Collection

    #
    # Linkers
    #
    mold # Fast modern linker

    #
    # CLI development tools
    #
    jq # JSON processor
    lsof # List open files
    speedtest-rs # Network speed test tool

    #
    # Terminal UI tools
    #
    lazygit # Git terminal UI
    delta # Enhanced git diff viewer
    gh # GitHub CLI
    gh-dash # GitHub dashboard TUI

    #
    # Programming languages
    #
    python3 # Python interpreter

    #
    # Development libraries
    #
    libclang # Clang compiler library
  ];
}
