# sgit - run sed on files under git control

`sgit` runs `sed(1)` on files that are under git control, based on one or more
globs (either a pattern or an exact file name). Running this from a directory
that is not a git repository is an error and any files not under git control in
the directory will not be touched. Depending on the globs specified it might or
might not recurse into subdirectories. That is the shell at work, of course.

`sgit` is extremely useful because one need not run extra commands to determine
the list of files (which might be very long) and then pass them directly to
`sed(1)`. Since it only acts on files under `git` control you need not worry
about files that are not under git control being touched or even considered. The
first example in the [examples](#examples) section will show just how useful
this tool is.

You can specify the path to `sed` in case you wish to use a different one. For
instance in macOS if you have GNU sed installed you might want to use that
instead. You can do that with the `-s sed` option.

If you wish to provide options to `sed` itself you can so with the `sgit -o`.
Note that you **MUST** pass the `-` for short options and the `--` for long
options!  In other words use the options like you would with `sed` but prefixing
it with `-o` first.

This was a stylistic choice but it allows one to quote (which is probably always
preferable) the option arg to pass more than one option instead of having to use
`sgit -o` more than once though you can certainly use the option more than once
(and it's generally preferable as there are cases where it is problematic to
not). If there's a need for a space then you must quote it.  Note that not all
options to `sed` have been tested: not only with using only one `-o` but not
every option of `sed` has been tested at all.

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

A dry-run option exists, `-n`, which will depending on verbosity level show just
the files that `sed` would run on or the files and the `sed` commands, one file
per line.

If you need to test the `sed` commands for syntax errors you can do so with the
`-t` option. With verbosity level >= 1 it will show which `sed` command is being
tested.

If you require the `-z` option to `git ls-files` use `-0`. This will force the
script to also use `xargs -0` which means your `xargs` must allow that option.
This is not enabled by default for a variety reasons including because POSIX
does not require `-0` to `xargs(1)`. This option has not been tested well and
has only been added in case someone needs it. The debug output does not quote
files with spaces or other unsafe characters either.

See the usage below or run `sgit` by itself (or with the `-h` option) to see the
rest of the options.

See the section [Script history](#script-history) for more details on the
evolution of the script.

# Usage

```sh
usage: sgit [-h] [-V] [-v level] [-x] [-I] [-i extension]
	    [-o sed_option] [-s sed] [-g git] [-X xargs]
	    [-e command] [-n] [-t] [-0] <glob...>

    -h			    print help and exit
    -V			    print version and exit
    -v level		    set verbosity level
    -x			    turn on tracing (set -x)
    -I			    disable in place editing

    -i extension	    set backup extension (default none)
				WARNING: sed -i overwrites existing backup files
				WARNING: this will create or update a file for each file changed

    -o sed_option	    append sed option to options list
				WARNING: use of "sgit -o -n" without "sgit -I" can, depending on
				sed commands, empty files as if both 'sed -i' and 'sed -n' were
				used together

				NOTE: you must pass the '-' for short options and '--' for long options!
				NOTE: if you need a space in an option you should quote it!
				NOTE: trying to use this option once to add more than one command can be
				problematic depending on how you do it so it is better to do only one
				command at a time

    -s sed		    set path to sed
    -g git		    set path to git
    -X xargs		    set path to xargs

    -e command		    append sed command to list of commands to execute on globs

    -n			    dry-run: don't run sed, only show files or sed commands with files

				NOTE: if verbosity is > 1 (-v 2)  we show the sed commands along with any sed
				options (if "sgit -o" used) and the files found; otherwise we only show
				the files found.
				NOTE: use of "sgit -n" prevents sed commands from being run

    -t			    test sed commands and exit

				NOTE: this does NOT test sed options ("sgit" -o)

    -0			    Use git ls-files -z and xargs -0

				NOTE: this does not check if your xargs has -0


sgit version: 1.0.2 02-11-2024
```

You **MUST** specify at least one `sed` command and if the `-t` option is not
used you must also specify at least one glob: the `sed` command by way of the
`-e` option (analogous to `sed -e`); anything arg after the last option is a
glob to be used. You may specify more than one of each. Specify `-e` for each
command. The `sed` commands is an array just like the `sed` options.

Note that although in some cases it is possible to specify more than one command
with just one `-e` option it can end up resulting in a `sed` error so it is
recommended that you use `-e` for each command.

# Required tools: `sed(1)`, `git(1)` and `xargs(1)`

As might be expected this script requires the tools `sed(1)` and `git(1)`. It
also requires the tool `xargs(1)`.

## Specifying alternate paths to the tools:

The script uses `type -P` to try and locate the right location but if you need
to specify a different one you can use the options: `-s sed`, `-g git` and/or
`-X xargs`.


# A note about the `-i` option and backup extensions:

It works like `sed -i` except that the default behaviour of the script is to use
`-i` just with an empty backup extension (this is required for some versions of
`sed` which force that a backup extension actually be provided with the `-i`
option .. I'm looking at you, BSD/macOS `sed`).


# `sgit -i` WARNING: each file edited will result in another file in the working directory:

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

# More about options and the tool itself:

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

Of course since this tool must be run in a `git(1)` repo it's not very useful if
it's not installed. See [Installing](#installing) for how to install this tool.


# Examples

## Delete first variable number of lines up through but excluding a matching line

In the [IOCCC temporary website](https://github.com/ioccc-src/temp-test-ioccc)
repo I had to delete the first lines up through the '## To build:' lines
in **all** README.md files of subdirectories in subdirectories of the years 1984-2020
but excluding the README.md files of the 1984-2020 README.md files (the format
of the filenames being YYYY/winner/README.md).

This change was very variable in the number of lines but it was very easy to do
with `sgit(1)` like so:

```sh
sgit -o -n -e '/^## To build:/,$p' '[12][0-9][0-9][0-9]/*/README.md'
```

This would delete the lines up through but excluding '## To build:' in the
README.md files in subdirectories of directories that start with '1', or '9'
(the 2 being a typo) followed by 3 digits in the range of 0-9.

As there were a total of **321** of these files this saved a tremendous amount
of time and prevented very tedious work. As you can see, this tool is very
useful.


## Change references (**IN MEMORY ONLY** i.e. **WITHOUT in-place editing**) of the exact word `sed` (as in `\<sed\>`) in this file but only show changed lines

```sh
sgit -I -o -n -e 's/\<sed\>/used/p' README.md
```

## Print out matches of the EXACT word `sed` (as in `\<sed\>`) in all files under git control from the current working directory

This is a simpler way of running `git --no-pager grep -h -E '\<sed\>'|sed
's/^[0-9]*://g'` which itself might or might not be more complicated than it
needs to be:

```sh
sgit -I -o -n -e '/\<sed\>/p' .
```

## With tracing enabled, change references of `\<sed\>` to `used` in this file and save it:

```sh
sgit -e 's/\<sed\>/used/g' -x README.md
```


## With tracing enabled, change references of `\<sed\>` to `used`, duplicating the lines, in this file and save it:

```sh
sgit -e 's/\<sed\>/used/p' -x README.md
```

## Verbosely (level 1) change references of `\<sed\>` to `used` in this file and save it:

With verbosity level 1 it will show the commands run, both the `git ls-files
...` piped to `xargs` with `sed(1)`:


```sh
sgit -e 's/\<sed\>/used/g' -v 1 README.md
```

This might show:

```
debug[1]: about to run: /usr/bin/git ls-files README.md | /usr/bin/xargs /usr/bin/sed -i"" -e "s/\<sed\>/used/g"
```

## Verbosely (level 1) change references of `\<sed\>` to `used` in this file with a backup as `README.md.bak`

If you wish to just see the backup extension and the commands to be run, that is
`git ls-files ... | xargs ...`, use verbosity level 1:

```sh
$ sgit -i.bak -e 's/\<sed\>/used/g' -v 1 README.md
debug[1]: using backup extension: .bak
debug[1]: about to run: /usr/bin/git ls-files README.md | /usr/bin/xargs /usr/bin/sed -i".bak" -e "s/\<sed\>/used/g"
```

## Verbosely (level 2) change references of `\<sed\>` to `used` in this file with a backup as `README.md.bak`

With verbosity level 2 the above command, it will show the `sed(1)` commands (or
in this case command) and after each glob is processed it will show the glob
number and the number of globs remaining (assuming there is more than one):

```sh
$ sgit -i.bak -e 's/\<sed\>/used/g' -v 2 README.md
debug[2]: sed command: -e "s/\<sed\>/used/g"
debug[1]: using backup extension: .bak
debug[2]: found glob: 0
debug[1]: about to run: /usr/bin/git ls-files README.md | /usr/bin/xargs /usr/bin/sed -i".bak" -e "s/\<sed\>/used/g"
```

As there is only one glob it does not report there is another glob to go
through.


## Verbosely (level 2) change references of `\<sed\>` to `used` in this file with a backup as `README.md.bak` and a non-existent file

With verbosity level 2 the above command, with the added glob that does not
exist (`foo`), it will show the `sed(1)` commands (or in this case command) and
after each glob is processed it will show the number of globs remaining:

```sh
$ sgit -i.bak -e 's/\<sed\>/used/g' -v 2 README.md foo
debug[2]: sed command: -e "s/\<sed\>/used/g"
debug[1]: using backup extension: .bak
debug[2]: found glob: 0
debug[1]: about to run: /usr/bin/git ls-files README.md | /usr/bin/xargs /usr/bin/sed -i".bak" -e "s/\<sed\>/used/g"
debug[2]: found glob: 1
debug[2]: no files found with glob: "foo"
debug[2]: hint: do you need to use -0?
```

Here you observe that since no files were found for `foo` it reports this. If
you did not specify a verbosity level of 2 or greater then this will not be seen
as globs are not shown. In this case also it offers the hint that maybe one
needs the `-0` option to `sgit(1)` to use `git ls-files -z` though as noted
elsewhere, this is untested as I do not have access to any repo that has unsafe
characters in filenames.


## Verbosely (level 3) change references of `\<sed\>` to `used` in this file with a backup as `README.md.bak`

With verbosity of level 3 it will show even more information.

```sh
sgit -i.bak -e 's/\<sed\>/used/g' -v 3 README.md
```

With the command you would see something like:

```sh
debug[2]: sed command: -e "s/\<sed\>/used/g"
debug[2]: looping through all globs
debug[1]: using backup extension: .bak
debug[2]: found glob: 0
debug[1]: about to run: /usr/bin/git ls-files README.md | /usr/bin/xargs /usr/bin/sed -i".bak" -e "s/\<sed\>/used/g"
debug[2]: 0 remaining globs
```

Level 1 will not show how many globs remain after each operation.


## Verbosely (level 3) change references of `\<used\>` back to `sed` in this file with a backup as `README.md.bak`

```sh
sgit -i.bak -e 's/\<used\>/sed/g' -v 3 README.md
```

With that you would see something like:

```sh
$ sgit -i.bak -e 's/\<used\>/sed/g' -v3 README.md
ebug[2]: sed command: -e "s/\<used\>/sed/g"
debug[2]: looping through all globs
debug[1]: using backup extension: .bak
debug[2]: found glob: 0
debug[1]: about to run: /usr/bin/git ls-files README.md | /usr/bin/xargs /usr/bin/sed -i".bak" -e "s/\<used\>/sed/g"
debug[2]: 0 remaining globs
```


## Change `\<sed\>` to `used` but only if it's on the first line

```sh
sgit -e '1s/\<sed\>/used/g' README.md
```

and the title of this document would be:

```markdown
# sgit - run used on files under git control
```

Alternatively you could do one of:


```sh
sgit -e '1s/\<sed\>/u&/g' README.md
sgit -e '1s/\(\<sed\>\)/u\1/g' README.md
```

## Change `\<sgit\>` to `gits` but only if it's on the third line

```sh
sgit -e '3s/\<sgit\>/gits/g' README.md
```

## Change `\<sgit\>` to `gits` and then back to `sgit` but only if it's on the third line


```sh
sgit -e '3s/\<sgit\>/gits/g' -e '3s/\<gits\>/sgit/g' README.md
```

## Dry-run mode: **ONLY _SHOW_** files that would be modified rather than modify them

If you want to **ONLY _SEE_ FILES** that would be considered **WITHOUT
_touching_** them you can use the `-n` option like so:

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

**NOTE**: it is pointless to supply a `sed(1)` command in this case but you may do
so anyway; it is not required.

## Dry-run mode: **ONLY _SHOW_** sed commands with the files found rather than actually running sed on them

If you want to see the `sed(1)` command along with the files found **WITHOUT
_touching_** them you can use the `-n` option with a verbosity level greater
than or equal to 1 like so:

```sh
sgit -v 1 -n -e 's/foo/bar/g' .
```

This would show every file along with the sed command, `s/foo/bar/g`, which if used without
the `-n` would actually be run on each file found. For instance, the above
command might show:

```sh
$ sgit -v 1 -n -e 's/foo/bar/g' .
/usr/bin/sed -i -e "s/foo/bar/g" ".gitignore"
/usr/bin/sed -i -e "s/foo/bar/g" "CHANGES.md"
/usr/bin/sed -i -e "s/foo/bar/g" "Makefile"
/usr/bin/sed -i -e "s/foo/bar/g" "README.md"
/usr/bin/sed -i -e "s/foo/bar/g" "sgit"
/usr/bin/sed -i -e "s/foo/bar/g" "sgit.1"
```

If verbosity is 2 or 3 you would see respectively:

```sh
debug[2]: sed command: -e "s/foo/bar/g"
debug[2]: found glob: 0
/usr/bin/sed -i -e "s/foo/bar/g" ".gitignore"
/usr/bin/sed -i -e "s/foo/bar/g" "CHANGES.md"
/usr/bin/sed -i -e "s/foo/bar/g" "Makefile"
/usr/bin/sed -i -e "s/foo/bar/g" "README.md"
/usr/bin/sed -i -e "s/foo/bar/g" "sgit"
/usr/bin/sed -i -e "s/foo/bar/g" "sgit.1"
```

and

```sh
debug[2]: sed command: -e "s/foo/bar/g"
debug[2]: looping through all globs
debug[2]: found glob: 0
/usr/bin/sed -i -e "s/foo/bar/g" ".gitignore"
/usr/bin/sed -i -e "s/foo/bar/g" "CHANGES.md"
/usr/bin/sed -i -e "s/foo/bar/g" "Makefile"
/usr/bin/sed -i -e "s/foo/bar/g" "README.md"
/usr/bin/sed -i -e "s/foo/bar/g" "sgit"
/usr/bin/sed -i -e "s/foo/bar/g" "sgit.1"
debug[2]: 0 remaining globs
```

If you were to specify more than one command you might see something like:

```sh
$ sgit -n -v 3 -e 's/foo/bar/g' -e 's/FOO/BAR/g' .
debug[2]: sed command: -e "s/foo/bar/g"
debug[2]: sed command: -e "s/FOO/BAR/g"
debug[2]: looping through all globs
debug[2]: found glob: 0
/usr/bin/sed -i -e "s/foo/bar/g" ".gitignore"
/usr/bin/sed -i -e "s/FOO/BAR/g" ".gitignore"
/usr/bin/sed -i -e "s/foo/bar/g" "CHANGES.md"
/usr/bin/sed -i -e "s/FOO/BAR/g" "CHANGES.md"
/usr/bin/sed -i -e "s/foo/bar/g" "Makefile"
/usr/bin/sed -i -e "s/FOO/BAR/g" "Makefile"
/usr/bin/sed -i -e "s/foo/bar/g" "README.md"
/usr/bin/sed -i -e "s/FOO/BAR/g" "README.md"
/usr/bin/sed -i -e "s/foo/bar/g" "sgit"
/usr/bin/sed -i -e "s/FOO/BAR/g" "sgit"
/usr/bin/sed -i -e "s/foo/bar/g" "sgit.1"
/usr/bin/sed -i -e "s/FOO/BAR/g" "sgit.1"
debug[2]: 0 remaining globs
```

Observe how it loops through each `sed(1)` command. This is to workaround some
versions of `sed(1)` like that of macOS (and presumably BSD) that have a missing
feature (it is no longer known what exactly that feature).


## Test `sed` command or commands without doing anything else

If you want to verify that there is no syntax error in the `sed` commands you
can do so with the `-t` option. If there is an error in syntax the error message
comes not from the script but rather `sed` so you will have to parse the
sometimes cryptic `sed` error messages.

With verbosity level >= 1 it will show each `sed` command that is being tested
before testing it.

If there is no error no output will be displayed unless verbosity is high enough
to show the command being tested and the `OK` status. If no `sed` commands have
an error the exit code will be 0.

If there is an error the `sed` error will be shown, either along with the `sed`
command itself or just the error message. In any event if any `sed` command has
an error it will exit with a non-zero value.

Here are several examples showing this feature.

These first ones have a sed syntax error:

```sh
$ sgit -t -e 's'
sed: -e expression #1, char 2: unterminated `s' command
$ sgit -t -e '1p 1p'
sed: -e expression #1, char 5: extra characters after command
$ sgit -t -e -e 's/foo/'
sed: -e expression #1, char 2: unknown command: `-'
```

This next one has two `sed` commands one of which has a syntax error. Since we
have more than one command let's also specify `-v 1` to show which command has
the problem and which one does not:

```sh
$ sgit -v 1 -t -e 's/foo//g' -e 's/foo/'
testing: 'sed s/foo//g': OK
testing: 'sed s/foo/': /usr/bin/sed: -e expression #1, char 6: unterminated `s' command
```

This example has two `sed` commands both of which have an error:

```sh
$ sgit -v 1 -t -e 's/foo' -e 's/foo/'
testing: 'sed s/foo': /usr/bin/sed: -e expression #1, char 5: unterminated `s' command
testing: 'sed s/foo/': /usr/bin/sed: -e expression #1, char 6: unterminated `s' command
```

Finally here are two sets of two examples with no syntax errors, the first set
showing the `sed` commands and the second one not showing it. In each set the
first invocation with just one `sed` command and the second with two.


```sh
$ sgit -v 1 -t -e 's/foo/bar/g'
testing: 'sed s/foo/bar/g': OK

$ sgit -t -v 1 -e 's/foo/bar/g' -e 's/bar/baz/g'
testing: 'sed s/foo/bar/g': OK
testing: 'sed s/bar/baz/g': OK
```

As noted above if you don't want any output on no errors then keep verbosity
level at 0 like:

```sh
$ sgit -t -e 's/foo/bar/g'
$ sgit -t -e 's/foo/bar/g' -e 's/bar/baz/g'
$
```

Of course, as shown earlier, if either of them have an error it will print out
the error via `sed(1)` itself:

```sh
$ sgit -t -e 's'
/usr/bin/sed: -e expression #1, char 1: unterminated `s' command
$ sgit -t -e 's/e/c' -e 's/e/c/g' -e 's///'
/usr/bin/sed: -e expression #1, char 5: unterminated `s' command
/usr/bin/sed: -e expression #1, char 0: no previous regular expression
```

which of course is not all that useful.

## Show `sed(1)` path and options used along with just the files that would be acted on (dry-mode)

If you want to see what the options are then specify a verbosity level of 4 or
greater:

```sh
debug[4]: sed: /usr/bin/sed
debug[4]: backup extension: ''
debug[4]: in-place editing enabled
debug[4]: test mode disabled
debug[4]: trace mode disabled
debug[2]: sed command: -e "s///g"
debug[2]: looping through all globs
debug[2]: found glob: 0
/usr/bin/sed -i -e "s///g" "README.md"
debug[2]: 1 remaining glob
debug[2]: found glob: 1
/usr/bin/sed -i -e "s///g" "sgit"
debug[2]: 0 remaining globs
```


## Surround specific lines with `**` except if they end in `<br>` in which case add the `**` **BEFORE** the `<br>` at the end of the line

In the [IOCCC temporary website](https://github.com/ioccc-src/temp-test-ioccc)
repo we had code blocks of the form:

```
STATUS: foo bar baz
```

and sometimes:

```
STATUS: foo bar baz
STATUS: zab rab oof
```

but it was decided it would be better if these were in a block quote (starting
with `>`). In the case where there was more than one `STATUS` line we would
obviously need a `<br>` at the end.

Now I had started without adding the `**`s (as an oversight) and I did add the
`<br>` in the cases there were additional lines so what could I do to fix not
only those but the ones that I have not done yet?

The following is what I did:

```sh
sgit -e 's/\(STATUS.*\)/> \*\*\1\*\*/g' \
    -e 's/> > \*\*STATUS/> **STATUS/g' \
    -e 's/<br>\*\*/**<br>/g' '*README.md'
```

This would address lines that already (now) started with the `>` but other lines
that just have `STATUS` at the start (or with spaces as in our case) and if the
lines ended with `<br>` it would put the `<br>` **after** the `**` at the final
step.

After this all I had to do was to remove the code block formatting (the three
backticks on the line before the first `STATUS` and the line after the last line
that started with `STATUS` (or now started with `> STATUS`)) and of course
(since I didn't address this in the command remove the spaces in front of the
`>` but since I had to edit the files manually anyway this was not a problem.

An added `-e ...` or additional `sgit` command might be:

```
-e 's/    > \*\*STATUS/> **STATUS/g'
```

since we start lines in the code blocks with four spaces.

A caveat here, of course, is that I did this in steps (in order to document),
but the idea is here anyway.


## Changing the paths of tools in a file

Previously for output in examples I used non-standard paths for macOS (because
of MacPorts). This meant this file had paths like:

```
/opt/local/libexec/gnubin/sed -i -e "s/foo/bar/g" ".gitignore"
/opt/local/libexec/gnubin/sed -i -e "s/foo/bar/g" "CHANGES.md"
/opt/local/libexec/gnubin/sed -i -e "s/foo/bar/g" "Makefile"
/opt/local/libexec/gnubin/sed -i -e "s/foo/bar/g" "README.md"
/opt/local/libexec/gnubin/sed -i -e "s/foo/bar/g" "sgit"
/opt/local/libexec/gnubin/sed -i -e "s/foo/bar/g" "sgit.1"
```

and so on.

To fix this so that they are `/usr/bin/sed`, `/usr/bin/git` and `/usr/bin/xargs`
I did:

```sh
sgit -e 's,/opt/local/libexec/gnubin/\(sed\|xargs\),/usr/bin/\1,g' -e 's,/opt/local/bin/\(git\),/usr/bin/\1,g' .
```

This shows the capture of the command names (basenames) and changes their paths
(dirname) entirely to be `/usr/bin`.

## Make Entings

<hr>
Disclaimer: okay this is mostly a joke but as it still shows another use of the
tool I have put it in.
<hr>

By accident (I did not even realise all the options were there that spell the
word [ent](https://www.glyphweb.com/arda/e/ents.html)) in the `getopts` line in
the script spells out `ent` like:

```
e:nt
```

There are no [Entings](https://www.glyphweb.com/arda/e/entings.html) (young
Ents) in centuries due to no more
[Entwives](https://www.glyphweb.com/arda/e/entwives.html) but let's help the
Ents out a bit, shall we? :-)

This changes the `e:nt` to `entings` (all of the options do exist but we can't
duplicate the `n` so no way to have `enting` sadly, otherwise I assure you that
it would spell it out):

```sh
sgit -I -e 's/e:nt/entings/g' sgit | grep entings
```

That would show the following:

```sh
while getopts :hVv:xIi:o:s:g:X:entings0 flag; do
```

(Of course even if we could duplicate the `n` it would be invalid as the other
options exist earlier in the `getopts` and we do not have the required `:` for
the ones that need it. But as this is just a joke and we disable in-place
editing it does not matter.)



# Installing

If you wish to install it (which would be useful since you must run the script
in a git repo and the odds are you won't be running it in this repo :-) )  you
may either copy it to a place in your path or if you have `make` installed you
can just run `make install` either as root or via `sudo` like:

```sh
sudo make install
```

If for some reason, for instance system policy, you do not wish to install to
`/usr/local`, you can override this with the standard `PREFIX` variable. For
instance, to make the `PREFIX` `/usr` so the `sgit` is installed in
`/usr/bin/sgit` and the man page, `sgit.1`, is installed in
`/usr/share/man/man1`, do:

```sh
sudo make PREFIX=/usr install
```

# Uninstalling

If you need to uninstall the tool you can do so with the `make uninstall` rule
either directly as root or sudo:

```sh
sudo make uninstall
```

This will remove the man page from the man page directory and sgit from the bin
directory.

Remember that if you have redefined the `PREFIX` as described above that you
will have to specify that same `PREFIX`!


# Limitations

If you specify invalid `sed` commands obviously there will be problems. If you
specify invalid `sed` options there will possibly be problems as well. As noted
earlier you can test the `sed` commands.


# Bugs

None known (yet?).

# Inspiration and historical context of `sgit`

It has been a persistent problem for me that I need to edit files under git
control and `sed` is the obvious way to go about it.

Working on the [IOCCC mkiocccentry](https://github.com/ioccc-src/mkiocccentry)
and the [IOCCC temporary website](https://github.com/ioccc-src/temp-test-ioccc)
repos (and in particular the latter) is what inspired me to finally do something
about it. The latter repo will eventually be merged into the [IOCCC winner
repo](https://github.com/ioccc-src/winner) which is the actual [IOCCC
website](https://www.ioccc.org).

# Script history

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

With version `1.0.0-7 11-08-2024` the options to specify a different `git` (`-g
git`) and xargs (`-X xargs`) were added and double quotes also surround the
`sed(1)` commands and the files in debug output (mostly useful for those who
for some odd reason have files with spaces in their names i.e. the use of the
`-0` option).


# Other thoughts

Pull requests are welcome but I think it's mostly in a good enough state where
this will probably generally not be needed.

# Dedications and thanks

This is dedicated to the [IOCCC](https://www.ioccc.org), the [IOCCC
judges](https://www.ioccc.org/judges.html) especially ([Landon Curt
Noll](http://www.isthe.com/chongo/)) for the friendship, telling me stories and
jokes, telling me history of different things about Unix, C and other things and
giving me the wonderful opportunity to help so much with the IOCCC - prompting
me to write this tool - and above all my dear sweet Mum Dianne and my wonderful
cousin Dani.

Thanks go to Landon for the suggesting of `-n` and what ended up as the test
option `-t` and for testing the script and even making use of it in his [calc
repo](https://github.com/lcn2/calc), verifying that it really does work well not
only for me but others as well.
