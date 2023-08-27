#

commitid=$(git rev-parse --short HEAD)
echo commitid: $commitid
gitid=$(git rev-parse HEAD)
shard=$(echo $gitid | cut -c-2)
objf=$(echo $gitid | cut -c3-)

gitdir=$(git rev-parse --absolute-git-dir)
objf=$gitdir/objects/$shard/$objf
pigz -z -d -c $objf | cat -v
pigz -z -d -c $objf | openssl sha1 -r 

git commit --amend "new commit $commitid"
