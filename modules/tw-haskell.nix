{ config, lib, pkgs, inputs, ... }:

let
  mk-TW-Instance = import ./mk-tw-instance.nix;
in
  let
    tw-haskell-pkg = inputs.wikis.packages.${config.nixpkgs.system}.haskell;
  in
    mk-TW-Instance {
      service-name = "tw-haskell";
      service-pkg = tw-haskell-pkg;
      inherit config lib pkgs;
    };
