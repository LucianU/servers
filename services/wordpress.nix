{ config, lib, pkgs, inputs, ... }:
{
	services.wordpress = {
		sites = {
			"hangout.elbear.com" = {
				virtualHost = { };
			};
			"labii.ro" = {
				virtualHost = { };
			};
		};
		webserver = "nginx";
	};

	services.nginx = {
		enable = true;
		virtualHosts = {
			"hangout.elbear.com" = {
				enableACME = true;
				forceSSL = true;
			};
			"labii.ro" = {
				enableACME = true;
				forceSSL = true;
			};
		};
	};
}