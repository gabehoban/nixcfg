# profiles/applications/browser.nix
#
# Web browser applications profile
{
  configLib,
  ...
}: {
  imports = [
    # Web browser modules
    (configLib.moduleImport "applications/app-firefox.nix")
  ];
}