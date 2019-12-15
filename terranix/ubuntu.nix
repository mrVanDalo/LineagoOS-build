{ pkgs, ... }:
{
  hcloud.server = {
    lineagos-builder = {
      enable = true;
      serverType = "cx31";
      image = "ubuntu-18.04";
      provisioners = [
        {
          remote-exec.inline = [
            # everything up to date
            "apt-get update"
            # install minimal stuff
            "apt-get install -y mosh vim htop"
          ];

        }
        {
          # step 1: install dependencies
          remote-exec.inline = [
            "apt-get install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev"
            "apt-get install -y openjdk-8-jdk-headless"
          ];

        }
        {
          # step 2: setup android sdk
          remote-exec.inline = [
            ''
              set -x
              apt-get install -y curl wget zip unzip python
              #wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
              #unzip platform-tools-latest-linux.zip -d ~
              #echo 'PATH="$HOME/platform-tools:$PATH"' >> ~/.profile
            ''
          ];
        }
        {
          # step 3: install android repo binary
          remote-exec.inline = [
            ''
              set -x
              mkdir -p ~/bin
              mkdir -p ~/android/lineage
              curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
              chmod a+x ~/bin/repo
              echo 'PATH="$HOME/bin:$PATH"' >> ~/.profile
            ''
          ];
        }
        {
          remote-exec.inline = [

            ''
              set -x
              cd ~/android/lineage
              git config --global user.name "John Doe"
              git config --global user.email johndoe@example.com

              #repo init -u https://github.com/LineageOS/android.git -b cm-14.1
              #repo sync
            ''
          ];
        }
        {
          file.destination = "/root/run-1.sh";
          file.content = ''
            set -x

            cd $HOME
            wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
            unzip platform-tools-latest-linux.zip -d ~
            echo 'PATH="$HOME/platform-tools:$PATH"' >> ~/.profile

            cd ~/android/lineage
            repo init -u https://github.com/LineageOS/android.git -b cm-14.1
            repo sync
            source build/envsetup.sh
            breakfast suzuran

            echo
            echo "now edit .repo/local_manifests/roomservice.xml"
            echo '<project name="TheMuppets/proprietary_vendor_sony" path="vendor/sony" depth="1" />'
            echo
            echo "and than run run-2.sh"

            '';
        }
        {
          file.destination = "/root/run-2.sh";
          file.content = ''
            set -x

            cd ~/android/lineage
            repo sync
            source build/envsetup.sh
            breakfast suzuran

            ccache -M 50G
            croot
            brunch suzuran

            echo 'all done, now go to cd $OUT'
            # cd $OUT
          '';
        }
      ];
    };
  };
}
