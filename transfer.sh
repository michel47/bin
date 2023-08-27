#


export IPFS_PATH=$HOME/.../ipfs/usb/OOB
qm=$(ipfs add -w -r -Q --pin=false "$@")
gwport=$(ipfs config Addresses.Gateway | cut -d'/' -f 5)
lip=$(hostname --all-ip-addresses | cut -d' ' -f1)
swarmkey.sh
url=http://$lip:$gwport/ipfs/$qm
echo url: $url
qrencode -m 3 -s 5 -o - $url | convert png:- $HOME/Downloads/QR/QROOB.webp
xdg-open $HOME/Downloads/QR/QROOB.webp &
ipfs config Addresses.Gateway "/ip4/$lip/tcp/$gwport"
ipfs daemon
