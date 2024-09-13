#!/usr/bin/env make

#############
# utilities #
#############
CHECKNR= checknr
INSTALL= install
MAKE= make
RM= rm
SGIT= sgit
SHELL= bash
SHELLCHECK= shellcheck

# The name of this directory
#
# This value is used to print the generic name of this directory
# so that various echo statements below can use this name
# to help distinguish themselves from echo statements used
# by Makefiles in other directories.
#
OUR_NAME= sgit

#######################
# install information #
#######################

# installing variables
#
DESTDIR= ${PREFIX}/bin
MAN1_DIR= ${PREFIX}/share/man/man1
TARGETS= ${SGIT}
MAN1_TARGETS= sgit.1
ALL_MAN_TARGETS= ${MAN1_TARGETS}

# INSTALL_V=				install w/o -v flag (quiet mode)
# INSTALL_V= -v				install with -v (debug / verbose mode)
#
#INSTALL_V=
INSTALL_V= -v

# where to install
#
# Default PREFIX is /usr/local so binaries would be installed in /usr/local/bin,
# libraries in /usr/local/lib etc. If one wishes to override this, say
# installing to /usr, they can do so like:
#
#	make PREFIX=/usr install
#
PREFIX= /usr/local

# uninstalling variables
#

# RM_V=					rm w/o -v flag (quiet mode)
# RM_V= -v				rm with -v (debug / verbose mode)
#
#RM_V= -v
RM_V=


all:
	@:

.PHONY: all clean clobber install uninstall test check_man

clean:
	@:

clobber: clean
	@:

# install sgit and man page
install:
	@echo
	@echo "${OUR_NAME}: make $@ starting"
	@echo
	${INSTALL} ${INSTALL_V} -d -m 0775 ${DESTDIR}
	${INSTALL} ${INSTALL_V} -d -m 0775 ${MAN1_DIR}
	${INSTALL} ${INSTALL_V} -m 0755 ${TARGETS} ${DESTDIR}
	${INSTALL} ${INSTALL_V} -m 0444 ${MAN1_TARGETS} ${MAN1_DIR}
	@echo
	@echo "${OUR_NAME}: make $@ ending"

# uninstall sgit and man page
#
uninstall:
	@echo
	@echo "${OUR_NAME}: make $@ starting"
	@echo
	${RM} ${RM_V} -f ${DESTDIR}/sgit
	${RM} ${RM_V} -f ${MAN1_DIR}/sgit.1
	@echo
	@echo "${OUR_NAME}: make $@ ending"

# inspect and verify sgit
#
shellcheck: ${SGIT} .shellcheckrc
	@echo
	@echo "${OUR_NAME}: make $@ starting"
	@echo
	@if ! type -P ${SHELLCHECK} >/dev/null 2>&1; then \
	    echo 'The ${SHELLCHECK} command could not be found.' 1>&2; \
	    echo 'The ${SHELLCHECK} command is required to run the $@ rule.'; 1>&2; \
	    echo ''; 1>&2; \
	    echo 'See the following GitHub repo for ${SHELLCHECK}:'; 1>&2; \
	    echo ''; 1>&2; \
	    echo '    https://github.com/koalaman/shellcheck.net'; 1>&2; \
	    echo ''; 1>&2; \
	    echo 'Or use the package manager in your OS to install it.' 1>&2; \
	    exit 1; \
	else \
	    echo "${SHELLCHECK} -f gcc -- ${TARGETS}"; \
	    ${SHELLCHECK} -f gcc -- ${TARGETS}; \
	    EXIT_CODE="$$?"; \
	    if [[ $$EXIT_CODE -ne 0 ]]; then \
		echo "make $@: ERROR: CODE[1]: $$EXIT_CODE" 1>&2; \
		exit 1; \
	    fi; \
	fi
	@echo
	@echo "${OUR_NAME}: make $@ ending"

test: check_man shellcheck
	@:

check_man: ${ALL_MAN_TARGETS}
	@echo
	@echo "${OUR_NAME}: make $@ starting"
	@echo
	-@if ! type -P ${CHECKNR} >/dev/null 2>&1; then \
	    echo 'The ${CHECKNR} command could not be found.' 1>&2; \
	    echo 'The ${CHECKNR} command is required to run the $@ rule.' 1>&2; \
	    echo ''; 1>&2; \
	    echo 'See the following GitHub repo for ${CHECKNR}:'; 1>&2; \
	    echo ''; 1>&2; \
	    echo '    https://github.com/lcn2/checknr' 1>&2; \
	    echo ''; 1>&2; \
	    echo 'Or use the package manager in your OS to install it.' 1>&2; \
	else \
	    echo "${CHECKNR} -c.BR.SS.BI.IR.RB.RI ${ALL_MAN_TARGETS}"; \
	    ${CHECKNR} -c.BR.SS.BI.IR.RB.RI ${ALL_MAN_TARGETS}; \
	fi
	@echo
	@echo "${OUR_NAME}: make $@ ending"
