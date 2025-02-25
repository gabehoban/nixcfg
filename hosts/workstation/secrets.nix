{
  age.secrets = {
    syncthingCert = {
      file = ../../secrets/gabehoban/syncthing/workstation/cert.age;
      path = "/home/gabehoban/.syncthing/cert.pem";
      mode = "644";
    };
    syncthingKey = {
      file = ../../secrets/gabehoban/syncthing/workstation/key.age;
      path = "/home/gabehoban/.syncthing/key.pem";
      mode = "644";
    };
  };
}
