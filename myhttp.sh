#! /bin/bash

trap 'rm -f $pipe;exit' INT QUIT TERM

WEB="./web"
ERROR="./error"
LOG="./log"
PORT=9877

STATUS_CODE=(
    [200]="OK"
    [400]="Bad Request"
    [403]="Forbidden"
    [404]="Not Found"
    [405]="Method Not Allowed"
    [500]="Internal Server Error"
)

send() {
    echo "HTTP/1.1 $1 ${STATUS_CODE[$1]}"
    echo "Date: $(date --rfc-2822)"
    echo "Server: Bash Server for FUN"

    case "$2" in
    *.sh)   bash "$2" "$3";;
    *.py)   python "$2" "$3";;
    #ruby,perl,python,php...etc
    *)      echo "Content-Type: $(file -b --mime-type "$2")"
#            echo "Content-Length: $(stat -c'%s' "$2")"
            echo
            cat $2;;
    esac
    exit
}

test_file() {
    local idx

    [ ! -r "$1" ] && send 404 "$ERROR"/404.html
    [ -f "$1" ] && send 200 "$1" "$2"
    [ -d "$1" ] &&
    idx=`find "$1" -maxdepth 1 -type f -name index.* -perm -444 | head -1` &&
    [ "$idx" ] && send 200 "$idx" "$2"
    send 404 "$ERROR"/404.html
}

main() {
    local line METHOD URI VERSION URItmp ARGS

    read -r METHOD URI VERSION
    [ "$METHOD" = "GET" ] || send 405 "$ERROR"/405.html
    [ "$URI" ] || send 400 "$ERROR"/400.html
    echo "`date +%T`    $URI" >> "$LOG"/`date +%Y%m%d`

    URItmp=(${URI//\?/ })
    URI="$WEB${URItmp[0]}"
    [ "${URItmp[1]}" ] && ARGS="${URItmp[1]//\&/ }" &&
    ARGS="`echo -e $(sed 's/%/\\\x/g'<<<"$ARGS")`"
    URI="`echo -e $(sed 's/%/\\\x/g'<<<"$URI")`"

    while read -r line
    do  [ "${line%%$'\r'}" ] || break
    done

    test_file "$URI" "$ARGS"
}

pipe=`mktemp /tmp/baws.XXXXXXnc`
rm -f $pipe
mkfifo $pipe

while :
do  main < $pipe 2>&1 | nc -l $PORT > $pipe
done
