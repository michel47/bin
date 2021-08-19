#


file=${1:-i.png}
bname=${file%.png}
convert $file -magnify -magnify $bname-4x.png
convert $file -magnify -magnify -magnify -magnify $bname-16x.png
convert $file -magnify -magnify -magnify -magnify -magnify $bname-32x.png
convert $file -magnify -magnify -magnify -magnify -magnify -magnify $bname-64x.png
