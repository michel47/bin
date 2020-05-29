#

export DISPLAY=${DISPLAY:-:1}
export WWW=${WWW:-/usr/local/share/doc/civetweb/public_html}
rxvt -geometry 128x18 -bg black -fg green -name civet -n Civet -title "civet web ($WWW)" -e sudo civetweb &
sleep 3
cd $WWW
#
echo http://yoogle.com:8088/cgi-bin/header.pl?url=https://ipfs.blockRingTM.ml/ipfs/QmSX3f5QM41mJyPwaxECpNcam8XtEhTybkPm7FB71Kybgb

exit 1;
