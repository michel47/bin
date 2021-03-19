#

intent="provide colors"

if echo -n "\e" | grep -q -e 'e'; then
 e="-e" # bash needs a -e !
fi
# colors : [see also](https://en.wikipedia.org/wiki/ANSI_escape_code)
default=$(echo -n $e "\e[39m")
red=$(echo -n $e "\e[31m")
green=$(echo -n $e "\e[1;32m")
yellow=$(echo -n $e "\e[1;33m")
cyan=$(echo -n $e "\e[2;36m")
grey=$(echo -n $e "\e[0;90m")
nc=$(echo -n $e "\e[0m")


if echo "$0" | grep -q -e 'colors'; then
echo "we have ${red}c${green}o${yellow}l${cyan}o${grey}r${nc}s"
fi

true;
