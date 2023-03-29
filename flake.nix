{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/22.11";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    age-keys.url = "/Users/lucian/.config/sops/age";

    knowledge-store.url = "/Users/lucian/code/web/knowledge-store";
    knowledge-store.inputs.nixpkgs.follows = "nixpkgs";

    wikis.url = "/Users/lucian/code/web/wikis";
    wikis.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, sops-nix, age-keys, ... }: {
    nixosConfigurations = {
      "knowledge-store" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./new-knowledge-store/configuration.nix
          sops-nix.nixosModules.sops
        ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}
