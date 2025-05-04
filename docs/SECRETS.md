# Secrets Management

This document explains how secrets are managed in this NixOS configuration using agenix with agenix-rekey and YubiKey hardware tokens.

## Overview

This project uses a sophisticated two-layer encryption system:
1. **YubiKey Master Identity**: Private keys stored on YubiKey hardware tokens that encrypt the original secrets
2. **Host SSH Keys**: Each host's SSH key can decrypt secrets specifically rekeyed for that host
3. **agenix-rekey**: Automatically rekeys secrets from the YubiKey master to host-specific keys

This approach provides:
- Hardware-based security with YubiKey protection
- Host-specific access control
- Automated secret deployment during NixOS builds
- No need to have YubiKey present during deployments

## Architecture

### Two-Layer Encryption Model

```
YubiKey (Master) → Original Secrets (.age files)
       ↓
  agenix-rekey
       ↓
Host SSH Keys → Rekeyed Secrets (in secrets/rekeyed/<hostname>/)
```

1. **Master Secrets**: Encrypted with YubiKey public key, stored in `/secrets/*.age`
2. **Rekeyed Secrets**: Re-encrypted for specific hosts, stored in `/secrets/rekeyed/<hostname>/`
3. **Runtime Decryption**: Hosts use their SSH keys to decrypt their specific secrets

## Configuration

### agenix-rekey Setup

The core configuration in `modules/core/secrets.nix`:

```nix
age.rekey = {
  # Use YubiKey as the master identity for decryption
  masterIdentities = [
    {
      identity = inputs.self + "/secrets/yubikey.pub";
      pubkey = "age1yubikey1qfccny0m02fzfgtee8wu598587qesyu5972dem7drjteztl93qa8uuy4phd";
    }
  ];

  # Store rekeyed secrets locally for each host
  storageMode = "local";
  localStorageDir = inputs.self.outPath + "/secrets/rekeyed/${config.networking.hostName}";
};
```

### Host Configuration

Each host must specify its SSH public key:

```nix
# In hosts/<hostname>/default.nix
age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA...";
```

This public key is used by agenix-rekey to encrypt secrets specifically for this host.

## Adding New Secrets

### 1. Create the Master Secret

First, create the encrypted secret file using your YubiKey:

```bash
cd secrets/
agenix -e new-secret.age
```

This encrypts the secret with your YubiKey public key.

### 2. Define the Secret in a Module

In the module that needs the secret:

```nix
# modules/services/example.nix
{
  age.secrets.new-secret = {
    rekeyFile = ../../secrets/new-secret.age;
    mode = "0400";           # File permissions
    owner = "service-user";  # Owner user
    group = "service-group"; # Owner group
  };
}
```

### 3. Use the Secret

Reference the decrypted secret path in your service configuration:

```nix
services.example = {
  secretFile = config.age.secrets.new-secret.path;
};
```

### 4. Rekey for Hosts

Run the rekey command to generate host-specific encrypted versions:

```bash
# Rekey all secrets for all hosts
nix run .#agenix-rekey

# Or rekey for specific hosts
nix run .#agenix-rekey -- rekey -a
```

This creates files in `/secrets/rekeyed/<hostname>/` that can be decrypted by each host's SSH key.

## Deployment Workflow

1. **Development Time**: Secrets are encrypted with YubiKey
2. **Build Time**: agenix-rekey creates host-specific versions
3. **Deploy Time**: Host uses its SSH key to decrypt its secrets
4. **Runtime**: Secrets are available as files in `/run/agenix/`

No YubiKey is needed during deployment - only during initial secret creation or modification.

## Managing Secrets

### Editing Existing Secrets

1. **With YubiKey**:
   ```bash
   cd secrets/
   agenix -e existing-secret.age
   ```

2. **Rekey for hosts**:
   ```bash
   nix run .#agenix-rekey
   ```

3. **Commit changes**:
   ```bash
   git add secrets/existing-secret.age secrets/rekeyed/
   git commit -m "Update existing-secret"
   ```

### Adding Secrets to New Hosts

When adding a new host:

1. **Get host's SSH public key**:
   ```bash
   ssh-keyscan -t ed25519 new-host.example.com
   ```

2. **Add to host configuration**:
   ```nix
   age.rekey.hostPubkey = "ssh-ed25519 AAAAC3...";
   ```

3. **Rekey all secrets**:
   ```bash
   nix run .#agenix-rekey
   ```

4. **Commit the rekeyed secrets**:
   ```bash
   git add secrets/rekeyed/new-host/
   git commit -m "Add secrets for new-host"
   ```

## YubiKey Setup

### Prerequisites

1. A YubiKey 5 series device
2. age and age-plugin-yubikey installed
3. agenix installed

### Initial Setup

1. **Install required tools**:
   ```bash
   nix-shell -p age age-plugin-yubikey
   ```

2. **Initialize YubiKey for age**:
   ```bash
   age-plugin-yubikey
   ```

   Follow the prompts to set up your YubiKey for age encryption.

3. **Get your public key**:
   ```bash
   age-plugin-yubikey --identity
   ```

   This will output your public key, which should be saved as `secrets/yubikey.pub`.

## Security Model

### Benefits

1. **Hardware Security**: Master keys never exist in software
2. **Host Isolation**: Each host can only decrypt its own secrets
3. **Deployment Security**: No YubiKey needed during deployments
4. **Version Control**: All encrypted secrets can be safely stored in Git
5. **Audit Trail**: Git history shows all secret changes

### Trust Model

- **YubiKey**: Ultimate authority for all secrets
- **Host SSH Keys**: Limited authority for host-specific secrets
- **Git Repository**: Stores all encrypted secrets safely
- **Build System**: Can rekey but not decrypt secrets without YubiKey

## Troubleshooting

### Common Issues

1. **"Failed to decrypt secret"**
   - Verify the host's SSH key matches `age.rekey.hostPubkey`
   - Ensure secrets were rekeyed after adding the host
   - Check file permissions on SSH private key

2. **"YubiKey not found" during rekeying**
   - Ensure YubiKey is inserted
   - Check age-plugin-yubikey is installed
   - Verify YubiKey has been initialized for age

3. **"No rekeyed secrets for host"**
   - Run `nix run .#agenix-rekey`
   - Verify host has `age.rekey.hostPubkey` configured
   - Check that modules properly define secrets with `rekeyFile`

### Debugging Commands

```bash
# List all secrets that should be rekeyed
nix eval .#agenix-rekey.secrets

# Show rekey configuration for a host
nix eval .#nixosConfigurations.hostname.config.age.rekey

# Manually decrypt a secret (requires YubiKey)
age -d -i ~/.age/yubikey-identity.txt secrets/secret-name.age

# Check which secrets a host can access
nix eval .#nixosConfigurations.hostname.config.age.secrets
```

## Best Practices

1. **Commit Rekeyed Secrets**: Always commit rekeyed secrets after changes
2. **Backup YubiKey**: Keep a secure backup YubiKey
3. **Document Secrets**: Maintain a list of what each secret contains
4. **Regular Audits**: Periodically review which hosts have access to which secrets
5. **Test Recovery**: Regularly test secret recovery procedures

## Recovery Procedures

### Lost Host SSH Key

If a host's SSH key is compromised or lost:

1. Generate new SSH host keys on the affected host
2. Update `age.rekey.hostPubkey` in the host configuration
3. Rekey all secrets: `nix run .#agenix-rekey`
4. Deploy the updated configuration

### Lost YubiKey

If your YubiKey is lost or damaged:

1. Use your backup YubiKey (if available)
2. If no backup exists:
   - Set up a new YubiKey with age-plugin-yubikey
   - Update `masterIdentities` in `modules/core/secrets.nix`
   - Manually re-encrypt all secrets with the new YubiKey
   - Rekey all secrets for hosts
   - Update all systems

### Adding a Backup YubiKey

To add redundancy with multiple YubiKeys:

1. Set up additional YubiKey with age-plugin-yubikey
2. Add its public key to `masterIdentities` in `modules/core/secrets.nix`
3. Re-encrypt all secrets to include the new YubiKey
4. Rekey all secrets for hosts

## Architecture Details

### File Structure

```
secrets/
├── *.age                    # Master secrets encrypted with YubiKey
├── yubikey.pub             # YubiKey public key(s)
└── rekeyed/                # Host-specific rekeyed secrets
    └── <hostname>/         # Secrets for specific host
        └── <hash>-<name>.age
```

### Secret Lifecycle

1. **Creation**: Secret encrypted with YubiKey public key
2. **Definition**: Module specifies secret with `rekeyFile`
3. **Rekeying**: agenix-rekey creates host-specific versions
4. **Deployment**: Host configuration includes rekeyed secrets
5. **Runtime**: Host decrypts with its SSH key, available at `/run/agenix/`

## Related Documentation

- [DEPLOYMENT.md](./DEPLOYMENT.md) - How to deploy systems with secrets
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Overall system architecture
- [ADDING_HOSTS.md](./ADDING_HOSTS.md) - Adding new hosts with secrets
- [age-plugin-yubikey documentation](https://github.com/str4d/age-plugin-yubikey)
- [agenix-rekey documentation](https://github.com/oddlama/agenix-rekey)
