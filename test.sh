#!/usr/bin/env sh

. ./getopts.sh

cd "$(mktemp -d)"

testops() { #1: spec, 2:expected, 3:args...
    INDEX=1.0
    OPTSTRING="$1"
    printf "%s" "$2" >"a"
    printf "\n" >"b"
    shift 2
    while getopts "$OPTSTRING" "OPT:INDEX" "$@"; do
        printf "%s:%s: %s\n" "$INDEX" "$OPT" "$OPTARG" >>"b"
    done
    diff -u "a" "b"
}

testops "a(append)bc" '
2.0:a: 
3.0:a: 
' -a --append

testops "abc" '
1.1:b: 
2.0:c: 
3.0:a: 
' -bc -a

testops "f:(file)b:c" '
1.1:c: 
2.0:b: argb
4.0:f: argf
' -cbargb --file argf

