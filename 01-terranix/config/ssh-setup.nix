# --------------------------------------------------------------------------------
#
# configure ssh setup
#
# --------------------------------------------------------------------------------

{ config, lib, pkgs, ... }:
let
  ssh = {
    privateKeyFile = ../../sshkey;
    publicKeyFile = ../../sshkey.pub;
  };
  target = file: "${toString ../../02-build/generated}/${file}";
in
{
  # configure admin ssh keys
  users.admins.palo.publicKey = lib.fileContents ssh.publicKeyFile;

  # configure provisioning private Key to be used when running provisioning on the machines
  provisioner.privateKeyFile = toString ssh.privateKeyFile;

  resource.local_file = {

    # provide ssh key for the server
    sshKey = {
      content = lib.fileContents ssh.publicKeyFile;
      filename = target "sshkey.pub";
    };

    sshConfig  = {
      filename = target "ssh-configuration";
      content =
        with lib;
        let
          configPart = name:
          ''
            Host ''${ hcloud_server.${name}.ipv4_address }
            IdentityFile ${toString ssh.privateKeyFile}
            ServerAliveInterval 60
            ServerAliveCountMax 3
          '';
        in
        concatStringsSep "\n" (map configPart (attrNames config.hcloud.server));
    };
  };
}



