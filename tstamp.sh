#

cachedir=${XDG_CACHE_HOME:-$HOME/.cache}
stamplogf=$cachedir/logs/stamplogf.yml

file="$1"

if changed "$file"; then
 tic=$(date +%s%N)
 sha=$(openssl sha256 -r "$file" | cut -d' ' -f1)
 otsid=$(echo $sha | cut -c-12)
 echo otsid: $otsid
 echo $tic: $otsid >> $stamplogf
 mv -f "$file.ots" "$file.prev.ots"
 ots stamp $file
else
 if [ -e "$file.ots" ]; then
   mv "$file" "$file.pending"
   mv "$file.ots" "$file.pending.ots"
 fi
fi
if [ -e "$file.pending.ots" ]; then
   if ots upgrade "$file.pending.ots"; then
     hash=$(ots info "$file.pending.ots" | grep -e hash: | cut -d' ' -f4)
     echo "commitment: $hash"
     otsid=$(echo $hash | cut -c-12)
     mv "$file.pending.ots" "$file.${otsid}-complete.ots"
     cp -p "$file.${otsid}-complete.ots" "$HOME/.local/share/ots/stamps/complete/$file.$otsid.ots"
     tsid==$(openssl sha256 -r "$file.pending" | cut -c-12)
     mv "$file.pending" "$file.${tsid}-complete"
   fi
fi
