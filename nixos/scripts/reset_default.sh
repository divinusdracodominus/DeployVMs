virsh net-destroy default
virsh net-undefine default
virsh net-define ./default.xml
virsh net-start default
virsh net-autostart default
