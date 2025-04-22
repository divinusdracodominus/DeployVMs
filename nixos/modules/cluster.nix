{ pkgs, lib, config, ...}:
with lib;
let 
    roles = config.cluster.roles;
    photos = builtins.elem "photos" roles;
    movies = builtins.elem "movies" roles;
    music = builtins.elem "music" roles;
    auth = builtins.elem "auth" roles;
    cfg = config.cluster;
    defaultDomain = builtins.getEnv "DOMAINE_NAME";
in
{
    options = {
        cluster = {
            roles = mkOption {
                type = types.listOf types.str;
                description = "name of roles that are allowed in this cluster";
                default = [ "photos" "auth" "movies" "music" "database" ];
            };

            database = mkOption {
                type = types.enum [ "postgres" ];
                default = "postgres";
                description = "which database backend to use";
            };

            domain = mkOption {
                type = types.str;
                example = "cluster.com";
                default = "${defaultDomain}";
            };

            databaseUrl = mkOption {
                type = types.str;
                example = "postgresql://db.cluster.com";
                default = "db.${cfg.domain}";
            };

            authUrl = mkOption {
                type = types.str;
                example = "auth.cluster.com";
                default = "auth.${cfg.domain}";
            };

            photosUrl = mkOption {
                type = types.str;
                example = "photos.cluster.com";
                default = "photos.${cfg.domain}";
            };

            musicUrl = mkOption {
                type = types.str;
                example = "music.cluster.com";
                default = "music.${cfg.domain}";
            };
        };
    };

    config = {
        networking.firewall.allowedTCPPorts = [ 
            80 443
            (mkIf photos config.services.immich.port)
        ];

    };
}