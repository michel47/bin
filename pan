#

# publish a note ...
qmset='QmXgazJVyNRBy8U26WGYbnM5X16wMNoGp4WJrBPWQHR2U1'
dir=pan11248;
if ! test -d $dir; then
ipfs get $qmset -o $dir
fi
file="$1"
bname=${file%.*}
perl -S moustache.pl $dir/default.html $dir/default.htm~
perl -S moustache.pl $file $bname.md~
pandoc -t html -f markdown --template=$dir/default.htm~ -o $bname.htm~ $bname.md~
cp -p $bname.md~ $dir/$bname.md
cp -p $bname.htm~ $dir/index.html
qm=$(ipfs add -Q -r $dir)

echo http://127.0.0.1:8080/ipfs/$qm
echo http://yoogle.com:8080/ipfs/$qm
echo https://cloudflare-ipfs.com/ipfs/$qm
echo https://ipfs.blockringtm.ml/ipfs/$qm
xdg-open $dir/index.html
#curl -I https://ipfs.blockringtm.ml/ipfs/$qm &
sleep 1; rm -rf $dir/
#rm $bname.*~

