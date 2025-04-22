{ config, pkgs, lib, ... }:
with lib;
let
  auth = builtins.elem "auth" config.cluster.roles;
  photos = builtins.elem "photos" config.cluster.roles;
  music = builtins.elem "music" config.cluster.roles;
  cfg = config.cluster;
in
{
  
    environment.etc."keycloak-database-pass".text = "PWD";
    
    services.nginx = {
      enable = true;

      # enable recommended settings
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;

      virtualHosts = {
        "${cfg.authUrl}" = mkIf auth {
          locations."/cloak/" = {
              proxyPass = "http://localhost:${toString config.services.keycloak.settings.http-port}/cloak/";
            };
          };

          "${cfg.photosUrl}" = mkIf photos {
            locations."/photos" = mkIf photos {
              proxyPass = "http://localhost:${toString config.services.immich.port}";
              proxyWebsockets = true;
              recommendedProxySettings = true;
              extraConfig = ''
                client_max_body_size 50000M;
                proxy_read_timeout   600s;
                proxy_send_timeout   600s;
                send_timeout         600s;
              '';
            };
          };

          "{cfg.musicUrl}".locations."/music" = mkIf music {
            proxyPass = "http://localhost:${toString config.services.navidrome.settings.Port}";
            proxyWebsockets = true;
            recommendedProxySettings = true;
          };
      };
      
    };
    
}
