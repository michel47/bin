#

# indent: check size of disks and create duc charts ...

echo "--- # ${0##*/}"
ls -l $HOME/Pictures/*.svg

if [ -d "$1" ]; then
  if ! echo "$1" | grep -q '^/'; then
    d="$(pwd -P)/$1"
    d=$(readlink -f "$d")
  else 
    d=$(readlink -f "$1")
  fi
  echo "d: $d"
  list="$d"
else
ds="/media/$USER/4TB/images:/data:/media/$USER/4TB/IPFS:/media/$USER/4TB/repos:/home"
n=$(expr "$(date +%s)" % 4 + 1)
echo n: $n
list="$(echo $ds | cut -d':' -f$n)"
fi
echo list: $list

for ddir in $list; do
name=${ddir##*/}
pdir=${ddir%/*}
pname=${pdir##*/}

dbname=$(echo "$pname $name" | tr [:upper:] [:lower:] | sed -e 's/^ *//' -e 's/  */-/g')
echo dbname: $dbname

cachedir=$HOME/.cache/duc
duc index -d $cachedir/${dbname}.db -x $ddir;
duc graph -d $cachedir/${dbname}.db -f svg -o $HOME/Pictures/${dbname}.svg $ddir;
duc gui -d $cachedir/${dbname}.db $ddir;

done
