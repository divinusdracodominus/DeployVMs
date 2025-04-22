{ pkgs, lib, config, ...}:
with lib;
let
  cluster = config.cluster;
  roles = cluster.roles;
  dbGen = import ./functions/postgres-dbs.nix {
    inherit lib;
    enableImmich = builtins.elem "photos" roles;
    enableJellyfin = builtins.elem "movies" roles;
    enableKeycloak = builtins.elem "auth" roles;
    enableNavidrome = builtins.elem "music" roles;
  };
in
{
  services.postgresql = {
    enable = cluster.database == "postgres" && (builtins.elem "database" roles);
    package = pkgs.postgresql_16;
    ensureDatabases = builtins.attrNames dbGen.databases;
    authentication = ''
      local all all trust
    '';
    initialScript = pkgs.writeText "init.sql" dbGen.sqlScript; 
  };
}
