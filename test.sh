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

#Test long option
testops "a(append)bc" '
2.0:a: 
3.0:a: 
' -a --append

#Test sharing the leading dash
testops "abc" '
1.1:b: 
2.0:c: 
3.0:a: 
' -bc -a

#Test arguments
testops "a:(along)b" '
1.1:b: 
2.0:a: arg0
2.1:b: 
4.0:a: arg1
5.0:a: arg2
7.0:a: arg3
8.0:a: arg4
10.0:a: arg5
' -baarg0 -ba arg1 -aarg2 -a arg3 --along=arg4 --along arg5
