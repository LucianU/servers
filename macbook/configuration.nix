{ pkgs, lib, ... }:

{
  nix.binaryCaches = [
    "https://cache.nixos.org/"
  ];
  nix.binaryCachePublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
  nix.trustedUsers = [
    "@admin"
  ];
  nix.distributedBuilds = true;
  nix.buildMachines = [
    { hostName = "hetzner-main";
      system = "x86_64-linux";
      maxJobs = 100;
      supportedFeatures = [ "benchmark" "big-parallel" ];
    }
  ];

  users.nix.configureBuildUsers = true;
  users.users.lucian = {
    name = "lucian";
    home = "/Users/lucian";
  };

  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  programs.bash.enableCompletion = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=<path/to/configuration.nix>
  environment.darwinConfig = "$HOME/.config/nixpkgs/configuration.nix";
  environment.systemPackages =
    [ pkgs.kitty
      pkgs.vim
    ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
