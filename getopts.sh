#!/usr/bin/env sh
#getopts - POSIX shell long options parser

#Written in 2018-2024 by Michiel van den Heuvel (michielvdnheuvel@gmail.com)

#To the extent possible under law, the author(s) have dedicated all copyright
#and related and neighboring rights to this software to the public domain
#worldwide. This software is distributed without any warranty.
#You should have received a copy of the CC0 Public Domain Dedication along with
#this software. If not, see http://creativecommons.org/publicdomain/zero/1.0/

_getopts_compile() {
    nl="$(printf \\n_)" && nl="${nl%_}"
    spec="${1#:}"
    opt="${2%%:*}"
    idx="${2#$opt:}" && idx="${idx%:*}"
    case "$2" in
    *:*:*) arg="${2##*:}" ;;
    *:*) arg="OPTARG" ;;
    *)
        printf "ERROR: %s does not match <opt_var>:<idx_var>[:<arg_var>]\n" \
            "$2" >&2
        exit 2
        ;;
    esac
    prog="${prog}$idx=\${$idx-1.0}$nl"
    prog="${prog}[ \"\${$idx%.*}\" -le \$# ] || return 1$nl"
    prog="${prog}shift \$((\${$idx%.*} - 1))$nl"
    prog="${prog}[ \"\$(printf %.1s \"\$1\")\" = - ] || return 1$nl"
    prog="${prog}$arg=\"\$1\"$nl"
    prog="${prog}while [ \${#$arg} -gt \$((\${#1} - \${$idx#*.})) ]; do$nl"
    prog="${prog}    $arg=\"-\${$arg#-?}\"$nl"
    prog="${prog}done$nl"
    prog="${prog}case \"\$( \\$nl"
    prog="${prog}    if [ \"--\${$arg#--}\" = \"\$1\" ]; then$nl"
    prog="${prog}        printf %s \"\${$arg}\"$nl"
    prog="${prog}    else$nl"
    prog="${prog}        printf %.2s \"\${$arg}\"$nl"
    prog="${prog}    fi$nl"
    prog="${prog})\" in $nl"
    while [ -n "$spec" ]; do
        c="$(printf %.1s "$spec")"
        case "$c" in
        [A-Za-z0-9_]) : ;;
        *) c="\\$c" ;;
        esac
        spec="${spec#?}"
        hasarg="${spec%%[!:]*}"
        if [ "$hasarg" = : ]; then
            spec="${spec#:}"
        fi
        if [ "$(printf %.1s "$spec")" = \( ]; then
            spec="${spec#\(}"
            long="${spec%%\)*}"
            spec="${spec#$long\)}"
            long="'--$long'"
        else
            long=""
        fi
        if [ "$hasarg" = : ]; then
            if [ -n "${long-}" ]; then
                prog="${prog}${long}=*)$nl"
                prog="${prog}    $opt=$c$nl"
                prog="${prog}    $arg=\"\${$arg#$long=}\"$nl"
                prog="${prog}    $idx=\$((\${$idx%.*} + 1)).0$nl"
                prog="${prog}    ;;$nl"
                prog="${prog}${long})$nl"
                prog="${prog}    $opt=$c$nl"
                prog="${prog}    $arg=\"\$2\"$nl"
                prog="${prog}    $idx=\$((\${$idx%.*} + 2)).0$nl"
                prog="${prog}    ;;$nl"
            fi
            prog="${prog}-$c)$nl"
            prog="${prog}    $opt=$c$nl"
            prog="${prog}    if [ \"\${$arg}\" = -$c ]; then$nl"
            prog="${prog}        $arg=\"\$2\"$nl"
            prog="${prog}        $idx=\$((\${$idx%.*} + 2)).0$nl"
            prog="${prog}    else$nl"
            prog="${prog}        $arg=\"\${$arg#-$c}\"$nl"
            prog="${prog}        $idx=\$((\${$idx%.*} + 1)).0$nl"
            prog="${prog}    fi$nl"
            prog="${prog}    ;;$nl"
        else
            prog="${prog}-$c${long:+|${long}})$nl"
            prog="${prog}    $opt=$c$nl"
            prog="${prog}    [ -n \"\${$arg#-$c}\" ] \\$nl"
            [ -z "${long-}" ] \
                || prog="${prog}        && [ \"\${$arg}\" != $long ] \\$nl"
            prog="${prog}        && $idx=\${$idx%.*}.\$((\${$idx#*.} + 1)) \\$nl"
            prog="${prog}        || $idx=\$((\${$idx%.*} + 1)).0$nl"
            prog="${prog}    unset $arg$nl"
            prog="${prog}    ;;$nl"
        fi
    done
    prog="${prog}--)$nl"
    prog="${prog}    $idx=\$((\${$idx%.*} + 1)).0$nl"
    prog="${prog}    return 1$nl"
    prog="${prog}    ;;$nl"
    prog="${prog}*) return 2 ;;$nl"
    prog="${prog}esac$nl"
    printf %s "$prog"
}

getopts() {
    eval "shift 2; $(
        func= spec= nl= c= long= opt= idx= arg= prog= hasarg= \
            _getopts_compile "$@"
    )"
}
