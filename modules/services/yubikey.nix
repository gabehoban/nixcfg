# modules/services/yubikey.nix
#
# YubiKey hardware security key support configuration
{
  pkgs,
  ...
}:
{
  #
  # YubiKey management applications
  #
  environment.systemPackages = with pkgs; [
    # YubiKey OTP and OATH (TOTP/HOTP) authentication
    yubioath-flutter
  ];

  #
  # Hardware support
  #

  # Enable GPG smartcard support for using YubiKey as a GPG key
  hardware.gpgSmartcards.enable = true;

  # Enable PC/SC daemon for smartcard communication
  services.pcscd.enable = true;

  # Add udev rules for YubiKey device detection
  services.udev.packages = with pkgs; [
    # Tools for personalizing YubiKeys
    yubikey-personalization
    # U2F host libraries and udev rules
    libu2f-host
  ];

  #
  # GPG configuration
  #
  home-manager.users.gabehoban = {
    programs.gpg = {
      enable = true;

      # Prevent GnuPG from managing its own CCID interface
      # https://support.yubico.com/hc/en-us/articles/4819584884124-Resolving-GPG-s-CCID-conflicts
      scdaemonSettings = {
        # Prevent CCID conflicts with PC/SC daemon
        disable-ccid = true;
      };

      # Secure GPG configuration settings
      # https://github.com/drduh/config/blob/master/gpg.conf
      settings = {
        #
        # Cryptographic algorithm preferences
        #
        personal-cipher-preferences = "AES256 AES192 AES";
        personal-digest-preferences = "SHA512 SHA384 SHA256";
        personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
        default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
        cert-digest-algo = "SHA512";
        s2k-digest-algo = "SHA512";
        s2k-cipher-algo = "AES256";

        #
        # Output and display preferences
        #
        charset = "utf-8";
        fixed-list-mode = true;
        no-comments = true;
        no-emit-version = true;
        keyid-format = "0xlong";
        list-options = "show-uid-validity";
        verify-options = "show-uid-validity";
        with-fingerprint = true;

        #
        # Security features
        #
        require-cross-certification = true;
        no-symkey-cache = true;
        use-agent = true;
        # Don't include key IDs in encrypted messages
        throw-keyids = true;
      };
    };

    #
    # GPG agent configuration
    #
    services.gpg-agent = {
      enable = true;

      # https://github.com/drduh/config/blob/master/gpg-agent.conf
      # Cache for 60 seconds
      defaultCacheTtl = 60;
      # Maximum cache time of 120 seconds
      maxCacheTtl = 120;
      # Use terminal PIN entry
      pinentryPackage = pkgs.pinentry-curses;
      extraConfig = ''
        # Use current TTY for PIN entry
        ttyname $GPG_TTY
      '';
    };
  };
}
