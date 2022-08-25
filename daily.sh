#

echo "start at $(date)"
uptime
ticns=$(date +%s%N)
echo ticsns: $ticns
crontab -l > $HOME/etc/crontab-l.txt

# -----------------------------------------------------
USER=michelc
HOME=/home/$USER
export DISPLAY=:1
export SUDO_ASKPASS="$(which ssh-askpass)"
if false; then sudo -k -A id; fi
key=micheL2GJkWmVJB5RSVi8Rf94mj39FhGT4H8ymQprQB
keypair=/keybase/private/$USER/SOLkeys/$key.json
openssl sha256 -r $keypair
# -----------------------------------------------------
## Safewatch Demo Patient
sh $HOME/repo/keybase/SWPoC/demo/cronjob.sh > $HOME/repo/keybase/SWPoC/demo/cronjob.log 2>&1


# -----------------------------------------------------
if ps -ax | grep -e '\<D[s+]\>'; then
loadok=0
else
  load15=$(cat /proc/loadavg | cut -d' ' -f3)
  echo load15: $load15;
  loadok=$(echo "$load15 < 5" | bc)
fi
# -------------------------

if [ $loadok = 1 ]; then

echo last big files ...
sh $HOME/bin/lastb
tail $HOME/lastb.log

# disk usage monitoring
cachedir=$HOME/.cache/duc;
sudo duc index -p -d $cachedir/root.db -x /;
mv $HOME/Pictures/root-1d.svg $HOME/Pictures/root-2d.svg
mv $HOME/Pictures/root-0d.svg $HOME/Pictures/root-1d.svg
duc graph -d $cachedir/root.db -f svg -o $HOME/Pictures/root-0d.svg /;
duc graph -d $cachedir/root.db -f png -o $HOME/Pictures/root.png /;
build=$(version --build $HOME/Pictures/root-0d.svg)
cp -p $HOME/Pictures/root-0d.svg $cachedir/logs/root-${build}.svg

cachedir=$HOME/.cache/duc;
sudo duc index -p -d $cachedir/4TB.db -x /media/michelc/4TB;
mv $HOME/Pictures/4TB-1d.svg $HOME/Pictures/4TB-2d.svg
mv $HOME/Pictures/4TB-0d.svg $HOME/Pictures/4TB-1d.svg
duc graph -d $cachedir/4TB.db -f svg -o $HOME/Pictures/4TB-0d.svg /media/michelc/4TB;
duc graph -d $cachedir/4TB.db -f png -o $HOME/Pictures/4TB.png /media/michelc/4TB;
build=$(version --build $HOME/Pictures/4TB.svg)
cp -p $HOME/Pictures/4TB-0.svg $cachedir/logs/4TB-${build}.svg

cachedir=$HOME/.cache/duc;
sudo duc index -p -d $cachedir/data.db -x /data;
mv $HOME/Pictures/data-1d.svg $HOME/Pictures/data-2d.svg
mv $HOME/Pictures/data-0d.svg $HOME/Pictures/data-1d.svg
duc graph -d $cachedir/data.db -f svg -o $HOME/Pictures/data-0d.svg /data;
duc graph -d $cachedir/data.db -f png -o $HOME/Pictures/data.png /;

fi
# -----------------------------------------------------


echo "done at $(date)"
true

