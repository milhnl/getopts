#!/usr/bin/env sh

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
    [ "${OPTIND-1}" = 1 ] && _getopts_subarg_index=0
    i="${OPTIND-1}.$_getopts_subarg_index"
    _getopts_worker "$@"
    case $? in
    0)
        OPTIND="${i%.*}"
        _getopts_subarg_index="${i#*.}"
        eval "$2=\$opt"
        OPTARG="$arg"
        ;;
    1)
        OPTIND="$(( ${i%.*} + 1 ))"
        eval "$2=\?"
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

true PROGRAM START ------------------------------------------------------------
while getopts "$OPTSTRING" OPT "$@"; do
    printf '$OPTIND=%s $OPT=%s $OPTARG=%s\n' "$OPTIND" "$OPT" "$OPTARG"
done
printf '$OPTIND=%s $OPT=%s $OPTARG=%s\n' "$OPTIND" "$OPT" "$OPTARG"
true
