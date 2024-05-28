{ pkgs, lib, ... }:

{
  nix.settings = {
    trusted-users = [ "@admin" ];
    substituters = [ "https://cache.nixos.org/" ];
    trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  };

  nix.configureBuildUsers = true;

  nix.distributedBuilds = true;

  nix.buildMachines = [
    { hostName = "oci-main";
      system = "x86_64-linux";
      maxJobs = 100;
      supportedFeatures = [ "benchmark" "big-parallel" "kvm" "nixos-test" ];
    }
  ];

  nix.extraOptions = ''
    auto-optimise-store = true
    builders-use-substitutes = true
    experimental-features = nix-command flakes
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
  };

  users.users.lucian = {
    name = "lucian";
    home = "/Users/lucian";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.lucian = import ./home.nix;
  };

  programs.bash.enableCompletion = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=<path/to/configuration.nix>
  environment.darwinConfig = "$HOME/.config/nixpkgs/configuration.nix";
  environment.systemPackages =
    [ pkgs.vim
    ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
