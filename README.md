getopts - POSIX shell long options parser
=========================================

This small shell library solves the issue of using long options in
shell scripts that can only rely on a POSIX environment. It is drop-in
compatible with the standard `getopts`, except for `$OPTIND`. The
specification grammar for long options is derived from Solaris and
extremely simple to use.

Usage
-----

  - Copy-paste the `getopts.sh` script into your own code, or include
    it with git submodule. This last method has two advantages: updates,
    and you can verify that it works with `test.sh`.

  - Change your getopts calls from `getopts OPT_VAR ":opt:s:"` to
    `getopts OPT_VAR:OPTIND_ALTERNATIVE ":opt:s:" "$@"` - i.e., add a
    colon and variable name for the position to the first argument, and
    explicitly pass the arguments you want to be parsed. This of course
    means that you also have to replace all occurences of `OPTIND` with
    your alternative.

  - Test! The changes you made should change nothing at this point,
    which is quite easy to test.

  - Now add the long options. The grammar for long options is the one
    Solaris uses for their `getopts` implementation. But you don't have
    to read their documentation, as it is very simple. Long options are
    synonyms for short options, and come after them (and the optional
    colon for an argument). So, to give an example:

         getopts OPT 'f:av'

    becomes

         getopts OPT:INDEX 'f:(file)a(append)v(verbose)' "$@"

    and the parsing for the OPT variable can stay the same, as it outputs
    the single-letter synonym for every long option encountered.

Bugs
----

  - `OPTIND` does not work. This will never be fixed. I tried a lot of
    things, but it boils down to the simple fact that this one variable
    can't hold the full state of `getopts`, as it needs to remember at
    which character in the argument it is (e.g. `tar -xf foo.tar`,
    first argument, but `x` or `f`?). And using an extra variable does
    not work either. In that case, how do you discriminate between being
    in the first argument, or being reset?
  - It does not currently support multiline option arguments. This will
    be the next, and probably last, feature to be added.
  - The double-dash override doesn't work on `zsh`. 
