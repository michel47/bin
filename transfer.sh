#


export IPFS_PATH=$HOME/.../ipfs/usb/SECURED
qm=$(ipfs add -w -r -Q "$@")
gwport=$(ipfs config Addresses.Gateway | cut -d'/' -f 5)
lip=$(hostname --all-ip-addresses | cut -d' ' -f1)
url=http://$lip:$gwport/ipfs/$qm
echo url: $url
qrencode -m 3 -s 5 -o - $url | convert png:- $HOME/Downloads/QR/QRsecure.webp
xdg-open $HOME/Downloads/QR/QRsecure.webp &
ipfs config Addresses.Gateway "/ip4/$lip/tcp/$gwport"
ipfs daemon
