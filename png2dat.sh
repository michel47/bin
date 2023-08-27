#

file="${1:-in.png}"


convert $file ppm:- | tail +4 > out.dat
if file out.dat | grep -q -e zlib; then
pigz -d -c -k out.dat | xxd | head -2
else 
cat out.dat | xxd | head -3
fi
