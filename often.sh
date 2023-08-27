# 
date
USER=michelc
HOME=/home/$USER
export DISPLAY=:1
export SUDO_ASKPASS="$(which ssh-askpass)"
sudo -A id


sudo pactl set-default-sink 0
echo "testing speak ?"
espeak -a 10 -s 120 -v f5 "I love you Me shell" ||

espeak -a 20 -v m3 "and using aplay" | aplay -D hw:1,0 2>/dev/null
#echo "testing aplay ?"


echo "temp ?"
temp=$(sensors -u | grep 'temp.*_in' | sort -n +1 | tail -1 | cut -c16-40)
echo temp: $temp

ticns=$(date +%s%N)
echo ticsns: $ticns

whoiam=$(keybase whoami 2>/dev/null)
uid=$(id -u $whoami)
KBFS_PATH=/run/user/$uid/keybase/kbfs
if [ -e "$KBFS_PATH/private/$USER/bin" ]; then
export SUDO_ASKPASS="$KBFS_PATH/private/$USER/bin/sudopass.pl"
else
#export SUDO_ASKPASS="$(which ssh-askpass)"
export SUDO_ASKPASS=/usr/libexec/seahorse/ssh-askpass
fi
# -k -A: reset timestamp and ask
sudo -k -A id

echo "sudo espeak ?"
sudo -A espeak "I love you Me shell"

export PATH=$HOME/bin:$PATH

ip=$(curl -s -4 icanhazip.com)
echo ip: $ip
echo $ticns $ip $temp >> $HOME/.local/share/logs/often.log

if echo $ip | grep -q -v '185\.127'; then
echo // sunping
sunping.sh > $HOME/var/logs/sunping.log 2>&1
tail -3 $HOME/var/logs/sunping.log
echo .
fi
