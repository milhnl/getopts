#!/usr/bin/env sh
#getopts - POSIX shell long options parser

#Written in 2018 by Michiel van den Heuvel (michielvdnheuvel@gmail.com)

#To the extent possible under law, the author(s) have dedicated all copyright
#and related and neighboring rights to this software to the public domain
#worldwide. This software is distributed without any warranty.
#You should have received a copy of the CC0 Public Domain Dedication along with
#this software. If not, see http://creativecommons.org/publicdomain/zero/1.0/

_getopts_inc() {
    printf "%s.%s" "$(( ${1%.*} + ${2%.*} ))" \
        "$( [ ${2#*.} != 0 ] && echo $(( ${1#*.} + ${2#*.} )) || echo 0)"
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
                    printf("/^--%s=/ { print \"1.0:%s: \" $2; next }\n", long, out)
                    printf("/^--%s$/ { print \"2.0:%s:\"; next }\n", long, out)
                } else {
                    printf("/^--%s$/ { print \"1.0:%s\"; next }\n", long, out)
                }
                next
            }
            /^./ { flag = "\\" $0; out = substr($0, 1, 1) }
            /^[\\"]/ { out = "\\" substr($0, 1, 1) }
            /^[^][\\().*+?{}|^$\/]/ { flag = $0 }
            /^.:$/ {
                printf("/^-%s./ { print \"1.0:%s: \"", substr(flag, 1, 1), out)
                printf(" substr($0, 3); next }\n")
                printf("/^-%s$/ { print \"2.0:%s:\"; next }\n", substr(flag,1,1),out)
                next
            }
            /^.$/ {
                printf("/^-%s$/ { print \"1.0:%s\"; next }\n", flag, out)
                printf("/^-%s./ { print \"0.1:%s\"; next }\n", flag, out)
                next
            }
            /^$/ { next }
            { print $0 | "cat >&2"; print "BEGIN { exit 3 }"; exit 3 }
            END { 
                print "/^-./ { exit 2 }\n/^--$/ { exit 1 }"
                print "/^[^-]/ { exit 1 }\n/^$/ { exit 1 }\n"
            }
        ')"
    )" || return $?
    case "$(echo "$opt" | sed 's/^[0-9]*\.[0-9]*:.//')" in
    :\ *)
        arg="${opt#*.*:*: }"
        opt="${opt%: $arg}"
        ;;
    :)
        opt="${opt%:}"
        arg="$2"
        ;;
    esac
    i=$(_getopts_inc "$i" "${opt%%:*}")
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
