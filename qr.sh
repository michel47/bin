#

ip=$(perl -S localip.pl)
gwport=$(ipfs config Addresses.Gateway | cut -d'/' -f 5)

if echo "$1" | grep -q -e '^Qm' ; then
chart="https://api.safewatch.care/api/v0/qrcode?size=4&url"
qm="$1"
xdg-open "$chart=http://$ip:$gwport/ipfs/$qm"
else 
chart="https://chart.googleapis.com/chart?cht=qr&chs=222x222&choe=UTF-8&chld=H&chl"
qm=$(ipfs add -w -Q $@)
fi
echo url: https://dweb.link/ipfs/$qm
echo url: http://$ip:$gwport/ipfs/$qm
xdg-open "$chart=http://$ip:$gwport/ipfs/$qm"

shortqm=$(echo $qm | cut -c42-)
echo shortqm: $shortqm
curl -s -o qrcode-$shortqm.png "$chart=https://ipfs.safewatch.tk/ipfs/$qm"
eog qrcode-$shortqm.png

