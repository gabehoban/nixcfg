# modules/core/packages.nix
#
# System-wide packages configuration
{
  pkgs,
  ...
}:
{
  #
  # System-wide packages
  #
  environment.systemPackages = with pkgs; [
    # Development tools
    actionlint # GitHub Actions workflow linter
    alejandra # Nix formatter
    clang # C/C++ compiler (LLVM)
    clang-tools # C/C++ language server and tools
    gcc # GNU Compiler Collection
    gh # GitHub CLI
    gh-dash # GitHub dashboard TUI
    git
    git-lfs
    gnumake # Make build tool
    mold # Fast modern linker
    libclang # Clang compiler library
    nil # Nix language server
    nixfmt-plus # Enhanced Nix formatter

    # Language servers and formatters
    black # Python formatter
    nodePackages_latest.bash-language-server
    nodePackages_latest.prettier # Multi-language formatter
    prettierd # Prettier as a daemon
    pyright # Python type checker and language server
    python3 # Python interpreter
    shfmt # Shell formatter
    stylua # Lua formatter
    taplo # TOML language server and formatter
    tree-sitter # Parser for syntax highlighting
    yaml-language-server # YAML language server

    # System utilities
    bat # Better cat replacement
    bc # Calculator
    bottom # System resource monitor
    btop # Resource monitor and process viewer
    btrfs-progs # BTRFS filesystem utilities
    cryptsetup # Disk encryption tool
    delta # Enhanced git diff viewer
    duf # Better df replacement
    eza # Better ls replacement
    jq # JSON processor
    lazygit # Git terminal UI
    linuxPackages_latest.perf # Performance analysis tool
    lsof # List open files
    neovim # Modern vim text editor
    nix-index # Locate packages with specific files
    nix-output-monitor # Better nix build output
    nix-prefetch-scripts # Fetch hashes for nix expressions
    nvtopPackages.full # NVIDIA GPU monitoring
    pciutils # PCI bus inspection utilities
    ranger # File manager
    ripgrep # Fast text search tool
    rsync # Efficient file transfer
    speedtest-rs # Network speed test tool
    tree # Directory structure viewer
    usbutils # USB device utilities
    wget # File download utility

    # Archive utilities
    p7zip
    unrar
    unzip
    zip

    # Media utilities
    yt-dlp # Media downloader
  ];

  #
  # Nix helper utilities
  #
  programs.nh = {
    enable = true;
    # Path to local flake
    flake = "/home/gabehoban/nixcfg";
  };
}
