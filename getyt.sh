# 
youtube-dl -r 50K -f 'best[height <=? 360]' -k "$(clip -o)" "$1"
