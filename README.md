# bin (my own scripts)

They might be useful for someone else so I open-sourced them.

### the linux BigBang !
Did you know \**nix*time has a beginning and end

* bot = -67768040609740805: Wed, 31 Dec -2147481748 23:59:52 GMT (bigBang!)
* eot = +67767976233316805: Sun, 00 Jan 2147483647 00:00:00 GMTT

 Read more about the odds of unix timeline : [epoch](epoch)

### write everything in binary ...

An other tip, if you want to convert any text into binary
you can simply decode it like if it were base64 encoded
(ok you don't have all the punctuation, but with a tr{+/=}{, .}
you can do a lot)

 check our [ubase64](ubase64)

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

Note version and nextr use "[$ENV{SITE}/lib](../../../site)" libraries (called by [SITE.pm](SITE.pm))
