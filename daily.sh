#

ticns=$(date +%s%N)
echo ticsns: $ticns


# disk usage monitoring
cachedir=$HOME/.cache/duc;
sudo duc index -p -d $cachedir/root.db -x /;
duc graph -d $cachedir/root.db -f svg -o $HOME/Pictures/root.svg /;
mv $HOME/Pictures/root.svg $HOME/Pictures/root-yest.svg
duc graph -d $cachedir/root.db -f png -o $HOME/Pictures/root.png /;

cachedir=$HOME/.cache/duc;
sudo duc index -p -d $cachedir/4TB.db -x /media/michelc/4TB;
duc graph -d $cachedir/4TB.db -f svg -o $HOME/Pictures/4TB.svg /media/michelc/4TB;
mv $HOME/Pictures/4TB.svg $HOME/Pictures/4TB-yest.svg
duc graph -d $cachedir/4TB.db -f png -o $HOME/Pictures/4TB.png /media/michelc/4TB;

cachedir=$HOME/.cache/duc;
sudo duc index -p -d $cachedir/data.db -x /data;
duc graph -d $cachedir/data.db -f svg -o $HOME/Pictures/data.svg /data;
mv $HOME/Pictures/data.svg $HOME/Pictures/data-yest.svg
duc graph -d $cachedir/data.db -f png -o $HOME/Pictures/data.png /;




true

