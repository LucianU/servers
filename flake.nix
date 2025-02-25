{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.11";
    nixpkgs-2211.url = "github:NixOS/nixpkgs/22.11";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-2211";

    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    eza.url = "github:eza-community/eza";

    tiddlywiki.url = "github:LucianU/nix-tiddlywiki";
    # Private repo
    wikis.url = "git+ssh://git@github.com/LucianU/tiddlywiki-instances.git";
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
          # staging for wikis
          "oci-main" = nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./machines/oci-main/configuration.nix
              sops-nix.nixosModules.sops
            ];
            specialArgs = { inherit inputs; };
          };

          # production for wikis
          "oci-snd" = nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./machines/oci-snd/configuration.nix
              sops-nix.nixosModules.sops
            ];
            specialArgs = { inherit inputs; };
          };

          # nothing for now
          "oci-arm-main" = nixosSystem {
            system = "aarch64-linux";
            modules = [
              ./machines/oci-arm-main/configuration.nix
              sops-nix.nixosModules.sops
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
