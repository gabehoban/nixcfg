# Casio - GPS/NTP Server

Casio is a Stratum 1 NTP server using GPS for accurate time synchronization, running on a Raspberry Pi 4B.

## Hardware

- Raspberry Pi 4B
- GPS HAT with PPS (Pulse Per Second) output
- DS3231 RTC (Real Time Clock) module for backup timing
- External GPS antenna

## Services

- GPSD for GPS data processing
- Chrony for NTP server functionality
- Monitoring for GPS and NTP services

## Configuration

The configuration is based on the shared GPS/NTP server profile, with host-specific settings for:

- Network and hostname
- Security settings
- Performance optimizations

## Building and Deploying

To build the SD card image:

```
nix build .#images.casio
```

Flash the resulting image to an SD card.

## Similarities with Sekio

Casio follows the same configuration pattern as Sekio, but can be deployed to a separate physical machine to provide redundancy for NTP services.