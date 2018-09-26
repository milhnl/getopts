#!/usr/bin/env sh
#getopts - POSIX shell long options parser

#Written in 2018 by Michiel van den Heuvel (michielvdnheuvel@gmail.com)

#To the extent possible under law, the author(s) have dedicated all copyright
#and related and neighboring rights to this software to the public domain
#worldwide. This software is distributed without any warranty.
#You should have received a copy of the CC0 Public Domain Dedication along with
#this software. If not, see http://creativecommons.org/publicdomain/zero/1.0/

_getopts_globmatch() {
    case "$2" in $1) return 0 ;; *) return 1 ;; esac ;
}

_getopts_inc() {
    case "$1" in
    '+')
        printf "%s.%s" "$(( ${2%.*} + ${3%.*} ))" \
            "$( [ ${3#*.} != 0 ] && echo $(( ${2#*.} + ${3#*.} )) || echo 0)"
        ;;
    esac
}

_getopts_worker() {
    shift 2
    [ "${i%.*}" -gt $# ] && return 1
    shift $(( ${i%.*} - 1 ))
    set -- "-$(printf "%s" "$1" | cut -c $(( 2 + ${i#*.} ))-)" "$2" "$3"
    opt="$(printf "%s" "$1" | awk "$(echo "$spec" \
        | sed "$(printf 's/.:\{0,1\}\(([^)]*)\)\{0,\}/&\\\n/g;s/(/\\\n(/g;')" \
        | awk '
            BEGIN { print "BEGIN { FS = \"=\" }" }
            /^\(.*\)$/ {
                long = substr($0,2,length($0) - 2)
                if (substr(flag, 2) == ":") {
                    printf("/^--%s=/ { print \"1.0:%s \" $2; next }\n", long, flag)
                    printf("/^--%s$/ { print \"2.0:%s\"; next }\n", long, flag)
                } else {
                    printf("/^--%s$/ { print \"1.0:%s\"; next }\n", long, flag)
                }
                next
            }
            /^.:$/ {
                printf("/^-%s./ { print \"1.0:%s \" ", substr($0, 1, 1), $0)
                printf("substr($0, 3); next }\n")
                printf("/^-%s$/ { print \"2.0:%s\"; next }\n", substr($0,1,1), $0)
                flag=$0; next
            }
            /^.$/ {
                printf("/^-%s$/ { print \"1.0:%s\"; next }\n", $0, $0)
                printf("/^-%s./ { print \"0.1:%s\"; next }\n", $0, $0)
                flag=$0; next
            }
            /^$/ { next }
            { print $0 | "cat >&2"; print "BEGIN { exit 3 }"; exit 3 }
            END { 
                print "/^-./ { exit 2 }\n/^--$/ { exit 1 }"
                print "/^[^-]/ { exit 1 }\n/^$/ { exit 1 }\n"
            }
        ')"
    )" || return $?
    if _getopts_globmatch '*.*:*: *' "$opt"; then
        arg="${opt#*.*:*: }"
        opt="${opt%: $arg}"
    elif _getopts_globmatch '*.*:*:' "$opt"; then
        opt="${opt%:}"
        arg="$2"
    fi
    i=$(_getopts_inc + "$i" "${opt%:*}")
    opt="${opt#*.*:}"
}

_getopts_return() {
    eval "i=\"\${${2#*:}-1.0}\""
    _getopts_worker "$@"
    case $? in
    0)
        eval "${2%:*}=\$opt"
        eval "${2#*:}=\$i"
        OPTARG="$arg"
        ;;
    1)
        eval "${2%:*}=\?"
        eval "${2#*:}=\$i"
        OPTARG="$arg"
        return 1
        ;;
    2)
        return 2 
        ;;
    *)
        return 2 ;;
    esac
}

getopts() { #1: spec, 2: name, 3: args...
    spec="${1#:}" verbose="${1%%[!:]*}" opt= arg= i= _getopts_return "$@"
}
