{ pkgs, lib, config, ...}:
let
    photos = builtins.elem "photos" config.cluster.roles;
in
{
    services.immich = lib.mkIf photos {
      enable = true;
      port = 2283;
      openFirewall = true;
      environment = {
        # OIDC settings for Keycloak
        # You must replace these with your actual Keycloak client and issuer URL
        #IMMICH_AUTH_TYPE = "oidc";
        #IMMICH_OIDC_CLIENT_ID = "immich";
        #IMMICH_OIDC_CLIENT_SECRET = "0OkN0rGUAUYyYqaQpCB2LAsW0Fej6sGa";
        #IMMICH_OIDC_ISSUER_URL = "${keycloakUrl}/cloak/realms/qrespite.org";
      };
    };
}