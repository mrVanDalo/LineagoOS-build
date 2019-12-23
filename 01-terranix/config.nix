{ config, lib, pkgs, ...}:
let
  hcloud-modules = pkgs.fetchgit {
    url = "https://github.com/mrVanDalo/terranix-hcloud.git";
    rev = "b6896f385f45ecfd66e970663c55635c9fd8b26b";
    sha256 = "1bggnbry7is7b7cjl63q6r5wg9pqz0jn8i3nnc4rqixp0ckwdn85";
  };
in
{

  imports = [
    (toString hcloud-modules)

    ./config/file-generation.nix
    ./config/ssh-setup.nix
  ];

  hcloud.nixserver.lineageOS-builder = {
    serverType = "ccx31";
    configurationFile = pkgs.writeText "configuration.nix" ''
      { pkgs, lib, ... }:
      {
        environment.systemPackages = with pkgs; [
          htop git vim mosh
        ];
        networking.firewall.allowedUDPPorts = [ 60001 ];
      }
      '';
  };

}
