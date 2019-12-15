# I used this shell.nix to build LineageOS 14.1 for my Z5 Compact phone
# The build instructions for normal Linuxes are here: https://wiki.lineageos.org/devices/suzuran/build
# For NixOS, follow those instructions but skip anything related to installing packages
# Detailed instructions:
#   cd into an empty directory of your choice
#   copy this file there
#   in nix-shell:

#   step 1:
#    $ repo init -u https://github.com/LineageOS/android.git -b cm-14.1
#    $ repo sync     # this takes forever (2 - 4 hours) and ca 30GB of hard drive
#    $ source build/envsetup.sh
#    $ breakfast suzuran

#   manual :
#    Get proprietary blobs (see https://wiki.lineageos.org/devices/suzuran/build#extract-proprietary-blobs)
#     (I actually used blobs from https://github.com/TheMuppets, following https://forum.xda-developers.com/showpost.php?s=a6ee98b07b1b0a2f4004b902a65d9dcd&p=76981184&postcount=4)
#    by add to .repo/local_manifests/roomservice.xml
#     <!-- binary blobs -->
#     <project name="TheMuppets/proprietary_vendor_sony" path="vendor/sony" depth="1" />
#    $ repo sync     # this takes forever (2 - 4 hours) and ca 30GB of hard drive
#    $ source build/envsetup.sh
#    $ breakfast suzuran

#   2:
#    $ ccache -M 50G (see https://wiki.lineageos.org/devices/maguro/build#turn-on-caching-to-speed-up-build)
#    $ croot
#    $ brunch suzuran
#    $ cd $OUT

#   The built ROM is named something like lineage-13.0-20180730-UNOFFICIAL-maguro.zip
#   You can flash it onto your device as usual, see e.g. https://wiki.lineageos.org/devices/suzuran/install for maguro
#   Voilà ! It Just Works™ (at least it did for me)

# Warning: the hardened NixOS kernel disables 32 bit emulation, which made me run into multiple "Exec format error" errors.
# To fix, use the default kernel, or enable "IA32_EMULATION y" in the kernel config.


let
  # nixpkgs-unstable does not have jdk7 anymore. I used the nixos-18.03 channel
  pkgs = import <nixpkgs> {};

  scripts = {
    step1 = pkgs.writers.writeBashBin "run-step1" ''
      set -x
      repo init -u https://github.com/LineageOS/android.git -b cm-14.1

      repo sync
      source build/envsetup.sh

      set +x
      breakfast suzuran

      cat <<EOF
      now add to .repo/local_manifests/roomservice.xml

        <!-- binary blobs -->
        <project name="TheMuppets/proprietary_vendor_sony" path="vendor/sony" depth="1" />

      EOF
    '';
    step2 = pkgs.writers.writeBashBin "run-step2" ''
      set -x
      repo sync
      source build/envsetup.sh
      breakfast suzuran
      ccache -M 50G
      croot
      brunch suzuran
    '';
  };

  # Inspired from https://nixos.wiki/wiki/Android#Building_Android_on_NixOS
  # I had to add several packages to make it work for me
  fhs = pkgs.buildFHSUserEnv {
    name = "android-env";
    targetPkgs = pkgs: with pkgs; [

      scripts.step1
      scripts.step2

      androidenv.androidPkgs_9_0.platform-tools
      bc
      binutils
      bison
      ccache
      curl
      flex
      gcc
      git
      gitRepo
      gnumake
      gnupg
      gperf
      imagemagick
      openjdk8_headless
      libxml2
      lz4
      lzop
      m4
      maven # Needed for LineageOS 13.0
      nettools
      openssl
      perl
      pngcrush
      procps
      python2
      rsync
      schedtool
      SDL
      squashfsTools
      unzip
      utillinux
      wxGTK30
      xml2
      zip

      # needed for editing
      vim
    ];
    multiPkgs = pkgs: with pkgs; [
      zlib
      ncurses5
      libcxx
      readline
    ];
    runScript = "bash";
    profile = ''
      export USE_CCACHE=1
      export ANDROID_JAVA_HOME=${pkgs.openjdk8.home}
      export LC_ALL=C
      export ANDROID_JACK_VM_ARGS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx4G"

      export GIT_AUTHOR_NAME="gibson"
      export GIT_AUTHOR_EMAIL="gibson@cyber.com"
      export GIT_COMMITTER_NAME="gibson"
      export GIT_COMMITTER_EMAIL="gibson@cyber.com"

      # Building involves a phase of unzipping large files into a temporary directory
      export TMPDIR=/tmp
    '';
  };

in pkgs.stdenv.mkDerivation {
  name = "android-env-shell";
  nativeBuildInputs = [ fhs ];
  shellHook = "exec android-env";
}
