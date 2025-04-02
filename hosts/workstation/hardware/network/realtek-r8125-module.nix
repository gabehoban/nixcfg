# ───────────────────────────────────────────
# Realtek R8125 Driver Module Definition
# ───────────────────────────────────────────
{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
}:
stdenv.mkDerivation rec {
  # ───────────────────────────────────────────
  # Package Metadata
  # ───────────────────────────────────────────
  pname = "r8125";
  # On update please verify (using `diff -r`) that the source matches the
  # realtek version.
  version = "9.014.01";

  # ───────────────────────────────────────────
  # Source Configuration
  # ───────────────────────────────────────────
  # This is a mirror. The original website[1] doesn't allow non-interactive
  # downloads, instead emailing you a download link.
  # [1] https://www.realtek.com/en/component/zoo/category/network-interface-controllers-10-100-1000m-gigabit-ethernet-pci-express-software
  src = fetchFromGitHub {
    owner = "louistakepillz";
    repo = "r8125";
    rev = version;
    sha256 = "sha256-vYgAOmKFQZDKrZsS3ynXB0DrT3wU0JWzNTYO6FyMG9M=";
  };

  # ───────────────────────────────────────────
  # Build Configuration
  # ───────────────────────────────────────────
  # Disable position independent code for kernel module build
  hardeningDisable = [ "pic" ];

  # Kernel module build dependencies
  nativeBuildInputs = kernel.moduleBuildDependencies;

  # Patch Makefile to fix build issues
  preBuild = ''
    substituteInPlace src/Makefile --replace "BASEDIR :=" "BASEDIR ?="
    substituteInPlace src/Makefile --replace "modules_install" "INSTALL_MOD_PATH=$out modules_install"
  '';

  # Set the kernel module directory
  makeFlags = [
    "BASEDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}"
  ];

  # Only build the modules target
  buildFlags = [ "modules" ];

  # ───────────────────────────────────────────
  # Package Metadata
  # ───────────────────────────────────────────
  meta = with lib; {
    homepage = "https://github.com/louistakepillz/r8125";
    downloadPage = "https://www.realtek.com/en/component/zoo/category/network-interface-controllers-10-100-1000m-gigabit-ethernet-pci-express-software";
    description = "Realtek r8125 driver";
    longDescription = ''
      A kernel module for Realtek 8125 2.5G network cards.
    '';
    #broken = lib.versionAtLeast kernel.version "5.9.1";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ peelz ];
  };
}
