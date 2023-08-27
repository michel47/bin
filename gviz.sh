#


file="${1:-merkle.dot}"
name=${file%.*};
set -x


twopi -Tsvg -o ${name}_twopi.svg $file
eog ${name}_twopi.svg &

neato -Tsvg -o ${name}_neato.svg $file
sfdp -Tsvg -o ${name}_sfdp.svg $file

circo -Tsvg -o ${name}_circo.svg $file

fdp -Tsvg -o ${name}_fdp.svg $file

dot -Tdot -o ${name}_dot.dot $file
dot -Tsvg -o ${name}_dot.svg $file


if false; then
sed -e 's/->/--/' -e 's/digraph/graph/' $file > ${name}_ung.dot;
patchwork -Tpng -o ${name}_patchwork.png ${name}_ung.dot
osage -Tpng -o ${name}_osage.png ${name}_ung.dot
rm ${name}_ung.dot
fi

exit $?;
true;
