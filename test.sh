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

#Test dash override
testops "-" '
2.0:-: 
' --

#Test all printable ascii chars except ':'
testops '() !"#$%&'"'"'*+,-./0123456789;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~' '
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
