#

echo "--- # ${0##*/} $*"
# log the birth date for a file !
file="$1"

locate $file | sed -e 's/^/loc: /'
stat -t $file | sed -e 's/^/stat: /'
echo dev: $(stat -c %D $file)
device=$(df $file | tail -1 | cut -d' ' -f 1)
echo device: $device
in=$(stat -c %i $file)
sudo debugfs -R "stat <$in>" $device | cat -
crt=$(sudo debugfs -R "stat <$in>" $device 2>/dev/null | grep crtime)
echo $crt

true; # $Source: /my/shell/script/birth.sh
