# System packages configuration
# Defines common packages available to all users
{
  pkgs,
  ...
}:
{
  # System-wide packages
  environment.systemPackages = with pkgs; [
    actionlint # GitHub Actions workflow linter
    alejandra # Nix formatter
    bat # Better cat replacement
    bc # Calculator
    black # Python formatter
    bottom # System resource monitor
    btop # Resource monitor and process viewer
    btrfs-progs # BTRFS filesystem utilities
    clang # C/C++ compiler (LLVM)
    clang-tools # C/C++ language server and tools
    cryptsetup # Disk encryption tool
    delta # Enhanced git diff viewer
    duf # Better df replacement
    eza # Better ls replacement
    gcc # GNU Compiler Collection
    gh # GitHub CLI
    gh-dash # GitHub dashboard TUI
    git
    git-lfs
    gnumake # Make build tool
    jq # JSON processor
    lazygit # Git terminal UI
    libclang # Clang compiler library
    linuxPackages_latest.perf # Performance analysis tool
    lsof # List open files
    mold # Fast modern linker
    neovim # Modern vim text editor
    nil # Nix language server
    nix-index # Locate packages with specific files
    nix-output-monitor # Better nix build output
    nix-prefetch-scripts # Fetch hashes for nix expressions
    nixfmt-plus # Enhanced Nix formatter
    nodePackages_latest.bash-language-server
    nodePackages_latest.prettier # Multi-language formatter
    nvtopPackages.full # NVIDIA GPU monitoring
    p7zip
    pciutils # PCI bus inspection utilities
    prettierd # Prettier as a daemon
    pyright # Python type checker and language server
    python3 # Python interpreter
    ranger # File manager
    ripgrep # Fast text search tool
    rsync # Efficient file transfer
    shfmt # Shell script formatter
    speedtest-rs # Network speed test tool
    stylua # Lua formatter
    taplo # TOML language server and formatter
    tree # Directory structure viewer
    tree-sitter # Parser for syntax highlighting
    unrar
    unzip
    usbutils # USB device utilities
    wget # File download utility
    yaml-language-server # YAML language server
    yt-dlp # Media downloader
    zip
  ];

  # Enable 'nh' flake utility
  programs.nh = {
    enable = true;
    flake = "/home/gabehoban/nixcfg"; # Path to local flake
  };
}
