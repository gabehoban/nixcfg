{
  lib,
  self,
  ...
}: {
  home-manager = {
    users = {
      gabehoban = self.homeManagerModules.gabehoban;
    };
  };
}
