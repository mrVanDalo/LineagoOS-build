
A setup to build lineage os on a hetzner box

# How to build and install lineag-os on a sony z5 compact

## OPTIONAL: generate fresh ssh keys

```sh
ssh-keygen -P "" -f sshkey
```

## generate machine

```sh
cd ./01-terranix
nix-shell --run "create"
```

## ssh to machine

```sh
cd ./02-build
nix-shell --run "mosh-nixserver-lineageOS-builder"
```

## build

copy `./02-build/build-shell.nix` to `/root/shell.nix`

Than run

```sh
run-step1
... do some manual work
run-step2
```

## download and install

copy the resulting `lineage-14.1-<date>-UNOFFICIAL-suzuran.zip` and `recovery.img` to `./03-install`
and in there run `nix-shell` 
and follow the steps of https://wiki.lineageos.org/devices/suzuran/install

Install 

* [FDroid](https://f-droid.org/)
* [Aurora Store](https://f-droid.org/en/packages/com.aurora.store/)
* [Yalp](https://f-droid.org/en/packages/com.github.yeriomin.yalpstore/)

and start from there.

## cleanup

cleanup do

```sh
cd ./01-terranix
nix-shell --run "clean"
```
