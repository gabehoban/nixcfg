# modules/services/zram.nix
#
# ZRAM swap configuration for improved memory management
_: {
  #
  # ZRAM swap configuration
  #
  # Enable ZRAM-based swap for improved performance and memory management
  zramSwap = {
    enable = true;

    # Use default algorithm for compression
    algorithm = "zstd";
  };
}
