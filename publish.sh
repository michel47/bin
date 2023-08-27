#

# intent: publish a folder under a key
# 
# usage:
#  publish.sh key /mfspath
#  

echo "--- # ${0##*/}"
if [ "x$1" != 'x' ]; then
 if echo "$1" | grep -q -e '^/'; then
   symb=self;
   ipath="$1"
 else
  symb="${1:-self}"
  ipath="${2:-/public}"
 fi
else
 echo usage:
 echo " ${0##*/} [self] /public"
 symb=self
 ipath='/public'
fi
echo "symb: $symb"
echo "ipath: $ipath"
dname=${ipath#*/}
emptyd=$(ipfs object new -- unixfs-dir)
keyid=$(ipfs key list -l --ipns-base=b58mh | grep -w $symb | cut -d' ' -f1) 
echo keyid: $keyid

root=$(ipfs name resolve $keyid) || root=/ipfs/$emptyd
qmroot=${root##/ipfs/}
echo "qmprev: $qmroot"
#ipfs ls $root | sed -e 's/^/  /' -e 's/ -/:/'
qmpub=$(ipfs files stat --hash "$ipath")
if [ "z$qmpub" != 'z' ]; then
  qmtemp=$(ipfs object patch rm-link $qmroot "$dname" --allow-big-block) && qmroot=$qmtemp
  qmtemp=$(ipfs object patch add-link -p $qmroot "$dname" $qmpub --allow-big-block) && qmroot=$qmtemp
echo "qmroot: $qmroot"
  ipfs ls /ipfs/$qmroot --timeout 3s | sed -e 's/^/  /' -e 's/ -/:/'
  ipfs name publish --key=$keyid /ipfs/$qmroot --allow-offline
  tic=$(date +%s)
  echo $tic: $symb:$keyid $qmroot >> $HOME/var/logs/published.log
fi

exit $?;


true; # $Source: /my/shell/scripts/publish.sh $
