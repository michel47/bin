# 

if [ "x$1" == 'x' ]; then
url="$(xclip -o)"
echo "url: $url"
else
url="$1"
echo "url: $url"
shift
fi
youtube-dl -r 50K -f 'best[height <=? 360]' -k "$url" $*
