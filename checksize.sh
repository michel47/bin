#

# indent: check size of disks and create duc charts ...

ls -l $HOME/Pictures/*.svg

if [ -d "$1" ]; then
  if ! echo "$1" | grep -q '^/'; then
    d="$(pwd -P)/$1"
    d=$(relink -f "$d")
  else 
    d=$(relink -f "$1")
  fi
  list="$d"
fi
list="/media/$USER/4TB/images /data /media/$USER/4TB/IPFS /media/$USER/4TB/repos /home"


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
