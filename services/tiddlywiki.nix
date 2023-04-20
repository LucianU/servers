{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ../modules/tw-haskell.nix
    ../modules/tw-knowledge-store.nix
    ../modules/tw-publish.nix
    ../modules/tw-rust.nix
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
		tw-publish = {
			enable = true;
			port = 8081;
		};
		tw-haskell = {
			enable = true;
			port = 8082;
		};
		tw-rust = {
			enable = true;
			port = 8083;
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
				"know.elbear.com" = proxy config.services.tw-knowledge-store.port;
				"haskell.elbear.com" = proxy config.services.tw-haskell.port;
				"rust.elbear.com" = proxy config.services.tw-rust.port;
				"publish.elbear.com" = proxy config.services.tw-publish.port;
			};
	};
}