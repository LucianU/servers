{ service-name, service-pkg, config, lib, pkgs }:
let
  service-description = "${service-name} - Tiddlywiki instance";
  cfg = config.services.${service-name};
in
  let
    options = import ./options.nix { inherit service-name service-pkg service-description cfg lib; };
    service_config = import ./config { inherit service-name service-description cfg lib pkgs; };
  in
    {
      options = {
        services = {
          ${service-name} = options;
        };
      };
      config = service_config;
    }
