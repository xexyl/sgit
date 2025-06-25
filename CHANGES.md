# Version 1.0.4 25-06-2025

Improve check if one is inside a git repo.


# Version 1.0.3 06-11-2024

`sgit` no longer acts on symlinks as this causes a type change in git, and if
someone wants the contents of a symlink in git changed, they can edit the target
file instead.


# Version 1.0.0-8 29-08-2024

Fix bug that showed up if a glob did not find any file in the repo.


# Version 1.0.0-7 11-08-2024

New options and debug output improvements

The option `-g git` allows one to specify a git path.

The option `-X xargs` allows one to specify an xargs path.

The git and xargs commands are now in variables ($GIT and $XARGS
respectively).

When showing debug output filenames are double quoted (in case one has
spaces in filenames, unsafe though it is) and the same for the sed
commands (as it can be misleading otherwise especially if there are
spaces in a sed command).


# Versions in between the below and the above

Unfortunately I forgot that I had this file so one will have to check the git
log as I deem it not that important to try and rectify.


# Version 1.0.0-1 06-10-2023

Add `-t` option to test each `sed` command specified. This option does not make
use of globs and it does not use `sed` options.

If `-v 1` (or greater than 1) is used then it will show what `sed` command is
about to be tested. In that case if all is okay it will append 'OK'; otherwise
what `sed` prints will be appended. If `-v 0` (or `-v` not used) it will not
show anything if no errors and otherwise it will show whatever error `sed`
shows, one per `sed` command.

# Version 0.0.17-1 04-10-2023

Check that directory is a git repository before anything else. This saves the
user from having to get a command line right (if they didn't or didn't provide
one) only to find out it's not a git repository.

It does print the usage in this case followed by the error.

# Version 0.0.16-1 03-10-2023

It is not strictly correct to say that use of `-n` implies `-I` but rather that
the use of `-n` means `sed(1)` will not be used at all. This has been clarified
in the man page, the README.md and the script itself.

# Version 0.0.15-1 03-10-2023

Fix a case of `-n` with `-v` greater than or equal to 1 where the files were not
printed along with the `sed` command.

Added examples to README.md file.


# Version 0.0.14-1 03-10-2023

Add support of `-n` option. Depending on the verbosity this option will print
the files that WOULD BE considered if `-n` was not specified OR otherwise show
the sed commands that would be done on the files if `-n` was not specified.

Moved error messages to AFTER the usage string when an error is encountered in
the command line. There is no usage printed if the directory the tool is run in
is not a git repository and that's how it's always been as I don't see the
purpose of showing the usage when it's not a git repository: at least not at
this point.

Update man page with typo fixes (missing option description) and add the new
`-n` option.
