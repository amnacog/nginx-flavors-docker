#!/usr/bin/env sh

cd $(dirname $0)

if [ "$1" == "add" ]; then
    packages="$(echo $@ | cut -d' ' -f2-)"
    apk update
    apk add $packages
    ret=$?
    echo $packages > installed
    return $ret
fi
# elif [ "$1" == "del" ]; then
#     apk del $(cat installed)
#     rm -rf /tmp/*
# fi