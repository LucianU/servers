{ ... }: {
  imports = [
    ./hardware-configuration.nix


  ];

  boot.cleanTmpDir = true;
  zramSwap.enable = true;

	networking = {
		hostName = "oci-snd";
		firewall.allowedTCPPorts = [ 80 443 ];
	};

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPI+dFnzXZ0xACwp1x9hMH0FFx4+WLj7ZiXW+j2z58sc lucian@Lucians-MacBook-Pro-2.local"
  ];

	nixpkgs.system = "x86_64-linux";
	system.stateVersion = "23.05";
}
