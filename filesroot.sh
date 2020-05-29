#

export IPFS_PATH=${IPFS_PATH:-$HOME/.ipfs}
tic=$(date +%s)
qmroot=$(ipfs files stat / --hash=1)
if test ! -e $IPFS_PATH/filesroot.yml; then
  peerid=$(ipms config Identity.PeerID)
  fname=$(perl -S fullname.pl $peerid)
  echo "--- # $fname ($peerid) /" > $IPFS_PATH/filesroot.yml
fi
echo $tic: $qmroot >> $IPFS_PATH/filesroot.yml
apihost=$(ipfs config Addresses.API | cut -d'/' -f 3)
apiport=$(ipfs config Addresses.API | cut -d'/' -f 5)
gwhost=$(ipfs config Addresses.Gateway | cut -d'/' -f 3)
gwport=$(ipfs config Addresses.Gateway | cut -d'/' -f 5)

swhost=$(ipfs config Addresses.Swarm | grep ip4 | head -1 | cut -d'/' -f 3)
swport=$(ipfs config Addresses.Swarm | grep ip4 | head -1 | cut -d'/' -f 5)


echo uri: ipfs://$swhost:$swport
echo url: http://$apihost:$apiport/webui/#/files/
xdg-open http://$gwhost:$gwport/ipfs/$qmroot;
if pinset=$(ipfs files stat /.pinset --hash=1 2>/dev/null); then
  echo pinset: $pinset
fi


