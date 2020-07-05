#

tag="$*"
export IPFS_PATH=${IPFS_PATH:-/media/IPFS/SELF}
echo "--- # $0"
echo "tag: \"$tag\""
browser=" - Brave"
#wmctrl -a $browser

WID=$(xdotool search --name "$browser" | tail -1)
echo "WID: $WID"
name="$(xdotool getwindowname $WID)"
echo "$WID: $name"
xdotool windowfocus $WID 
xdotool getmouselocation --shell | sed -e 's/=/: /'
# see [*](https://support.brave.com/hc/en-us/articles/360032272171-What-keyboard-shortcuts-can-I-use-in-Brave-)
#xdotool key "Alt+Tab"
xdotool key "alt+d"
xdotool key "ctrl+l"
xdotool key "ctrl+a"
#xdotool Click 3
xdotool key "ctrl+c"
url=$(clipit -c)
echo "URL: $url"

tic=$(date +%s)
ip=$(curl -s https://dyn℠.ml/cgi-bin/remote_addr.pl)
echo ip: $ip


main(){

peerid=$(ipms config Identity.PeerID)
echo peerid: $peerid

eval "$(perl -S contkey.pl $url | eyml)"

cat >/tmp/useen.yml <<EOF
--- # seen url ...
name: "$name"
tag: "$tag"
url: $url
tic: $tic
ip: $ip
peerid: "$peerid"
EOF
cat >/tmp/useen.url <<EOF
[InternetShortcut]
URL="$url"
MEMO="$tag"
EOF
cat >/tmp/useen.htm <<EOF
<!DOCTYPE html>
<title>$tag ~ $name</title>
<h2>$tag</h2><i>$name</i>
<p>REDIRECT : URL=<a href="$url">$url</a></p> ($WID)
<iframe src="$url"></iframe>
--&nbsp;<br>
$tic: $peerid\@$ip 
EOF
cat >$HOME/seen/useen.desktop <<EOF
[Desktop Entry]
Version=1.0
StartupNotify=true
GenericName=$tag
Name=$name
Icon=/mnt/usb/images/icons/useen.png
Comment=$WID, $tag
Exec=xdg-open $url
URL=$url
Type=Link
Teminal=false
X-ip=$ip
X-tic=$tic
X-peerid=$peerid
Categories=bookmark;Network;
EOF

qm=$(ipfs add -Q -w /tmp/useen.htm $HOME/seen/useen.desktop /tmp/useen.yml /tmp/useen.url)
rm -rf /tmp/useen.yml
echo "qm: $qm"
if ! ipfs files stat --hash /var/seen 1>/dev/null; then
ipfs files mkdir -p /var/seen
fi
if ipfs files rm -r /var/seen/url 2>/dev/null; then true; fi
ipfs files cp /ipfs/$qm /var/seen/url
ipfsappend /var/seen/urls.log "$tic: $qm; $tag"

echo url: https://gateway.ipfs.io/ipfs/$qm;

}

ipfsappend(){
   file="$1"
   string="$2"
   tmpf=/tmp/${file##*/}
   mdir=${file%/*}
   if ! ipms files stat --hash $mdir 1>/dev/null 2>&1; then
      ipms files mkdir -p $mdir
   fi
   if prev=$(ipms files stat --hash ${file} 2>/dev/null); then
      echo prev: $prev
      sz=$(ipms files stat --format="<size>" ${file} 2>/dev/null)
      echo size: $sz
      ipms files read "${file}" | sed -e "s/\$Previous: .*\$/\$Previous: $prev\$/" > $tmpf
      echo "$string" >> $tmpf
      ipms files write --create "${file}" < $tmpf
   else 
      genesis=z83ajSANGx6FnQqFaaELyCGFFtrxZKM3C
      ipms files write --create --raw-leaves "${file}" <<EOF
--- # blockRing for ${file##*/}
# \$Source: ${file}$
# \$Author: ${peerid}$
# \$Previous: ${genesis}$
$string
EOF
   fi
   qm=$(ipfs files stat --hash ${file})
   echo log: $qm

   rm -f $tmpf
}
  
main $@
exit $?

