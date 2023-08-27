#

set -e
dir="$1"
if [ ! -d "$dir" ];then
  dir=$HOME/.../ipfs/usb/PERMLINK
  #dir=$HOME/.../ipfs/usb/SWITCH
fi
intent="move content from $IPFS_PATH/blocks to $1/blocks"
IPFS_PATH=${IPFS_PATH:-$HOME/.ipfs}
shards=$(ls -1d $IPFS_PATH/blocks/* | perl -S randomize.pl)
for d in $shards; do
  echo $d:
  list=$(ls -1S $d | grep -v -e '^CIQ')
  for f in $list; do
    h32=${f%%.*}
    len=$(echo $h32 | wc -c)
    p=$(expr $len - 3)
    p1=$(expr $len - 2)
    shard=$(echo $h32 | cut -c$p-$p1)
    #echo $f ${len}c $shard
    if [ ! -d $dir/blocks/$shard ]; then
      mkdir -p $dir/blocks/$shard
      echo mkdir -p $dir/blocks/$shard
    fi
    mv -n $d/$f $dir/blocks/$shard/$f
    echo -n "$dir/blocks/$shard/$f \r"
    #exit
  done
done


