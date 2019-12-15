{ config, lib, pkgs, ...}:
let
  hcloud-modules = pkgs.fetchgit {
    url = "https://git.ingolf-wagner.de/terranix/hcloud.git";
    rev = "b6896f385f45ecfd66e970663c55635c9fd8b26b";
    sha256 = "1bggnbry7is7b7cjl63q6r5wg9pqz0jn8i3nnc4rqixp0ckwdn85";
  };
in
{

  imports = [
    (toString hcloud-modules)
  ];


}
