# Sekio - Raspberry Pi 4B Headless Server with GPS HAT

This configuration creates a Raspberry Pi 4B headless server setup named "sekio" with special handling for a GPS HAT.

## Hardware

- Raspberry Pi 4B
- GPS HAT (connected to UART pins)
- aarch64 architecture
- Headless configuration (no GUI)
- RV3028 RTC module
- PPS signal on GPIO 18

## Special Configuration

This setup includes several special features:

### SD Card Optimization

The system uses several optimizations to extend SD card lifespan:

1. System logs kept in memory with tmpfs
2. ZRAM swap enabled instead of swap on disk
3. Temporary files stored in RAM
4. File system mounted with noatime option
5. Weekly TRIM for flash storage

### UART/GPS Configuration

A custom U-Boot configuration ignores UART interrupts during boot, which prevents the GPS HAT from interfering with the boot process:

1. Uses a custom U-Boot overlay with autoboot enabled
2. Disables serial console on ttyAMA0/ttyS0
3. Configures boot to ignore UART input
4. Sets specific Raspberry Pi device tree overlays:
   - disable-wifi
   - disable-bt
   - miniuart-bt
   - i2c-rtc,rv3028,wakeup-source,backup-switchover-mode=3
   - pps-gpio,gpiopin=18
5. Sets kernel parameters:
   - nohz=off
   - init_uart_baud=115200

## Features

- Minimal server configuration
- SSH access enabled by default with security hardening
- Network Manager for connectivity
- Basic system utilities
- User configuration with home-manager
- WiFi and Bluetooth disabled to save power
- Real-time clock support with RV3028 module
- PPS (Pulse Per Second) GPIO support for precise timing
- GPSD daemon for GPS data collection and distribution
- Chrony NTP server with GPS/PPS integration for stratum 1 time source
- Security features including firewall
- SD card optimizations to reduce wear and extend lifespan:
  - Logs kept in memory
  - ZRAM swap enabled
  - Temporary files in RAM
- GPS/NTP monitoring tools and status script

## Building the SD Card Image

To build the SD card image, run:

```bash
nix build .#images.sekio
```

The resulting image will be available at `./result/sd-image/*.img`.

## Flashing the SD Card

Flash the image to your SD card using a tool like `dd` or a GUI tool like Balena Etcher:

```bash
# Replace /dev/sdX with your SD card device
sudo dd if=./result/sd-image/*.img of=/dev/sdX bs=4M conv=fsync status=progress
```

## First Boot and Setup

On first boot:
1. Connect the Raspberry Pi to your network via Ethernet
2. The system will be available as `sekio.local` on your network
3. SSH into the server: `ssh root@sekio.local` (password: Sekio-R00t-Init-2024)

### Deploying Full Configuration

After booting from the SD card image, deploy the full configuration:

```bash
# From your workstation
deploy -s '.#sekio'
```

During deployment:
1. System changes are applied based on the NixOS configuration
2. The SD card optimizations are maintained to extend lifespan

The system keeps these directories persistent across reboots:
- /etc/ssh - SSH keys
- /var/lib/chrony - NTP server state
- /var/lib/gpsd - GPS daemon data
- /var/lib/NetworkManager - Network configuration
- /nix - The Nix store
- /etc/machine-id - System identifier

After deployment, the system will have:
- U-Boot bootloader for improved reliability
- Secure SSH configuration (password authentication disabled)
- Firewall protection
- All SD card optimizations 
- Proper GPS and NTP service configuration

## Security Notes

- Make sure to change the default root password after first boot
- Consider disabling password authentication in SSH and using key-based authentication only
- Update the host ID in the hardware configuration

## Customization

Customize your configuration by editing the following files:
- `hosts/sekio/default.nix`: Main host configuration
- `hosts/sekio/hardware/default.nix`: Hardware-specific settings
- `hosts/sekio/hardware/rpi-config.nix`: Raspberry Pi specific configuration
- `images/sekio.nix`: SD card image configuration