#
IPFS_PATH=${IPFS_PATH:-$HOME/.ipfs}
echo "--- # ${0##*/}"
while read qm; do
echo qm: $qm
ciq=$(echo $qm | mbase -d -a | grep ciq | cut -d' ' -f2)
len=$(echo $ciq | wc -c)
p=$(expr $len - 3)
q=$(expr $len - 2)
shard=$(echo $ciq | cut -c$p-$q)
echo shard: $shard
echo ciq: $ciq
block=$IPFS_PATH/blocks/$shard/$ciq.data
if [ -e $block ]; then
ls -l $IPFS_PATH/blocks/$shard/$ciq.data
rm -f $IPFS_PATH/blocks/$shard/$ciq.data
else
  locate $ciq.data
fi


done
