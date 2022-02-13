#

tic=$(date +%s)
ip=$(curl -s https://postman-echo.com/ip?format=text)
peerid=$(ipfs config Identity.PeerID)
gitid=$(git rev-parse --short HEAD)
commitid=$(git rev-parse HEAD)
if ! test -e gittrail.yml; then echo "--- # git commit trail" > gittrail.yml; fi
echo $tic,$ip: $commitid >> gittrail.yml
git add gittrail.yml
echo "commitid: $commitid"
if test -e _data/commit.yml; then
sed -i -e "s,gitid: .*,gitid: $gitid," _data/commit.yml
git add _data/commit.yml
fi
if test -e _data/ipfs.yml; then
  qm=$(ipfs add -Q -w -r _data $0 gittrail.yml)
  sed -i -e "s,qmtrail: .*,qmtrail: $qm," _data/ipfs.yml
  git add _data/ipfs.yml
else
  qm=$(ipfs add -Q -w $0 gittrail.yml)
fi
url=https://ipfs.io/ipfs/$qm
echo url: $url
if test -e gittrail.desktop; then
cat >gittrail.desktop <<EOF
[Desktop Entry]
Version=1.0
StartupNotify=true
GenericName=GitTrail
Name=gittrail
Icon=/mnt/usb/images/icons/gittrail.png
Comment=$commitid, $qm
Exec=xdg-open "https://ipfs.io/ipfs/$qm"
URL=$url
Type=Link
Teminal=false
X-ip=$ip
X-tic=$tic
X-peerid=$peerid
Categories=logs;Network;
EOF

fi
