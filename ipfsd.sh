#

red="[31m"
green="[32m"
reset="[0m"

REPO="$1"

#if [ -e $HOME/bin/ipfs ]; then
 #export PATH=$HOME/bin:$PATH
#fi

qm=$(echo "IPFS is active" | ipfs add --offline -Q) && echo "qm: $qm"
qm=$(echo "IPFS is active" | ipfs add -n -Q --hash id)
# ------------------------------------------------------
if [ "x$REPO" != "x" ]; then

if test -d /media/IPFS/$REPO; then
  export IPFS_PATH=/media/IPFS/$REPO
  #GW=$(ipfs --offline config show | xjson Addresses.Gateway) # need API running
  GW=$(cat $IPFS_PATH/config | xjson Addresses.Gateway)
  pp=$(echo $GW|cut -d'/' -f5)
  #name=$(ipfs --offline id | xjson ID | fullname)
  name=$(cat $IPFS_PATH/config | xjson Identity.PeerID | fullname)
  echo env IPFS_PATH=${green}/media/IPFS/$REPO${reset} ipfs daemon
  OPTIONS="--unrestricted-api --enable-namesys-pubsub"
  rxvt -geometry 128x18 -bg black -fg lightyellow -name IPFS -n "$pp" -title "ipfs daemon:$pp ($REPO) ~ $name" -e ipfs daemon $OPTIONS &
  sleep 7
  ipfs id
  echo -n $green
  ipfs cat /ipfs/$qm
  echo -n $reset
  tic=$(date +%s)
  qmroot=$(ipfs files stat / --hash=1)
  echo "$tic: $qmroot" >> $IPFS_PATH/filesroot.yml
fi
# ------------------------------------------------------
else
unset IPFS_PATH
IPFS_PATH=$HOME/.ipfs
GW=$(cat $IPFS_PATH/config | xjson Addresses.Gateway)
pp=$(echo $GW|cut -d'/' -f5)
#name=$(ipfs --offline id | xjson ID | fullname)
name=$(cat $IPFS_PATH/config | xjson Identity.PeerID | fullname)
# -------------------
if curl -s -S -I http://127.0.0.1:$pp/ipfs/$qm | grep -q X-Ipfs-Path; then
  echo ${green}$name running$reset on port:$pp
# -------------------
else
  echo "$name ${red}not running$reset on port:$pp; $?"
  # ipfs daemon --enable-namesys-pubsub 
  rxvt -geometry 128x18 -bg black -fg lightyellow -name IPFS -n "$pp" -title "ipfs daemon:$pp (default) ~ $name" -e ipfs daemon --enable-namesys-pubsub &

  sleep 7
  ipfs --offline id | xjson ID
fi
tic=$(date +%s)
qmroot=$(ipfs files stat / --hash=1)
echo "$tic: $qmroot" >> $IPFS_PATH/filesroot.yml
# -------------------
#for REPO in BLOCKRING COLD OOB INFINITE PRIVATE PERMLINK AUDIO IMAGES MEDIA LEDGER MUTABLES BACKUP FILED RANDOM; do
# launch them all ...
for IPFS_PATH in /media/IPFS/* ; do
REPO=${IPFS_PATH##*/}
if test -f $IPFS_PATH/config; then #[
export IPFS_PATH=/media/IPFS/$REPO
echo -n "$IPFS_PATH: "
if ipfs --offline id > /dev/null; then
 echo "id ok"
else 
 echo "! id"
 #exit $?;
fi
GW=$(cat $IPFS_PATH/config | xjson Addresses.Gateway)
pp=$(echo $GW|cut -d'/' -f5)
#name=$(ipfs --offline id | xjson ID | fullname)
name=$(cat $IPFS_PATH/config | xjson Identity.PeerID | fullname)
# -------------------
if curl -s -I http://127.0.0.1:$pp/ipfs/$qm | grep -q X-Ipfs-Path; then
echo ${green}$name running${reset} on port:$pp
# -------------------
else
  echo ipfs $name ${red}not running${reset} on /ip4/0.0.0.0/tcp/$pp
  rxvt -geometry 128x18 -bg black -fg lightyellow -name IPFS -n "$pp" -title "ipfs daemon:$pp ($IPFS_PATH) ~ $name" -e ipfs daemon &
  #exit;
  sleep 7
fi
# -------------------
ipfs cat /ipfs/$qm
ipfs stats repo | grep -v Version
tic=$(date +%s)
qmroot=$(ipfs files stat / --hash=1)
echo "$tic: $qmroot" >> $IPFS_PATH/filesroot.yml
echo .
fi #]
done

export IPFS_PATH=/media/IPFS/PERMLINK

fi

if [ "x$REPO" != "x" ]; then
# debug,info,warning,error,critical
ipfs log level -- all critical
ipfs log level -- gc info
ipfs log level -- dht info
ipfs log level -- sum info
ipfs log level -- ipns-repub info

ipfs log level -- pubsub error
ipfs log level -- blockservice warning
ipfs log level -- keystore debug

ipfs log level -- cmd/ipfs debug
ipfs log level -- cmds/cli debug
ipfs log level -- cmds/http info
fi


exit 1;
