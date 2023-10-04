# sgit - run sed on files under git control

`sgit` runs `sed(1)` on files that are under git control, based on one or more
globs (either a pattern or an exact file name). Running this from a directory
that is not a git repository is an error and any files not under git control in
the directory will not be touched. Depending on the globs specified it might or
might not recurse into subdirectories. That is the shell at work, of course.

`sgit` is extremely useful because one need not run extra commands to determine
the list of files (which might be very long) and then pass them directly to
`sed(1)`. Since it only acts on files under `git` control you need not worry
about files that are not under git control being touched or even considered.

You can specify the path to `sed` in case you wish to use a different one. For
instance in macOS if you have GNU sed installed you might want to use that
instead. You can do that with the `-s sed` option.

If you wish to provide options to `sed` itself you can so with the `sgit -o`.
Note that you **MUST** pass the `-` for short options and the `--` for long
options!  In other words use the options like you would with `sed` but prefixing
it with `-o` first.

This was a stylistic choice but it allows one to quote (which is probably always
preferable) the option arg to pass more than one option instead of having to use
`sgit -o` more than once though you can certainly use the option more than once.
If there's a need for a space then you must quote it.  Note that not all options
to `sed` have been tested.

By default it does **in-place editing and it does NOT backup files**. If you
wish to not edit the file in place (see [examples](#examples) later in this
file) you can use the `sgit -I` option. Note that the `sed` option `-n` (`sgit
-o -n`) without `sgit -I` can, depending on the sed commands, empty files! This
is analogous to using both `-n` and `-i` to `sed` which would do in-place
editing without automatic printing of the pattern space. An example is provided
later.

If you wish to provide a backup extension for editing files use `sgit -i`. See
example below. Note that using `-i` overwrites existing backup files and it will
also create or update a file for each file edited. This means that if it ends up
editing 50 files without a backup file (with the extension provided) there will
be 50 new files created. Using this option might be of limited use, of course,
since files under git control can be restored, compared etc. but it's there in
case one wants it.

See the usage below or run `sgit` by itself (or with the `-h` option) to see the
rest of the options.

See the section [Script history](#script-history) for more details on the
evolution of the script.

## Usage

```sh
usage: sgit [-h] [-V] [-v level] [-x] [-I] [-i extension] [-o sed_option] [-s sed] [-e command] [-n] <glob...>

    -h			    print help and exit
    -V			    print version and exit
    -v level		    set verbosity level
    -x			    turn on tracing (set -x)
    -I			    disable in place editing

    -i extension	    set backup extension (default none)
				WARNING: sed -i overwrites existing backup files
				WARNING: this will create or update a file for each file changed

    -o sed_option	    append sed option to options list
				WARNING: use of '-o -n' without '-I', can depending on
				sed commands, empty files as if both sed -i and sed -n were
				used together

				NOTE: you must pass the '-' for short options and '--' for long options!
				NOTE: if you need a space in an option you should quote it!
				NOTE: trying to use this option once to add more than one command can be problematic
				depending on how you do it so it is better to do only one command at a time

    -s sed		    set path to sed
    -e command		    append sed command to list of commands to execute on globs

    -n			    dry-run: only show files that would be modified but do not touch them

				NOTE: depending on verbosity level, only the files considered will
				be printed or the sed commands along with the files will be printed
				NOTE: use of -n prevents sed commands from being run


sgit version: 0.0.17-1 04-10-2023
```

You **MUST** specify at least one `sed` command and one glob: the `sed` command
by way of the `-e` option (analogous to `sed -e`); anything after the last option
is a glob. You may specify more than one of each. Specify `-e` for each command.
The `sed` commands is an array just like the `sed` options.

Note that although in some cases it is possible to specify more than one command
with just one `-e` option it can end up resulting in a `sed` error so it is
recommended that you use `-e` for each command.

## A note about the `-i` option and backup extensions

It works like `sed -i` except that the default behaviour of the script is to use
`-i` just with an empty backup extension (this is required for some versions of
`sed` which force that a backup extension actually be provided with the `-i`
option .. I'm looking at you, BSD/macOS `sed`).


## `sgit -i` WARNING: each file edited will result in another file in the working directory

Of course if you have 50 files that are edited then 50 new files will be
created (or otherwise updated) just like with `sed` itself.

# `sgit -i` WARNING: this **WILL OVERWRITE EXISTING BACKUP FILES**!

Please be aware that if a backup file already exists it **WILL** be overwritten!
This is because it uses `sed -i`.

I won't even try and detect this because it's not how `sed` works and it would
overly complicate the script plus it's almost pointless with `git`.


# `sgit -o -n` WARNING: invalid use of `sgit -o -n` can empty files!

As already noted: because `sed -n` does not print output if you do not use `-I`
and you use substitute or do not print everything you can empty the entire file
or remove much of the file for two examples. For instance **DO NOT** do this:


```sh
sgit -o -n -e 's/.//g' sgit
```

because it would empty `sgit`!

## More about options and the tool itself

A man page exists for this tool with more about the tool and the options. It has
some examples but it might be more useful to see the [Examples](#examples) in
this file instead. To render it:

```sh
man sgit
```

if installed. Otherwise if it's not installed you can do:

```sh
man ./sgit.1
```


## Examples

### Change references (_**IN MEMORY ONLY**_ i.e. WITHOUT in-place editing) of the exact word `sed` (as in `\<sed\>`) in this file but only show changed lines

```sh
sgit -I -o -n -e 's/\<sed\>/used/p' README.md
```

### Print out matches of the EXACT word `sed` (as in `\<sed\>`) in all files under git control from the current working directory

This is a simpler way of running `git --no-pager grep -h -E '\<sed\>'|sed
's/^[0-9]*://g'` which itself might or might not be more complicated than it
needs to be:

```sh
sgit -I -o -n -e '/\<sed\>/p' .
```

### With tracing enabled, change references of `\<sed\>` to `used` in this file and save it:

```sh
sgit -e 's/\<sed\>/used/g' -x README.md
```


### With tracing enabled, change references of `\<sed\>` to `used`, duplicating the lines, in this file and save it:

```sh
sgit -e 's/\<sed\>/used/p' -x README.md
```

## Verbosely (level 1) change references of `\<sed\>` to `used` in this file and save it:

```sh
sgit -e 's/\<sed\>/used/g' -v1 README.md
sgit -e 's/\<sed\>/used/g' -v 1 README.md
```

The two are equivalent but naturally running them in sequence the second one
would not do anything useful.

## Verbosely (level 3) change references of `\<sed\>` to `used` in this file with a backup as `README.md.bak`

```sh
sgit -i.bak -e 's/\<sed\>/used/g' -v 3 README.md
```

With the command you would see something like:

```sh
debug[2]: sed commands:  -e	s/\<sed\>/used/g
debug[2]: looping through all globs
debug[1]: using backup extension: .bak
debug[2]: found glob: 0
debug[1]: about to run: git ls-files README.md | xargs /opt/local/bin/sed -i".bak" -e	s/\<sed\>/used/g
debug[2]: 0 remaining globs
```

Level 2 will not show how many globs remain after each operation.


### Verbosely (level 3) change references of `\<used\>` back to `sed` in this file with a backup as `README.md.bak`

```sh
sgit -i.bak -e 's/\<used\>/sed/g' -v 3 README.md

```

With that you would see something like:

```sh
sgit -i.bak -e 's/\<used\>/sed/g' -v3 README.md
debug[2]: sed commands:  -e	s/\<used\>/sed/g
debug[2]: looping through all globs
debug[1]: using backup extension: .bak
debug[2]: found glob: 0
debug[1]: about to run: git ls-files README.md | xargs /opt/local/libexec/gnubin/sed -i".bak" -e	s/\<used\>/sed/g
debug[2]: 0 remaining globs
```

and the example title would look like:

```markdown
### Verbosely (level 3) change references of `\<sed\>` back to `sed` in this file with a backup as `README.md.bak`
```

## Change `\<sed\>` to `used` but only if it's on the first line

```sh
sgit -e '1s/\<sed\>/used/g' README.md
```

Alternatively you could do one of:


```sh
sgit -e '1s/\<sed\>/u&/g' README.md
sgit -e '1s/\(\<sed\>\)/u\1/g' README.md
```

### Change `\<sgit\>` to `gits` but only if it's on the third line

```sh
sgit -e '3s/\<sgit\>/gits/g' README.md
```

### Dry-run mode: _ONLY SHOW_ files that would be modified rather than modify them

If you want to _ONLY SEE FILES_ that would be considered _WITHOUT_ touching them you
can use the `-n` option like so:

```sh
sgit -n -e '' .
```

This would print every file in the repository from the current working
directory. Since nothing will be done anyway it would not matter if the sed
command list is empty. Typically if the sed command list is empty it just won't
do anything but in this case it would not change any behaviour of sed as sed
won't be run. For instance the above command would show in this repository at
this time (03 Oct 2023):

```sh
.gitignore
CHANGES.md
Makefile
README.md
sgit
sgit.1
```

NOTE: it is pointless to supply a `sed` command in this case but nevertheless
you must do so.

### Dry-run mode: _ONLY SHOW_ sed commands with the files found rather than actually running sed on them

If you want to see the sed command along with the files found _WITHOUT_ touching
them you can use the `-n` option with a verbosity level greater than or equal to
1 like so:

```sh
sgit -v 1 -n -e 's/foo/bar/g' .
```

This would show every file along with the sed command, `s/foo/bar/g`, which if used without
the `-n` would actually be run on each file found. For instance, the above
command might show:

```sh
$ sgit -v 1 -n -e 's/foo/bar/g' .
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g .gitignore
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g CHANGES.md
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g Makefile
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g README.md
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g sgit
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g sgit.1
```

If verbosity is 2 or 3 you would see respectively:

```sh
$ sgit -v 2 -n -e 's/foo/bar/g' .
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g .gitignore
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g CHANGES.md
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g Makefile
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g README.md
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g sgit
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g sgit.1
```

and

```sh
$ sgit -v 3 -n -e 's/foo/bar/g' .
debug[2]: sed commands:  -e	s/foo/bar/g
debug[2]: looping through all globs
debug[2]: found glob: 0
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g .gitignore
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g CHANGES.md
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g Makefile
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g README.md
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g sgit
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g sgit.1
debug[2]: 0 remaining globs
```

If you were to specify more than one command you might see something like:

```sh
$ sgit -n -v 3 -e 's/foo/bar/g' -e 's/FOO/BAR/g' .
debug[2]: sed commands:  -e	s/foo/bar/g	-e	s/FOO/BAR/g
debug[2]: looping through all globs
debug[2]: found glob: 0
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g -e s/FOO/BAR/g .gitignore
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g -e s/FOO/BAR/g CHANGES.md
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g -e s/FOO/BAR/g Makefile
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g -e s/FOO/BAR/g README.md
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g -e s/FOO/BAR/g sgit
/opt/local/libexec/gnubin/sed -i -e s/foo/bar/g -e s/FOO/BAR/g sgit.1
debug[2]: 0 remaining globs
```

## Installation

If you wish to install it you may either copy it to a place in your path or if
you have `make` installed you can just run `make install` either as root or via
`sudo` like:

```sh
sudo make install
```

## Limitations

One that comes to mind is you cannot specify `git ls-files` options but this
could be problematic anyway especially if one were to specify the `-z` option.

There are probably other limitations but it works well for what I needed.

## Bugs

None known but it does not try and determine which files match the patterns.
This would likely greatly complicate the script and is I feel unneeded.

If you specify invalid `sed` commands obviously there will be problems. If you
specify invalid `sed` options there will possibly be problems as well.

As below this was originally a hack.


## History

It has been a persistent problem for me that I need to edit files under git
control and `sed` is the obvious way to go about it.

Working on the [IOCCC mkiocccentry](https://github.com/ioccc-src/mkiocccentry)
and the [IOCCC temporary website](https://github.com/ioccc-src/temp-test-ioccc)
repos (and in particular the latter) is what inspired me to finally do something
about it. The latter repo will eventually be merged into the [IOCCC winner
repo](https://github.com/ioccc-src/winner) which is the actual [IOCCC
website](https://www.ioccc.org).

### Script history

This was originally a quick and dirty hack to modify files under git control via
`sed`. It started out with some limitations like the inability to deal with
spaces in `sed` commands, only allowing one command (due to a bug) and it had
terrible efficiency because it ran git ls-files for each `sed` command.

Now it is much more thorough and is more efficient (though not perfect). It
allows you to specify a path to `sed`, `sed` options and multiple `sed` commands
(though the latter always existed), it can disable in-place editing, you can
backup files if you wish and much more.

`sgit` version `0.0.9-1 24-04-2023` added support to use the `-o` option more
than once. Not allowing this was an oversight.

[Landon Curt Noll](http://www.isthe.com/chongo/) provided some valuable thoughts
and suggested the `-n` option.  This was initially added in version `0.0.14-1
03-10-2023`. Thank you Landon!

## Other thoughts

Pull requests are welcome but I think it's mostly in a good enough state where
this will probably generally not be needed.

## Dedications

This is dedicated to the [IOCCC](https://www.ioccc.org), the [IOCCC
judges](https://www.ioccc.org/judges.html) especially ([Landon Curt
Noll](http://www.isthe.com/chongo/)) for the friendship, telling me stories and
jokes, telling me history of different things about Unix, C and other things and
giving me the wonderful opportunity to help so much with the IOCCC - prompting
me to write this tool - and above all my dear Mum Dianne and my wonderful cousin
Dani.
