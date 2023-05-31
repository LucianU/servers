{ cfg }:
let
  virtualHosts = {
    "${cfg.domainName}" = {
      forceSSL = true;
      enableACME = true;

      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:" + toString(cfg.port) + "/";
          extraConfig = ''
            proxy_set_header        Host             $host;
            proxy_set_header        X-Real-IP        $remote_addr;
            proxy_set_header        X-Forwarded-For  $proxy_add_x_forwarded_for;
          '';
        };
      };
    };
  };
in
  {
    enable = true;
    virtualHosts = virtualHosts;
  }
