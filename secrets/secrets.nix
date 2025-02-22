let
  hosts = [
    "fallarbor"
    "lilycove"
    "mauville"
    "petalburg"
    "rustboro"
    "slateport"
    "sootopolis"
  ];
  users = [
    "aly_fallarbor"
    "aly_lilycove"
    "aly_mauville"
    "aly_petalburg"
    "aly_rustboro"
    "aly_slateport"
    "aly_sootopolis"
  ];
  systemKeys = builtins.map (host: builtins.readFile ./publicKeys/root_${host}.pub) hosts;
  userKeys = builtins.map (user: builtins.readFile ./publicKeys/${user}.pub) users;
  keys = systemKeys ++ userKeys;
in {
  "aly/syncthing/fallarbor/cert.age".publicKeys = keys;
  "aly/syncthing/fallarbor/key.age".publicKeys = keys;
  "aly/syncthing/lilycove/cert.age".publicKeys = keys;
  "aly/syncthing/lilycove/key.age".publicKeys = keys;
  "aly/syncthing/mauville/cert.age".publicKeys = keys;
  "aly/syncthing/mauville/key.age".publicKeys = keys;
  "aly/syncthing/pacifidlog/cert.age".publicKeys = keys;
  "aly/syncthing/pacifidlog/key.age".publicKeys = keys;
  "aly/syncthing/petalburg/cert.age".publicKeys = keys;
  "aly/syncthing/petalburg/key.age".publicKeys = keys;
  "aly/syncthing/rustboro/cert.age".publicKeys = keys;
  "aly/syncthing/rustboro/key.age".publicKeys = keys;
  "aly/syncthing/slateport/cert.age".publicKeys = keys;
  "aly/syncthing/slateport/key.age".publicKeys = keys;
  "aly/syncthing/sootopolis/cert.age".publicKeys = keys;
  "aly/syncthing/sootopolis/key.age".publicKeys = keys;
  "spotify/clientId.age".publicKeys = keys;
  "spotify/clientSecret.age".publicKeys = keys;
  "tailscale/authKeyFile.age".publicKeys = keys;
}
