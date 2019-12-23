{ pkgs ?  import <nixpkgs> {} }:

let

  terranix = pkgs.callPackage (pkgs.fetchgit {
    url = "https://github.com/mrVanDalo/terranix.git";
    rev = "6097722f3a94972a92d810f3a707351cd425a4be";
    sha256 = "1d8w82mvgflmscvq133pz9ynr79cgd5qjggng85byk8axj6fg6jw";
  }) { };

  terraform = pkgs.writers.writeDashBin "terraform" ''
    export TF_VAR_hcloud_api_token=`${pkgs.pass}/bin/pass development/hetzner.com/api-token`
    ${pkgs.terraform_0_11}/bin/terraform "$@"
  '';

  create = pkgs.writers.writeDashBin "create" ''
    ${terranix}/bin/terranix | ${pkgs.jq}/bin/jq '.' > ${toString ./.}/config.tf.json \
      && ${terraform}/bin/terraform init \
      && ${terraform}/bin/terraform apply
  '';

in pkgs.mkShell {

  buildInputs = with pkgs; [
    terranix
    terraform
    create
  ];

}
