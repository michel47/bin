# 
date
USER=michelc
HOME=/home/$USER
kbhome=/run/user/1000/keybase/kbfs/private/$USER
export DISPLAY=:1
#export SUDO_ASKPASS="$(which ssh-askpass)"
export SUDO_ASKPASS=/usr/libexec/seahorse/ssh-askpass
if [ -e "$kbhome/bin" ]; then
export SUDO_ASKPASS="$kbhome/bin/sudopass.pl"
fi
espeak -v f3 "I love you Me shell"

temp=$(sensors -u | grep 'temp.*_in' | sort -n +1 | tail -1 | cut -d' ' -f4)


ticns=$(date +%s%N)
echo ticsns: $ticns
sudo -k -A id


cd $HOME/bin
ip=$(curl -s -4 icanhazip.com)
echo ip: $ip
echo $ticns $ip $temp >> $HOME/.local/share/logs/often.log

if echo $ip | grep -q -v '185\.127'; then
echo // sunping
sh sunping.sh > $HOME/var/logs/sunping.log 2>&1
fi
