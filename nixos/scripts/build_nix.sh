set -e
config=$1
if [[ $config -eq "" ]]; then
    echo "please provide a config file"
    exit -1
fi

# generate the hostname so that both the host and VM have the same hostname
generate_random_string() {
  local length=$1
  if [[ length -eq "" ]]; then
    length="16"
  fi
  tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$length"
  echo
}

# generate a mac address to store in kea-dhcp-server so that the IP address
# assigned to the virtual machine can be known by the host
generate_virtio_mac() {
  # Generate a MAC address starting with '52:54:00' for virtio
  printf "52:54:00:%02x:%02x:%02x\n" $(($RANDOM % 256)) $(($RANDOM % 256)) $(($RANDOM % 256))
}


hostname=$(generate_random_string 16)
macaddr=$(generate_virtio_mac)
export NIX_VM_HOSTNAME=$hostname
export DOMAIN_NAME="qrespite.org"
echo "creating VM with hostname: $hostname"
nixos-rebuild build-vm -I nixos-config="$config"
qemu-system-x86_64 -m 4096 -drive file=./result/virtualisation/image.qcow2,format=qcow2 -boot d
