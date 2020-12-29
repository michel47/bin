#

echo "--- # ${0##*/} $*"
# log the birth date for a file !
file="$1"
bname="${file##*/}"
locate $bname | sed -e 's/^/loc: /'
stat -t $file | sed -e 's/^/stat: /'
echo dev: $(stat -c %D $file)
device=$(df $file | tail -1 | cut -d' ' -f 1)
echo device: $device
in=$(stat -c %i $file)
echo inode: $in
if which debugfs 1>/dev/null; then
sudo debugfs -R "stat <$in>" $device | cat -
fi
if which birth 1>/dev/null; then
crt=$(birth $file)
else
crt=$(sudo debugfs -R "stat <$in>" $device 2>/dev/null | grep -oP 'crtime:\s*\K.*')
fi
echo crt: $crt

true; # $Source: /my/shell/script/birth.sh
