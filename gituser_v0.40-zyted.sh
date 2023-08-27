#

qm=$(ipfs add -Q -r -n . )
eval $(fullname -a $qm | eyml)
git config user.name "$fullname"
git config user.email $user@healthium.gq

echo "gituser: $(git config user.name) <$(git config user.email)>"

