
set -e

# Configuration
DISK_BY_ID="/dev/vda"
ZPOOL_NAME="rpool"
MOUNTPOINT="/mnt"

# Partition disk (GPT with a boot and ZFS partition)
partition_disk() {
  echo "Partitioning disk $DISK_BY_ID..."
  sgdisk --zap-all "$DISK_BY_ID"
  sgdisk -n1:1M:+512M -t1:EF00 "$DISK_BY_ID"  # EFI partition
  sgdisk -n2:0:0     -t2:BF01 "$DISK_BY_ID"   # ZFS partition
  partprobe "$DISK_BY_ID"
}

# Create ZFS pool with encryption
create_zfs_pool() {
  echo "Creating ZFS pool $ZPOOL_NAME with encryption..."
  local zfs_dev="${DISK_BY_ID}2"
  zpool create -f \
    -o ashift=12 \
    -O encryption=on \
    -O keyformat=passphrase \
    -O keylocation=prompt \
    -O mountpoint=none \
    "$ZPOOL_NAME" "$zfs_dev"
}

# Create ZFS dataset for root
create_zfs_root_dataset() {
  echo "Creating root dataset..."
  zfs create -o mountpoint=legacy "$ZPOOL_NAME"/root
  mkdir -p "$MOUNTPOINT"
  mount -t zfs "$ZPOOL_NAME"/root "$MOUNTPOINT"
}

# Create EFI partition and mount
prepare_efi() {
  echo "Formatting and mounting EFI partition..."
  local efi_dev="${DISK_BY_ID}1"
  mkfs.vfat -F32 "$efi_dev"
  mkdir -p "$MOUNTPOINT/boot"
  mount "$efi_dev" "$MOUNTPOINT/boot"
}

# Generate NixOS configuration
generate_nixos_config() {
  echo "Generating NixOS config..."
  nixos-generate-config --root "$MOUNTPOINT"
}

main() {
  partition_disk
  create_zfs_pool
  create_zfs_root_dataset
  prepare_efi
  generate_nixos_config

  echo "Done. Ready for NixOS installation."
}
echo $DISK_BY_ID
main "$@"