#

file="${1%.*}"
pandoc -f markdown -t pdf -o "$file.pdf" "$@"
