#

tic=$(date +%s)
dj=$(date +%j)
ww=$(date +%W)
yest=$(expr $tic / 86400 \* 86400 )
top=$(git rev-parse --show-toplevel)
echo "--- # standup log for D$dj (W$ww)"
echo "please add record w/o '* ' ..."
echo "--- # standup log for D$dj (W$ww) ~~ wawoi.sh" > $top/_data/standup.yml
tail -4 $top/_data/journal.yml
echo "# $(date +%d) D$dj (W$ww)" >> $top/_data/journal.yml
echo "What I did yesterday ?"
while read i; do
if [ "x$i" = 'x' ]; then break; fi
echo "* $i"
echo "$yest: $i" >> $top/_data/standup.yml
echo "$yest: $i" >> $top/_data/journal.yml
done
echo "What I plan to do today ?"
while read i; do
if [ "x$i" = 'x' ]; then break; fi
echo "* $i"
echo "$tic: $i" >> $top/_data/standup.yml
echo "$tic: $i" >> $top/_data/journal.yml
done
echo "any refs ?"
echo "please add record in yaml format ({key}: {url})"
while read r; do
if [ "x$r" = 'x' ]; then break; fi
echo "$r"
echo "$r" >> $top/_data/refs.yml
done

git add $top/_data
