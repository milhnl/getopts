#!/usr/bin/env sh
set -eu

. ./getopts.sh

cd "$(mktemp -d)"

testops() { #1:description, 2:spec, 3:endindex, 3:expected, 3:args...
    for x in spec verbose opt arg i; do
        eval "$x=sentinel"
    done
    unset index option OPTARG
    description="$1"
    optstring="$2"
    end_index="$3"
    printf "%s" "$4" >"expect: $description"
    printf "\n" >"result: $description"
    shift 4
    while getopts "$optstring" "option:index" "$@"; do
        printf "%s:%s: %s\n" "$index" "$option" "$OPTARG" \
            >>"result: $description"
    done
    diff -u "expect: $description" "result: $description" ||:
    [ "$end_index" = "$index" ] \
        || echo "index: $description $index ~ $end_index"
    for x in spec verbose opt arg i; do
        [ "$(eval "echo \"\$$x"\")" = sentinel ] || echo "getopts overwrote $x"
    done
}

testops "single option" "a" 2.0 '
2.0:a: 
' -a

testops "multiple options" "ab" 3.0 '
2.0:a: 
3.0:b: 
' -a -b

testops "sharing the leading dash" "abc" 3.0 '
1.1:b: 
2.0:c: 
3.0:a: 
' -bc -a

testops "arguments" "a:b" 7.0 '
1.1:b: 
2.0:a: arg0
2.1:b: 
4.0:a: arg1
5.0:a: arg2
7.0:a: arg3
' -baarg0 -ba arg1 -aarg2 -a arg3

testops "dash override" "-" 2.0 '
2.0:-: 
' --

testops "long options" "a(append)bc" 3.0 '
2.0:a: 
3.0:a: 
' -a --append

testops "all printable ascii chars except ':'" '() !"#$%&'"'"'*+,-./0123456789;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~' 2.0 '
1.1:(: 
1.2:): 
1.3: : 
1.4:!: 
1.5:": 
1.6:#: 
1.7:$: 
1.8:%: 
1.9:&: 
1.10:'"'"': 
1.11:*: 
1.12:+: 
1.13:,: 
1.14:-: 
1.15:.: 
1.16:/: 
1.17:0: 
1.18:1: 
1.19:2: 
1.20:3: 
1.21:4: 
1.22:5: 
1.23:6: 
1.24:7: 
1.25:8: 
1.26:9: 
1.27:;: 
1.28:<: 
1.29:=: 
1.30:>: 
1.31:?: 
1.32:@: 
1.33:A: 
1.34:B: 
1.35:C: 
1.36:D: 
1.37:E: 
1.38:F: 
1.39:G: 
1.40:H: 
1.41:I: 
1.42:J: 
1.43:K: 
1.44:L: 
1.45:M: 
1.46:N: 
1.47:O: 
1.48:P: 
1.49:Q: 
1.50:R: 
1.51:S: 
1.52:T: 
1.53:U: 
1.54:V: 
1.55:W: 
1.56:X: 
1.57:Y: 
1.58:Z: 
1.59:[: 
1.60:\: 
1.61:]: 
1.62:^: 
1.63:_: 
1.64:`: 
1.65:a: 
1.66:b: 
1.67:c: 
1.68:d: 
1.69:e: 
1.70:f: 
1.71:g: 
1.72:h: 
1.73:i: 
1.74:j: 
1.75:k: 
1.76:l: 
1.77:m: 
1.78:n: 
1.79:o: 
1.80:p: 
1.81:q: 
1.82:r: 
1.83:s: 
1.84:t: 
1.85:u: 
1.86:v: 
1.87:w: 
1.88:x: 
1.89:y: 
1.90:z: 
1.91:{: 
1.92:|: 
1.93:}: 
2.0:~: 
' -'() !"#$%&'"'"'*+,-./0123456789;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'

testops "long option arguments" "a:(along)b" 4.0 '
2.0:a: arg0
4.0:a: arg1
' --along=arg0 --along arg1

testops "multiline arguments" "a:b" 3.0 '
2.0:a: arg0 line 1
line 2
3.0:b: 
' -a"arg0 line 1
line 2" -b

testops "initial state" "a" 1.0 '
' aaaaa

testops "double dash terminator" "a" 2.0 '
' -- a b c

testops "empty argument" "a" 1.0 '
' ''
