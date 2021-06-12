#

if grep -q -e "$1:.*:$2" /keybase/private/$USER/etc/shadow ; then
 pass=$(grep -e "$1:.*:$2" /keybase/private/$USER/etc/shadow | cut -d: -f2) 
 if echo "$-" | grep -q i; then # interactive
  echo interactive
 fi
 if [ -t 1 ] ; then # test if output is a tty
  echo "pass: ******"
 else
 echo "pass: $pass"
 fi
 
fi

