# 
date
USER=michelc
HOME=/home/$USER
kbhome=/run/user/1000/keybase/kbfs/private/$USER
export DISPLAY=:1
#export SUDO_ASKPASS="$(which ssh-askpass)"
export SUDO_ASKPASS=/usr/libexec/seahorse/ssh-askpass
export SUDO_ASKPASS="$kbhome/bin/sudopass.pl"

ticns=$(date +%s%N)
echo ticsns: $ticns
sudo -k -A id


cd $HOME/bin
ip=$(curl -s -4 icanhazip.com)
echo ip: $ip
if echo $ip | grep -q -v '185\.127'; then
echo // sunping
sh sunping.sh > $HOME/var/logs/sunping.log 2>&1
fi
