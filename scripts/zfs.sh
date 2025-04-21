
# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root"
  exit 1
fi

# Variables
POOL_NAME="mypool"  # Replace with your ZFS pool name
ROOT_FS_NAME="$POOL_NAME/root"  # Replace with your dataset name for root

# Install ZFS (if not already installed)
nixos-rebuild switch --upgrade
#nixos-option nixpkgs.config.packageOverrides = pkgs: {
#  zfs = pkgs.zfs_2_1;
#}
nixos-rebuild switch

# Create ZFS Root Dataset (If not already created)
echo "Creating ZFS root dataset..."
zfs create -o mountpoint=/ -o canmount=off $ROOT_FS_NAME
zfs mount $ROOT_FS_NAME

# Set ZFS mountpoint to root (if not already set)
echo "Setting ZFS root mountpoint..."
zfs set mountpoint=/ $ROOT_FS_NAME

# Ensure ZFS pool is mounted
echo "Verifying pool is mounted..."
zpool status $POOL_NAME

# Update /etc/fstab for ZFS root mount
echo "Updating /etc/fstab..."
echo "$ROOT_FS_NAME / zfs defaults 0 0" > /etc/fstab

# Create the NixOS configuration to mount ZFS at boot
echo "Configuring NixOS for ZFS root..."


# Add ZFS kernel modules and mount the filesystem at boot
cat <<EOF > /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  boot.loader.grub.device = "/dev/sda";  # Modify to match your disk
  boot.kernelModules = [ "zfs" ];
  boot.zfs.enable = true;
  boot.zfs.poolName = "$POOL_NAME";  # Use your pool name here
  boot.zfs.root = "$ROOT_FS_NAME";   # Root filesystem dataset

  imports = [ "/cfg/system/default.nix" ];
  # Optional: You can add more configurations for ZFS, like compression, etc.
}
EOF

# Rebuild NixOS configuration
nixos-rebuild switch

# Verify and reboot
echo "ZFS root filesystem setup complete. Rebooting system..."
#reboot