{
  description = "Nix setup for M1 Macbook Pro";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-22.05-darwin";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, darwin, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (darwin.lib) darwinSystem;
      homeManagerConfig = {
        nixpkgs.config = {
          allowUnfree = true;
          allowBroken = true;
        };
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.lucian = import ./home.nix;
      };
      pkgs = nixpkgs.legacyPackages."aarch64-darwin";
    in
      {
        darwinConfigurations = {
          "Lucians-MacBook-Pro" = darwinSystem {
            system = "aarch64-darwin";
            modules = [
              ./configuration.nix
              home-manager.darwinModules.home-manager
       	      homeManagerConfig
            ];
          };
        };
        devShells = {
          "aarch64-darwin".default = pkgs.mkShell {
            packages = [ pkgs.bashInteractive ];
          };
        };
      };
}
