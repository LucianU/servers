{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ../modules/tw-knowledge-store.nix
  ];

	users = {
		groups = {
			tiddlywiki = {};
		};
		users = {
			tiddlywiki = {
				group = "tiddlywiki";
				isSystemUser = true;
			};
		};
	};

	services = {
		tw-knowledge-store = {
			enable = true;
			port = 8080;
		};
	};

	services.nginx = {
		enable = true;
		recommendedGzipSettings = true;
		recommendedOptimisation = true;
		recommendedTlsSettings = true;

		virtualHosts = let
			common = locations: {
				enableACME = true;
				forceSSL = true;

				inherit locations;
			};

			proxy = port:
				common {
					"/" = {
						proxyPass = "http://127.0.0.1:" + toString(port) + "/";
						extraConfig = ''
							proxy_set_header        Host             $host;
							proxy_set_header        X-Real-IP        $remote_addr;
							proxy_set_header        X-Forwarded-For  $proxy_add_x_forwarded_for;
						'';
					};
				};
		in
			{
				"know.staging.elbear.com" = proxy config.services.tw-knowledge-store.port;
			};
	};
}