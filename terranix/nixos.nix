{ pkgs, ... }:
{
  hcloud.nixserver.lineagos-builder = {
    enable = true;
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
