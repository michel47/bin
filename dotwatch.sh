#

dot="$1"
while true; do
  if ifchanged $dot; then
    dot -Tpng -o PNGs/${dot%.*}.png $dot
    dot -Tsvg -o ${dot%.*}.svg $dot
  fi
  sleep 3;
done
