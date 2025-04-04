# Secrets Management

This directory contains encrypted secrets used in the NixOS configuration, managed with [agenix](https://github.com/ryantm/agenix) and [agenix-rekey](https://github.com/oddlama/agenix-rekey).

## Directory Structure

- `*.age`: Encrypted secret files
- `yubikey.pub`: YubiKey public key for decryption
- `rekeyed/`: Host-specific rekeyed secrets
  - `workstation/`: Secrets rekeyed for the workstation host

## Secret Files

- `hashed-root-password.age`: Encrypted root password hash
- `hashed-user-password.age`: Encrypted user password hash

## Usage

Secrets are automatically decrypted during system activation when the YubiKey is present.

### Adding New Secrets

1. Create a new secret with `agenix -e new-secret.age`
2. Reference it in your modules using `age.secrets.secret-name.rekeyFile`

### Managing YubiKey

The system uses YubiKey for secret decryption. See the `modules/core/secrets.nix` file for configuration details.

## Security Notes

- **Never commit unencrypted secrets**
- Keep your YubiKey secure
- The `rekeyed/` directory contains host-specific copies of secrets