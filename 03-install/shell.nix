{ pkgs ?  import <nixpkgs> {} }:
pkgs.mkShell {

  # follow steps (to install):
  # https://wiki.lineageos.org/devices/suzuran/install

  # make sure you in configuration.nix is
  # programs.adb.enable = true;
  # users.users.mainUser.extraGroups = [ "adbusers" ];
  buildInputs = with pkgs; [
    androidenv.androidPkgs_9_0.platform-tools
  ];

}
