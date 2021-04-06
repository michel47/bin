#

hint="$1"
ymlf=${SECURE:-/keybase/private/$USER}/api_keys/$hint.jwt_token.yml
cat $ymlf | json_xs -f yaml -t string -e '$_ = $_->{jwt}'

exit $?
true;
