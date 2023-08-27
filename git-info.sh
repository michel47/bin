#

gitdir=$(git rev-parse --absolute-git-dir)
top=$(git rev-parse --show-toplevel)
if git remote | grep -q origin; then
repo=$(git remote get-url origin | sed -e "s/git@.*\.github\.com:/git@github.com:/");
else
remote=$(git remote | head -1)
if [ "x$remote" != 'x' ]; then
repo=$(git remote get-url $remote);
else
repo=$(git rev-parse --git-dir)
fi
fi
echo gitdir: $gitdir
echo repo: $repo
echo top: $top

committer=$(git config user.name)
eval $(perl -S fullname.pl -a $repo | eyml)

dirname=${top##*/}
echo dirname: $dirname

echo "${repo##*/}; holoGit repository for $dirname by $email (repo: $repo) nid:$nid" | \
cat $gitdir/description - | uniq

