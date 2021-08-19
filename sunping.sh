#

s=1
export PATH=$PATH:$HOME/.../ipfs/bin
tic=$(date +%s%N | cut -c-13)
cachedir=$HOME/.cache/logs
if [ ! -d $cachedir ]; then mkdir $cachedir; fi
echo $tic: $(date)
echo "my internet is down" | ipfs add --raw-leaves -pin=true --progress=false --cid-base base58btc
#ipfs dht provide QmVS6qA5AYu5d5yVc1uKALJbSGcHZtqUCLMy4UeUR5mU4p &
ipfs dht provide zb2rhaAgAM19HByZSiSENFsG5Bz9bAScvXZmobJ5XnJieoshc &
#exit;

# ping measurements :
ping -D -A -W 3 -c 29 74.208.236.102 >> $cachedir/sunping.log || s=0
echo -n "$tic: status=$?" >> $cachedir/sunstatus.log
ping -D -A -W 3 -c 23 sunrise.com >> $cachedir/sunping.log || s=0
echo -n " $?" >> $cachedir/sunstatus.log
ping -D -A -W 3 -c 19 4.2.2.1 || s=0
echo -n " $?" >> $cachedir/sunstatus.log
ping -D -A -W 3 -c 17 www.linkedin.com || s=0
echo -n " $?" >> $cachedir/sunstatus.log
ping -D -A -W 3 -c 13 gist.github.com || s=0
echo -n " $?" >> $cachedir/sunstatus.log
ping -D -A -W 3 -c 11 google.com || s=0
echo -n " $?" >> $cachedir/sunstatus.log
ping -D -A -W 3 -c 7 gateway.ipfs.io || s=0
echo -n " $?" >> $cachedir/sunstatus.log
ping -D -A -W 3 -c 5 opentimestamps.org || s=0
echo -n " $?" >> $cachedir/sunstatus.log
ping -D -A -W 3 -c 3 opensea.io && s=1
echo  " $?." >> $cachedir/sunstatus.log
p=$(cat $cachedir/sunstatus.txt)
echo $s > $cachedir/sunstatus.txt
echo "$p->$s."

if [ "$s" = '0' -a "$p" != '0' ]; then
echo "My Internet down again" > /home/michelc/.ipfs/blocks/ED/AFKREIBULR2LB6AUY75KCVPVL6L7EWGWQ2YBY4EE4AOXTHNZ5VSGYFYEDM.data
qm=$(ipfs add -w --pin=false $cachedir/sun*.log -Q)
#env DISPLAY=:0 firefox http://localhost:8390/ipfs/$qm/sunstatus.log
ping -c 1 gateway.ipfs.io 1>/dev/null
ping -c 1 wepik.com 1>/dev/null
ping -c 1 nft.storage 1>/dev/null
ping -c 1 na-west1.surge.sh 1>/dev/null
ping -c 1 michelc.netlify.com 1>/dev/null
ping -c 1 freepikcompany.com 1>/dev/null
# echo "Your Internet is DOWN" | ipfs add
#env DISPLAY=:0 firefox --new-tab http://localhost:8390/ipfs/Qmaq9GJrmJdMPxo9ThC8NRk6zjQkPUyZKcNC1uYhBHDPVb
espeak "internet is down";
fi
if [ "$s" = '1' -a "$p" = '0' ]; then
ipfs dht findprovs -n 1 zb2rhaAgAM19HByZSiSENFsG5Bz9bAScvXZmobJ5XnJieoshc
echo "My internet is UP!" > /home/michelc/.ipfs/blocks/ED/AFKREIBULR2LB6AUY75KCVPVL6L7EWGWQ2YBY4EE4AOXTHNZ5VSGYFYEDM.data
curl -4 https://icanhazip.com
echo "Your internet connection is back UP" | ipfs add
#env DISPLAY=:0 firefox http://gateway.ipfs.io/ipfs/QmbbMRJJyuNdPniaCmgqFiNR5CBm17Kd8AMsC1SFzUwTVr
#env DISPLAY=:0 firefox http://localhost:8390/ipfs/zb2rhaAgAM19HByZSiSENFsG5Bz9bAScvXZmobJ5XnJieoshc
#env DISPLAY=:0 firefox https://ipfs.blockringtm.ml/ipfs/zb2rhaAgAM19HByZSiSENFsG5Bz9bAScvXZmobJ5XnJieoshc
espeak "internet is downr";
fi

exit $?
true;
