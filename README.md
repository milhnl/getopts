# getopts - POSIX shell long options parser

This small shell library solves the issue of using long options (GNU-style) in
shell scripts that can only rely on a POSIX environment. It is drop-in
compatible with the standard `getopts`, except for `$OPTIND`. The specification
grammar for long options is derived from Solaris and extremely simple to use.

## Usage

- Copy-paste the `getopts.sh` script into your own code, or include it with git
  submodule. This last method has two advantages: updates, and you can verify
  that it works with `test.sh`.

- Change your getopts calls from `getopts OPT_VAR ":opt:s:"` to
  `getopts OPT_VAR:OPTIND_ALTERNATIVE ":opt:s:" "$@"` - i.e., add a colon and
  variable name for the position to the first argument, and explicitly pass the
  arguments you want to be parsed. This of course means that you also have to
  replace all occurences of `OPTIND` with your alternative, like
  `${OPTIND_ALTERNATIVE%.*}` (see reference below).

- Test! The changes you made should change nothing at this point, which is
  quite easy to test.

- Now add the long options. The grammar for long options is the one Solaris
  uses for their `getopts` implementation. But you don't have to read their
  [docs](https://docs.oracle.com/cd/E88353_01/html/E37839/getopts-1.html). It
  is very simple: Long options are synonyms for short options, and come after
  them (and the optional colon for an argument). So, to give an example:

       getopts OPT 'f:av'

  becomes

       getopts OPT:INDEX 'f:(file)a(append)v(verbose)' "$@"

  and the parsing for the OPT variable can stay the same, as it outputs the
  single-letter synonym for every long option encountered.

## Reference/Advanced usage

The full usage of `getopts` is:

    getopts <optstring> <opt>:<idx>[:<arg>] [args...]

#### `optstring`

The specification of what options to parse. `opstring` is a concatenation of
individual options, which have the following format:

- A single character, which can be any printable ASCII character except `:`.
  This will be the short option, and will be returned for the long option if
  given. If you want to use `(`, it needs to be the first in `optstring`.
- An optional colon (`:`). This will indicate that the option requires an
  argument.
- Long synonym surrounded by `(` and `)`.

An example is given above under 'Usage'.

#### Variable names

- `opt`: The shell variable where the option character will be stored.
- `idx`: The shell variable where the index of the next token is stored. This
  is, contrary to `OPTIND`, not a single number, but the argument number, a `.`
  and the offset of the character inside that argument.

  For example, to shift all parsed options out of `"$@"`, if you called this
  `INDEX`:

      shift $(( ${INDEX%.\*} - 1 ))

- `arg`: The shell variable where the option argument will be stored. Will be
  unset if option does not require an argument. If omitted, will default to
  `OPTARG`.

## Compatibility notes

Great care was taken to ensure `getopts` is as compatible as possible.

- It is tested with and supports at least:
  - bash (both 3.2 -- which is bundled with macOS -- and modern)
  - dash
  - zsh
- `set -e`, `set -u` do not affect this version of `getopts`.
- The execution environment is not altered in any way other than the variable
  names passed in its first argument.
- It does not `exec` _any_ external dependency, not counting `printf`, which is
  built-in for most shells.

## Bugs

- `opt`, `arg`, `idx` will not work as variable names for getopts output. Will
  be fixed in a new version.
- `OPTIND` does not work. This will never be fixed. I tried a lot of things,
  but it boils down to the simple fact that this one variable can't hold the
  full state of `getopts`, as it needs to remember at which character in the
  argument it is (e.g. `tar -xf foo.tar`, first argument, but `x` or `f`?). And
  using an extra variable does not work either. In that case, how do you
  discriminate between being in the first argument, or being reset?
- Verbose mode isn't added yet. Don't think anyone cares. If you do, send a
  pull request or a very friendly message.
