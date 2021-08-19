<!--
[![blockRing™](https://cdn.statically.io/gh/iglake/dir-index-html/master/gw-assets/logo.png)](http://blockringtm.gq)
[![blockRing™](https://cdn.statically.io/img/github.com/iglake/dir-index-html/raw/master/gw-assets/logo.png)
[![logo](https://cdn.jsdelivr.net/gh/iglake/dir-index-html@master/gw-assets/logo.png)](//blockring™.gq)
[![bring](https://img.shields.io/badge/project-blockRingTM-darkgreen.svg?style=flat-square&logoColor=gold&logo=CodeSandbox)](http://blockRing™.ml/)
[![markdown](https://img.shields.io/badge/format-markdown-ffaabb.svg?style=flat-square&logo=Markdown&logoColor=ffaabb)](http://markdown.org)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)
<img style="opacity=0.8;" src=https://data.jsdelivr.com/v1/package/gh/iglake/dir-index.html/badge?style=flat-square></a>
-----
-->

# bin (my own scripts)

They might be useful for someone else so I open-sourced them.

### the linux BigBang !
Did you know \**nix*time has a beginning and end

* bot = -67768040609740805: Wed, 31 Dec -2147481748 23:59:52 GMT (bigBang!)
* eot = +67767976233316805: Sun, 00 Jan 2147483647 00:00:00 GMTT

 Read more about the odds of unix timeline : [epoch](epoch)

---
### write everything in binary ...

An other tip, if you want to convert any text into binary
you can simply decode it like if it were base64 encoded
(ok you don't have all the punctuation, but with a tr{+/=}{, .}
you can do a lot)

 check our [ubase64](ubase64)

---
### post a note to the world

the script "post" let you publish a note on the *(inter)*net and gives you a link
to share it on social media, it will open your favorite [$EDITOR][vi] for you
to write a full note in [markdown][md] format.

usage:

 post "note summary"

![vi](https://img.shields.io/badge/made_w/-♡-red.svg?style=flat-square&logo=Vim)

[vi]: {{DUCK}}=!g+favorite+editor+gvim
[md]: {{DUCK}}=!g+markdown


---
### hash with shake-224

The script [sk224](sk224) is computing the shake256-224 of the standard-input
and display the result in hex, base32, base58 (flickr)


---
### version nextr, & sched

in order to commit to regular releases, I use a time based versioning convention
so it is not really [SemVer](https://semver.org/) unless you do
* a MAJOR release every 10 weeks
* a MINOR release every week
* and a PATCH every 2 days or so

Also you might want to do development releases on Wednesday and Saturday
in order to have odd release number :smiley:

- [version](version) prints out the current file version and the next scheduled one
- [nextr](nextr) gives you the date and version of the next release
- [sched](sched) indicates the next 5 days versions

Note version and nextr use "[$ENV{SITE}/lib](https://github.com/michel47/site)" libraries (called by [SITE.pm](SITE.pm))

---
### xyml

this script might be useful to extract a particular value from a [YAML][yml] hash-table
it take the yml serialized data as its STDIN and output the keys that are passed in arguments.

example : 
```
cat <<EOY | xyml item3 item1
--- # ymldata
item1: value1
item2: value2
item3: value3
...
EOY
```
[yml]: http://duckduckgo.com/?q=YAML


---
### mhash

a script to quickly compute a multihash of a typed-in string,
3 parameters :

- the choice of the algorithm
- the number of iteration
- the length of the result

base 16,32,58,64 supported

example:

echo '3.14159265358979' | mhash

```
// algo: (MD5^1)-128-128 (24B)
h16: 5c9ff9f4ec09c14c1e1331dd81d0c92c0000000000000000
h64: XJ/59OwJwUweEzHdgdDJLAAAAAAAAAAA
mh16: fd5185c9ff9f4ec09c14c1e1331dd81d0c92c0000000000000000
mh32: bAEW5KGC4T747J3AJYFGB4EZR3WA5BSJMAAAAAAAAAAAAA
mh58: zoCcizrfM9uzsVTwYkeyAsP1hPVfSzPFifr5hy

```

### note

a way to publish a note on the wide-web, by publishing
a single page website .
(requires xyml and version available [here](http://cloudflare-ipfs.com/ipfs/QmRDETuZnXUgh4gLB796Vn24yjWA3sviRbzJPWeaqLqLvk))

``usage: note``


<!--
try to think CI !

https://circleci.com/pricing/

-->
