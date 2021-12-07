#
# Intent
#  moving IPFS hashes that cause gc error


# usage: ipmove.sh qm-gc-errors.loh
IPFS_PATH=${IPFS_PATH:-$HOME/.ipfs}
PRIVATE_PATH=$HOME/.../ipfs/usb/PRIVATE

file="${1:-qmlist.lst}"
cat $file | perl -S uniq.pl | while read line; do
qm=$(echo $line | cut -d' ' -f1)
echo // qm: $qm
bafy=$(echo $qm | mbase -d --bafy);
echo bafy: $bafy
AFK=$(echo $bafy | cut -c 2- | tr '[:lower:]' '[:upper:]')

len=$(echo -n $AFK | wc -c)
p0=$(expr $len - 2)
p1=$(expr $len - 1)
#echo len: $len, $p0, $p1
ashard=$(echo $AFK | cut -c$p0-$p1)
echo AFK: $AFK
echo ashard: $ashard
if [ -e $IPFS_PATH/blocks/$ashard/$AKF.dat ]; then
  echo mv $IPFS_PATH/blocks/$ashard/$AKF.data $PRIVATE_PATH/blocks/$ashard/$AKF.data
  mv $IPFS_PATH/blocks/$ashard/$AKF.data $PRIVATE_PATH/blocks/$ashard/$AKF.data
else
locate -e -b $AFK
fi

CIQ=$(echo $qm | mbase -d --ciq);
len=$(echo -n $CIQ | wc -c)
p0=$(expr $len - 2)
p1=$(expr $len - 1)
#echo len: $len, $p0, $p1
cshard=$(echo $CIQ | cut -c$p0-$p1)
echo CIQ: $CIQ
echo cshard: $cshard
if [ -e $IPFS_PATH/blocks/$cshard/$CIQ.data ]; then
  echo mv $IPFS_PATH/blocks/$cshard/$CIQ.data $PRIVATE_PATH/blocks/$cshard/$CIQ.data
  mv $IPFS_PATH/blocks/$cshard/$CIQ.data $PRIVATE_PATH/blocks/$cshard/$CIQ.data
else
locate -e -b $CIQ
fi

#find -L $IPFS_PATH/blocks/$ashard $IPFS_PATH/blocks/$cshard -name "$AFK.*" -o -name "$CIQ.*"
#echo locate:

echo .
done
