# modules/users/gabehoban.nix
#
# User configuration for gabehoban
{ config, ... }:
{
  age.secrets.hashed-root-password.rekeyFile = ../../secrets/hashed-root-password.age;
  age.secrets.hashed-user-password.rekeyFile = ../../secrets/hashed-user-password.age;

  #
  # User account configuration
  #
  users = {
    users = {
      # Primary user account
      gabehoban = {
        isNormalUser = true;
        description = "Gabe Hoban";

        # Group membership for various system capabilities
        extraGroups = [
          "networkmanager" # Network management
          "wheel" # Administrative access
          "media" # Media files access
          "input" # Input devices access
          "libvirt" # Virtualization
          "audio" # Audio devices
          "video" # Video devices
          "power" # Power management
          "users" # Standard user group
          "kvm" # KVM virtualization
        ];

        # Password hash for login
        hashedPasswordFile = config.age.secrets.hashed-user-password.path;

        # SSH configuration
        openssh = {
          # Authorized keys for SSH access - ensure this key has sudo access for deploy-rs deployments
          authorizedKeys.keys = [
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqFRwe/auSdigp5l+XmgIABl8rIIFuwBh9I2WNRpIfYKYJRyKkLbYZO3Z56lCxqjJkTUIIdw+hsUvR3A71HVRnRlx05pMQ9IMn6XSrx+AQVXs/hBFNijQsmCVUMebop2kW1WZUfIgMg4+5L9VQPL+pX6ARKuXSf8Gv2Qn+rInpY1rYE9DesezjzA2Cljr3Pii1JlmqYDDLS2HnZ10FhJfutqWPUR9RnX4HcVXKcxE9rgHzjGSyNkaFVX2HG8SafePyABacoajNQVORn7PHD9RLUeQ+qM8IIvAVxig2JPt36AnWjakSumwgyf/NjrbjJTMlacN3zqresfcsa3+HdGki86QRbZ2bNRurrBbevxxzgQggjW0506drw49sN/y78BGuYjZJjQW3C7TPHaLpPBKMIEFz64vuwATZiLpSb/mfGqXvpXb9Yl91qYbOy6GdXOO54EMb4zM6pQn1n3h6uaneJ/ZjM2GarbcGE5d/Nxw3AsS7gVUBAXrkbHdmJnXzoZWKO1DGjx7fGnHHvyKZN997BEzGpTMIRbF7g2S0RLVVjVYmLJNpCPGxkWACeJN+CXYof/Yl1adeCmQVLagtO8HwsBQLRO2CJwveUwnNRK3WVOOM8DK+u5ROgg1XJO7ngXnP3HKql6ju0kYRpwlRj/dZNrsJh7tYDgXr/9B8I/9Q4w=="
          ];
        };
      };

      # Root account configuration
      root = {
        isNormalUser = false;
        hashedPasswordFile = config.age.secrets.hashed-root-password.path;
        # SSH configuration
        openssh = {
          # Authorized keys for SSH access - ensure this key has sudo access for deploy-rs deployments
          authorizedKeys.keys = [
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCqFRwe/auSdigp5l+XmgIABl8rIIFuwBh9I2WNRpIfYKYJRyKkLbYZO3Z56lCxqjJkTUIIdw+hsUvR3A71HVRnRlx05pMQ9IMn6XSrx+AQVXs/hBFNijQsmCVUMebop2kW1WZUfIgMg4+5L9VQPL+pX6ARKuXSf8Gv2Qn+rInpY1rYE9DesezjzA2Cljr3Pii1JlmqYDDLS2HnZ10FhJfutqWPUR9RnX4HcVXKcxE9rgHzjGSyNkaFVX2HG8SafePyABacoajNQVORn7PHD9RLUeQ+qM8IIvAVxig2JPt36AnWjakSumwgyf/NjrbjJTMlacN3zqresfcsa3+HdGki86QRbZ2bNRurrBbevxxzgQggjW0506drw49sN/y78BGuYjZJjQW3C7TPHaLpPBKMIEFz64vuwATZiLpSb/mfGqXvpXb9Yl91qYbOy6GdXOO54EMb4zM6pQn1n3h6uaneJ/ZjM2GarbcGE5d/Nxw3AsS7gVUBAXrkbHdmJnXzoZWKO1DGjx7fGnHHvyKZN997BEzGpTMIRbF7g2S0RLVVjVYmLJNpCPGxkWACeJN+CXYof/Yl1adeCmQVLagtO8HwsBQLRO2CJwveUwnNRK3WVOOM8DK+u5ROgg1XJO7ngXnP3HKql6ju0kYRpwlRj/dZNrsJh7tYDgXr/9B8I/9Q4w=="
          ];
        };
      };
    };

    # Additional system groups
    groups = {
      docker = { };
      libvirt = { };
    };
  };

  #
  # Home Manager configuration
  #
  home-manager.users.gabehoban = {
    home.username = "gabehoban";
    home.homeDirectory = "/home/gabehoban";
    home.stateVersion = "24.11";
  };

  #
  # Security configuration
  #
  # Allow sudo without password for wheel group members
  security.sudo.wheelNeedsPassword = false;
}
