# modules/core/secrets.nix
#
# Secrets management using agenix and YubiKey authentication
# Configures encrypted secrets with agenix-rekey for host-specific decryption
{
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
  ];

  #
  # Age-rekey configuration
  #
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
}
