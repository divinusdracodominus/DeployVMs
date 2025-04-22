{pkgs, lib, config, ...}: 
let
  auth = builtins.elem "auth" config.cluster.roles;
  keycloakDomain = "auth.qrespite.org";
  keycloakUrl = "http://${keycloakDomain}:${toString config.services.keycloak.settings.http-port}";
in
{
    services.keycloak = {
      enable = auth;

      database = {
        type = "postgresql";
        createLocally = true;

        username = "keycloak";
        passwordFile = "/cfg/system/secrets/keycloak_psql_pass";
      };

      settings = {
        hostname = "${keycloakDomain}";
        http-relative-path = "/cloak";
        http-port = 38080;
        #proxy-headers = "passthrough";
        http-enabled = true;
      };
    };
}