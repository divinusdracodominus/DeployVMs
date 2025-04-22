DISK="$1"
DISK_ID="$2"
MOUNT="/mnt"

if [[ "$1" -eq "" ]]; then
    echo "missing install disk"
    exit -1;
fi

if [[ "$2" -eq "" ]]; then
    echo "missing disk ID";
    exit -2;
fi

partition_disk() {
  echo "[*] Partitioning $DISK..."
  sgdisk --zap-all "$DISK"
  sgdisk -n1:1M:+512M -t1:EF00 "$DISK"
  sgdisk -n2:0:0       -t2:8300 "$DISK"
  partprobe "$DISK"
}

format_and_create_subvolumes() {
  echo "[*] Formatting and creating Btrfs subvolumes..."

  mkfs.vfat -F32 "${DISK}1"
  mkfs.btrfs -f "${DISK}2"

  mount "${DISK}2" "$MOUNT"
  btrfs subvolume create "$MOUNT/@"
  btrfs subvolume create "$MOUNT/@nix"
  btrfs subvolume create "$MOUNT/@home"
  umount "$MOUNT"

  mount -o subvol=@ "${DISK}2" "$MOUNT"
  mkdir -p "$MOUNT"/{boot,nix,home}
  mount -o subvol=@nix "${DISK}2" "$MOUNT/nix"
  mount -o subvol=@home "${DISK}2" "$MOUNT/home"
  mount "${DISK}1" "$MOUNT/boot"
}

generate_config() {
  echo "[*] Generating NixOS config..."
  nixos-generate-config --root "$MOUNT"
}

main() {
  partition_disk
  format_and_create_subvolumes
  generate_config

  echo "[✔] Ready to install NixOS. You can now run:"
  echo "    nixos-install"
}

main "$@"

