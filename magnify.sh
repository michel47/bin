#


file=${1:-i.png}
if [ -e $file ]; then
  mag=16
else
if [ "$1" != '' ]; then
  mag=$1
  shift
  file=${1:-i.png}
else # default
  mag=4
  file=i.png
fi

fi
bname=${file%.png}
shift
convert $file -magnify -magnify $bname-4x.png
convert $file -magnify -magnify -magnify -magnify $bname-${mag}x.png
#convert $file -magnify -magnify -magnify -magnify -magnify $bname-32x.png
#convert $file -magnify -magnify -magnify -magnify -magnify -magnify $bname-64x.png
