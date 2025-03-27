# System packages configuration
# Defines common packages available to all users
{
  pkgs,
  ...
}:
{
  # System-wide packages
  environment.systemPackages = with pkgs; [
    #
    # Core utilities
    #

    # Version control
    git
    git-lfs

    # File utilities
    bc # Calculator
    rsync # Efficient file transfer
    wget # File download utility

    # Archive utilities
    unzip
    unrar
    p7zip
    zip

    #
    # Enhanced CLI tools
    #

    # Improved alternatives to standard tools
    bat # Better cat replacement
    eza # Better ls replacement
    duf # Better df replacement

    #
    # Text editor and dependencies
    #
    neovim # Modern vim text editor
    tree-sitter # Parser for syntax highlighting
    ripgrep # Fast text search tool

    #
    # System monitoring and management
    #
    bottom # System resource monitor
    tree # Directory structure viewer
    btop # Resource monitor and process viewer
    ranger # File manager
    yt-dlp # Media downloader
    nvtopPackages.full # NVIDIA GPU monitoring

    #
    # Nix-specific tools
    #
    nix-prefetch-scripts # Fetch hashes for nix expressions
    nix-output-monitor # Better nix build output
    nix-index # Locate packages with specific files

    #
    # Hardware utilities
    #
    pciutils # PCI bus inspection utilities
    usbutils # USB device utilities

    #
    # Filesystem tools
    #
    cryptsetup # Disk encryption tool
    btrfs-progs # BTRFS filesystem utilities
  ];

  # Enable 'nh' flake utility
  programs.nh = {
    enable = true;
    flake = "/home/gabehoban/nixcfg"; # Path to local flake
  };
}
