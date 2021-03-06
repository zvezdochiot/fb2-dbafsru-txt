#!/bin/sh

#fb2toinfo.sh
#Depends: dash, sed, file, unzip, zcat

sname="Fb2toauthor"
sversion="0.20180813"

echo "$sname $sversion" >&2

tnocomp=""
tcomp="sed"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="file"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="unzip"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
tcomp="gzip"
[ ! "$(command -v $tcomp)" ] && tnocomp="$tnocomp $tcomp"
if [ "+$tnocomp" != "+" ]
then
    echo "Not found:${tnocomp}!" >&2
    echo "" >&2
    exit 1
fi

fzip="false"
fhlp="false"
while getopts ":o:zh" opt
do
    case $opt in
        o) dst="$OPTARG"
            ;;
        h) fhlp="true"
            ;;
        z) fzip="true"
            ;;
        *) echo "Unknown option -$OPTARG"
            exit 1
            ;;
    esac
done
shift "$(($OPTIND - 1))"
src="$1";

if [ "x$src" = "x" -o "x$fhlp" = "xtrue" ]
then
    echo "Usage:"
    echo "$0 [options] book.fb2"
    echo "Options:"
    echo "    -o name.txt    name text file (default = stdout)"
    echo "    -z             force unzip (default = false)"
    echo "    -h             help"
    exit 0
fi

if [ ! -f "$src" ]
then
    echo "Not found $src!" >&2
    exit 1
fi

if [ "x$src" = "x$dst" ]
then
    dst="$dst.txt"
fi

fcompr=$(file -b -i  "$src")
[ "x$fzip" = "xtrue" ] && fcompr="application/zip; charset=binary"

if [ "x$fcompr" = "xapplication/zip; charset=binary" ]
then
    tauth=$(unzip -c "$src" | sed -n -e '/<description/,/<\/description>/p' | sed -n -e '/<title-info>/,/<\/title-info>/p' | sed -e 's/\x0D$//' | sed -n -e '/<author>/,/<\/author>/p' | sed -e 's/<author>//;s/<\/author>/ /' | sed -e :a -e '/>$/N; s/\n//; ta' | sed -e '/^ *$/d;' | sed -e 's/\(^.*\)\(<last-name>.*<\/last-name>\)/\2\1/' | sed -e 's/> *</></g')
else
    tauth=$(gzip -cdf "$src" | sed -n -e '/<description/,/<\/description>/p' | sed -n -e '/<title-info>/,/<\/title-info>/p' | sed -e 's/\x0D$//' | sed -n -e '/<author>/,/<\/author>/p' | sed -e 's/<author>//;s/<\/author>/ /' | sed -e :a -e '/>$/N; s/\n//; ta' | sed -e '/^ *$/d;' | sed -e 's/\(^.*\)\(<last-name>.*<\/last-name>\)/\2\1/' | sed -e 's/> *</></g')
fi
tauth=$(echo "$tauth" | sed -e 's/<[^>]*>/ /g' | sed -e 's/^ *//g;s/ *$//g;s/  / /g;')
if [ -z "$dst" ]
then
    echo "$tauth"
else
    echo "$tauth" > "$dst"
fi
