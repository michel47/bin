#

origin="Michel C."

cachedir=${XDG_CACHE_HOME:-$HOME/.cache}
script=${0##*/}
pgm=${script%.*}


qm=shift
date=$(date)
tic=$(date +%s%N | cut -c-13)
ip=$(curl -s -4 icanhazip.com)
echo $tic: $qm
cat <<EOT > statement.md
---
tic: $tic
dotip: $ip
qm: $qm
---
## stampement

I undersign $origin, attest the existance
the document whose hash is $qm (base58 SHA256)

-- $date @$ip
$origin
EOT
ipfs add statement.md
hash=$(openssl sha256 -r statement.md)
otid=$(echo $hash | cut -c-12)
echo otid: $otid
mv statement.md $cachedir/$pgm/statement-$otid.md
ots stamp $cachedir/$pgm/statement-$otid.md

