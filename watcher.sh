#!/bin/bash

rerun="no"

thedir() {
    d="$(dirname $0)"
    [ -z "$d" ] && realpath .
    realpath "${d}/"
}

thewait() {
    echo -n "=> Waiting for updates... "
    file="$(fswatch -1  --event Updated "$(thedir)/src/cv."{css,xsl,xml} "${0}")"
    (echo "${file}" | grep "$(basename "${0}")\$" > /dev/null 2>&1) && rerun="yes"
    echo "${file}"
    return 0
}

trap "brk=yes" int

while thewait; do
    if [ "${rerun}" == "yes" ]; then
        echo "=> Reloading watcher"
        bash "$0" "$@"
        exit $?
    fi

    [ "${brk}" == "yes" ] && break

    for l in es en; do
        echo "==> Processing language: $l"

        echo "===> Generating HTML..."
        saxonb-xslt "-o:$(thedir)/dist/cv.$l.html" "-s:$(thedir)/src/cv.xml" "-xsl:$(thedir)/src/cv.xsl" "lang=$l"

        echo "===> Generating PDF..."
        if [ ! -f ./node_modules/.bin/electron-pdf ]; then
            echo "====> Electron PDF not found, trying to install via npm"
            cd "$(thedir)"
            npm install electron-pdf
            r=$?
            [ "$r" != "0" ] && exit $r
        fi
        ./node_modules/.bin/electron-pdf "$(thedir)/dist/cv.${l}.html" "$(thedir)/dist/cv.${l}.pdf"

        echo "==> Done processing language"
    done
done
    



    