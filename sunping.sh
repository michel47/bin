#

tic=$(date +%s%N | cut -c-13)
cachedir=$HOME/.cache/logs
if [ ! -d $cachedir ]; then mkdir $cachedir; fi
echo $tic: $(date)
ping -D -A -W 3 -c 23 sunrise.com | tee -a $cachedir/sunping.log 2>&1 
echo -n "status: $?" >> $cachedir/sunping.log
ping -D -A -W 3 -c 19 www.linkedin.com
echo -n " $?" >> $cachedir/sunping.log
ping -D -A -W 3 -c 17 gist.github.com
echo -n " $?" >> $cachedir/sunping.log
ping -D -A -W 3 -c 13 google.com
echo -n " $?" >> $cachedir/sunping.log
ping -D -A -W 3 -c 11 gateway.ipfs.io
echo -n " $?" >> $cachedir/sunping.log
ping -D -A -W 3 -c 7 opentimestamps.org
echo  " $?." >> $cachedir/sunping.log
echo .

#env DISPLAY=:0 firefox https://gist.github.com

exit $?
true;
