{ pkgs ?  import <nixpkgs> {} }:

with pkgs.lib;

let

  servers = import ./generated/nixos-machines.nix;

  sshServer = name: {user, host, ... }:
  pkgs.writers.writeDashBin "ssh-${name}" ''
    ${pkgs.openssh}/bin/ssh -F ${toString ./generated/ssh-configuration} "${user}@${host}"
  '';

  moshServer = name: {user, host, ... }:
  pkgs.writers.writeDashBin "mosh-${name}" ''
    ${pkgs.mosh}/bin/mosh \
      --ssh="${pkgs.openssh}/bin/ssh -F ${toString ./generated/ssh-configuration}" \
      "${user}@${host}"
  '';

in
pkgs.mkShell {

  buildInputs =
    mapAttrsToList moshServer servers
    ++
    mapAttrsToList sshServer servers;

}
