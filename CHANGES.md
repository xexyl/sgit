# Version 0.0.13-2 03-10-2023

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
