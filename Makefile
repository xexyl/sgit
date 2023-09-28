#!/usr/bin/env make

#############
# utilities #
#############
INSTALL= install
MAKE= make
SHELL= bash
SHELLCHECK= shellcheck

#######################
# install information #
#######################
DESTDIR= /usr/local/bin
MAN1_DIR= /usr/local/share/man/man1
TARGETS= sgit
MAN1_TARGETS= sgit.1

all:
	@:

.PHONY: all install

install:
	${INSTALL} -d -m 0775 ${DESTDIR}
	${INSTALL} -d -m 0775 ${MAN1_DIR}
	${INSTALL} -m 0755 ${TARGETS} ${DESTDIR}
	${INSTALL} -m 0444 ${MAN1_TARGETS} ${MAN1_DIR}

shellcheck: sgit
	@${SHELLCHECK} sgit
