# modules/services/zram.nix
#
# ZRAM swap configuration for improved memory management
_: {
  zramSwap = {
    enable = true;
  };
}