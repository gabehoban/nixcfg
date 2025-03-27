# Main configuration for workstation host
{
  configLib,
  inputs,
  ...
}:
{
  networking.hostName = "workstation";

  imports = [
    # ───────────────────────────────────────────
    # Hardware Configuration
    # ───────────────────────────────────────────
    # AMD CPU/GPU support
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    (configLib.relativeToRoot "hosts/common/optional/hardware/amd.nix")

    # Disk and local hardware configuration
    inputs.disko.nixosModules.disko
    ./hardware

    # ───────────────────────────────────────────
    # Core System Modules
    # ───────────────────────────────────────────
    (configLib.relativeToRoot "hosts/common/core")

    # ───────────────────────────────────────────
    # Desktop Environment
    # ───────────────────────────────────────────
    (configLib.relativeToRoot "hosts/common/optional/applications")
    (configLib.relativeToRoot "hosts/common/optional/desktop/environments/gnome.nix")
    (configLib.relativeToRoot "hosts/common/optional/desktop/theme/stylix.nix")
    (configLib.relativeToRoot "hosts/common/optional/desktop/fonts.nix")

    # ───────────────────────────────────────────
    # System Services
    # ───────────────────────────────────────────
    (configLib.relativeToRoot "hosts/common/optional/services/ai.nix")
    (configLib.relativeToRoot "hosts/common/optional/services/audio.nix")
    (configLib.relativeToRoot "hosts/common/optional/services/ssh.nix")
    (configLib.relativeToRoot "hosts/common/optional/services/yubikey.nix")

    # ───────────────────────────────────────────
    # User Configuration
    # ───────────────────────────────────────────
    (configLib.relativeToRoot "hosts/common/users/gabehoban.nix")
  ];
}
