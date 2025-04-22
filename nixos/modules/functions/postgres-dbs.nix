{ lib
, enableImmich ? false
, enableJellyfin ? false
, enableKeycloak ? false
, enableNavidrome ? false
}:

let
  inherit (lib) mkMerge mkIf;

  databases = mkMerge [
    (mkIf enableImmich {
      immich = { user = "immich"; };
    })
    (mkIf enableJellyfin {
      jellyfin = { user = "jellyfin"; };
    })
    (mkIf enableKeycloak {
      keycloak = { user = "keycloak"; };
    })
    (mkIf enableNavidrome {
      navidrome = { user = "navidrome"; };
    })
  ];
in
{
  
  databases = databases;

  # Or optionally turn it into SQL if needed:
  sqlScript = (lib.mapAttrsToList (name: attr:
  let user = if builtins.isAttrs attr && attr ? user then attr.user else name;
  in ''
    CREATE DATABASE ${name};
    GRANT ALL PRIVILEGES ON ${name} TO ${user};
  ''
) databases);
}