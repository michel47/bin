#

# intent:
#   use arbtt to track attention givent to projects

export PATH=$HOME/.../ipfs/bin:$HOME/repo/gitea/bin:$PATH

logd=$HOME/.local/share/logs
cd $logd

gitid=$(git rev-parse HEAD)
tic=$(date +%s%N|cut -c-13)
echo $tic: $gitid >> gitid.log
echo "--- # ${0##*/}"
date=$(date)
echo date: $date
# -----------------------------------------------
# previously:
echo gitid: $gitid
rm -f qm.log.ots.bak
ots upgrade qm.log.ots
git add qm.log qm.log.ots
git commit -uno -m "stamped: $(tail -1 qm.log)"
# -----------------------------------------------
arbtt-stats  --filter='$date>='`date +"%Y-%m-%d"` > arbtt-today.csv
arbtt-stats -x Recreation --output-format csv --for-each day > arbtt-day.csv
arbtt-stats -x Recreation --output-format csv --for-each month > arbtt-month.csv
qm=$(ipfs add -r . -Q --progress=false)
tic=$(date +%s%N|cut -c-13)
echo $tic: $qm >> qm.log
echo $tic: $qm
rm -f qm.log.ots
ots stamp qm.log
git add qm.log qm.log.ots
git add gitid.log
git add *.csv
git add *.yml
git add *.ots
git add arbtt*
gituser
git commit -a -m "tracked on $date"

gitid=$(git rev-parse HEAD)
echo new-gitid: $gitid

echo '...'
exit $?
true;
