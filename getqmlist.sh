#

set -e

cat qm.log | while read line; do
#echo line: $line
qm=$(echo $line | cut -d' ' -f 2)
echo qm: $qm
ipfs ls /ipfs/$qm | tee -a qmlist.loq
done
