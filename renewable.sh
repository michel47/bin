#

# intent:
#  give a reminder for renewable
#  heliohost for instance

echo "--- # ${0##*/}"
yd=$(date +%j);

# ------------------------------------------------
echo "yd: $yd"
# once every 29 days :
m=$(expr $yd % 29)
echo "m: $m";

if [ $m = 0 ]; then
  echo reminder
  firefox https://www.heliohost.org/renew/
fi
# ------------------------------------------------
# every 180 days
m=$(expr $yd % 179)
if [ $m = 0 ]; then
  echo 6 months have passed
fi

# ------------------------------------------------


ip=$(curl -s http://dyn℠.ml/cgi-bin/remote_addr.pl | head -1)
if echo "$ip" | grep -q -P '\d+\.\d+\.\d+\.\d+'; then
echo ip: $ip
else
echo "ip: broken ($ip)"
fi

exit $?

true; # $Source: /my/shell/scripts/renewable.sh $
