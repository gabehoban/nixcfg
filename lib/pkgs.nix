{ lib, ... }:
{
  # Package-related helper functions
  importPackagesByCategory =
    pkgs: categories:
    lib.fold (
      category: acc: acc // { ${category} = import ../pkgs/${category} { inherit pkgs; }; }
    ) { } categories;
}
