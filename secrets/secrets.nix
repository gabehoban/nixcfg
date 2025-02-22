let
  hosts = [
    "workstation"
  ];
  users = [
    "gabehoban_workstation"
  ];
  systemKeys = builtins.map (host: builtins.readFile ./publicKeys/root_${host}.pub) hosts;
  userKeys = builtins.map (user: builtins.readFile ./publicKeys/${user}.pub) users;
  keys = systemKeys ++ userKeys;
in {
  "gabehoban/syncthing/workstation/cert.age".publicKeys = keys;
  "gabehoban/syncthing/workstation/key.age".publicKeys = keys;
}
