#!/usr/bin/env make

#############
# utilities #
#############
CHECKNR= checknr
INSTALL= install
MAKE= make
RM= rm
SHELL= bash
SHELLCHECK= shellcheck

#######################
# install information #
#######################
DESTDIR= /usr/local/bin
MAN1_DIR= /usr/local/share/man/man1
TARGETS= sgit
MAN1_TARGETS= sgit.1
ALL_MAN_TARGETS= ${MAN1_TARGETS}

all:
	@:

.PHONY: all clean clobber install uninstall test

clean:
	@:

clobber: clean
	@:

install:
	${INSTALL} -d -m 0775 ${DESTDIR}
	${INSTALL} -d -m 0775 ${MAN1_DIR}
	${INSTALL} -m 0755 ${TARGETS} ${DESTDIR}
	${INSTALL} -m 0444 ${MAN1_TARGETS} ${MAN1_DIR}

uninstall:
	${RM} -vf ${DESTDIR}/sgit
	${RM} -vf ${MAN1_DIR}/sgit.1

shellcheck: sgit
	@echo "Running shellcheck on sgit."
	@${SHELLCHECK} sgit
	@echo "shellcheck found no problems."

test:
	${MAKE} check_man
	${MAKE} shellcheck

check_man: ${ALL_MAN_TARGETS}
	@if ! type -P ${CHECKNR} >/dev/null 2>&1; then \
            echo 'The ${CHECKNR} command could not be found.' 1>&2; \
            echo 'The ${CHECKNR} command is required to run the $@ rule.' 1>&2; \
            echo ''; 1>&2; \
            echo 'See the following GitHub repo for ${CHECKNR}:'; 1>&2; \
            echo ''; 1>&2; \
            echo '    https://github.com/lcn2/checknr' 1>&2; \
            echo ''; 1>&2; \
            echo 'Or use the package manager in your OS to install it.' 1>&2; \
        else \
	    echo "Running checknr on man pages."; \
            ${CHECKNR} -c.BR.SS.BI.IR.RB.RI ${ALL_MAN_TARGETS}; \
	    echo "checknr found no problems."; \
	fi
