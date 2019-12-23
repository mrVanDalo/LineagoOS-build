# --------------------------------------------------------------------------------
#
# collect all server information and generate files which get picked up
# by 02-build to deploy the machines properly.
#
# This makes it possible to deploy VPNs like tinc and wireguard.
#
# --------------------------------------------------------------------------------

{ config, lib, pkgs, ... }:
{
  resource.local_file = {
    nixosMachines = {
      content =
        with lib;
        let serverPart = name:
        ''
          ${name} = {
            host = "''${ hcloud_server.${name}.ipv4_address }";
            user = "root";
          };
        '';
        allServerParts = map serverPart (attrNames config.hcloud.server);
        in
        ''
          {
            ${concatStringsSep "\n" allServerParts}
          }
        '';
      filename = "${toString ../../02-build/generated/nixos-machines.nix}";
    };
  };
}
