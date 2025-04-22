{ pkgs, lib, config, ...}:

let
  # Define the directory containing the .nix files
  nixDir = ./modules;

  # Function to get all .nix file paths in the directory
  getNixFilePaths = dir: builtins.map (file: "${dir}/${file}") (builtins.filter (file: builtins.match ".*\\.nix$" file != null) (builtins.attrNames (builtins.readDir dir)));

  # Get the list of Nix file paths
  nixFilePaths = getNixFilePaths nixDir;
  fileImports = [ ] ++ nixFilePaths;
in

{
  
  security.pam.sshAgentAuth.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  imports = fileImports;

  users.users.admin = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    Password = "";
  };
}
