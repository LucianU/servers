{ lib, ... }: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [
      "67.207.67.2"
      "67.207.67.3"
    ];
    defaultGateway = "64.225.64.1";
    defaultGateway6 = "2a03:b0c0:2:f0::1";
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce true;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address="64.225.74.143"; prefixLength=20; }
{ address="10.18.0.6"; prefixLength=16; }
        ];
        ipv6.addresses = [
          { address="2a03:b0c0:2:f0::364:5001"; prefixLength=64; }
{ address="fe80::d4a5:c0ff:fe87:725b"; prefixLength=64; }
        ];
        ipv4.routes = [ { address = "64.225.64.1"; prefixLength = 32; } ];
        ipv6.routes = [ { address = "2a03:b0c0:2:f0::1"; prefixLength = 32; } ];
      };
      
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="d6:a5:c0:87:72:5b", NAME="eth0"
    
  '';
}
