#

# intent peg on BTC,ETH,AION
# see also: https://my.originstamp.com/my/api/create-timestamp
# 5 stamp per month == ~1/week

hash="$1"; shift
if [ -e "$hash" ]; then
  hash=$(openssl sha256 -r $hash | cut -d' ' -f1)
  echo hash: $hash
fi

tic=$(date +%s%N | cut -c-13)
local=$HOME/.local/share/originstamp
if [ ! -e "$local/originstamp.yml" ]; then
echo "--- # originstamp $date" > $local/originstamp.yml
fi
echo $tic: $hash >> $local/originstamp.yml
hash=$(openssl sha256 -r $local/originstamp.yml | cut -d' ' -f1)
qm=$(ipfs add -w $local/originstamp.yml -Q)
echo $tic: $qm >> $local/qm.log

credit=$(perl -S get_rate_balance.pl originstamp)
if [ $credit \> 0 ]; then
api_url=$(get_keys.sh originstamp_api.keys api_url)
API_KEY=$(get_keys.sh originstamp_api.keys api_key)
#echo API_KEY=$API_KEY
comment="$@"
json=$(echo "{'comment':'$comment','hash':'$hash'}"|sed -e "s/'/\"/g")
echo json: $json
curl -X POST "$api_url/v3/timestamp/create"\
     -H "Content-Type: application/json"\
     -H "Authorization: $API_KEY"\
     -d $json

rm $local/originstamp.yml

fi


exit $?;

true;
