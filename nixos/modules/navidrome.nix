{ pkgs, lib, config, ...}:
with lib;
let
    music = builtins.elem "musicc" config.cluster.roles;
in
{
    services.navidrome = {
        enable = music;
    };
}