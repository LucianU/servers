{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.11";
    nixpkgs-2211.url = "github:NixOS/nixpkgs/22.11";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-2211";

    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    eza.url = "github:eza-community/eza";

    tiddlywiki.url = "github:LucianU/nix-tiddlywiki";

    wikis.url = "/Users/lucian/code/wikis";

  };

  outputs = inputs@{
    self,
    nixpkgs-2211,
    sops-nix,
    flake-parts,
    treefmt-nix,
    eza,
    darwin,
    home-manager,
    nixos-wsl,
    ...
    }:
    let
      inherit (nixpkgs-2211.lib) nixosSystem;
      inherit (darwin.lib) darwinSystem;
      nixpkgsConfig = {
        overlays = [ self.overlays.default ];
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {

      systems = [
          "aarch64-darwin"
          "x86_64-darwin"
          "x86_64-linux"
          "aarch64-linux"
      ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        devShells = {
          default = pkgs.mkShell {
            name = "servers";
            packages = with pkgs; [
              (ghc.withPackages (p: with p; [
                optparse-applicative
                optparse-simple
                turtle
              ]))
            ];
          };
        };

        formatter =
          treefmt-nix.lib.mkWrapper
            pkgs
            {
              projectRootFile = "flake.nix";
              programs.nixpkgs-fmt.enable = true;
              programs.black.enable = true;
            };
      };

      flake = {
        overlays.default = final: prev: {
          inherit eza;
        };

        nixosConfigurations = {
          "oci-main" = nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./machines/oci-main/configuration.nix
              sops-nix.nixosModules.sops
            ];
            specialArgs = { inherit inputs; };
          };

          "oci-snd" = nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./machines/oci-snd/configuration.nix
              sops-nix.nixosModules.sops
            ];
            specialArgs = { inherit inputs; };
          };

          "oci-arm-main" = nixosSystem {
            system = "aarch64-linux";
            modules = [
              ./machines/oci-arm-main/configuration.nix
              sops-nix.nixosModules.sops
            ];
            specialArgs = { inherit inputs; };
          };

          "asus-rog" = nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./machines/asus-rog/configuration.nix
              nixos-wsl.nixosModules.wsl
            ];
            specialArgs = { inherit inputs; };
          };
        };

        darwinConfigurations = {
          "Lucians-MacBook-Pro" = darwinSystem {
            system = "aarch64-darwin";
            modules = [
              ./machines/macbook-pro/configuration.nix
              home-manager.darwinModules.home-manager
              { nixpkgs = nixpkgsConfig; }
            ];
          };
        };
      };
    };
}
