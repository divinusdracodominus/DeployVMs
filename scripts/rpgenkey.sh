file=$1
if [[ $file -eq "" ]]; then
    echo "please enter a file root"
    exit -1
fi
rp genkey rosenpass-secret
rp pubkey rosenpass-secret rosenpass-public
