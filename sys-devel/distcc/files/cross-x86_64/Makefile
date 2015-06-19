# dist-utils Makefile
# Copyright © 2009 Andrew Savchenko
#
# This file is part of distcc-utils.
#
# distcc-utils is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation
#
# distcc-utils is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License version 3 for more details.
#
# You should have received a copy of the GNU General Public License version 3
# along with distcc-utils. If not, see <http://www.gnu.org/licenses/>.
#

CC ?= gcc
CFLAGS += --std=gnu99 -Wall -D_GNU_SOURCE
LDFLAGS ?= -Wl,-O1 $(CFLAGS)

SRCS = gcc.c g++.c c++.c

BINS = $(SRCS:.c=)

%.c: common.h

all: $(BINS)

tags:
	ctags *.c

clean:
	rm -f $(BINS)

distclean: clean
	rm -f tags

.PHONY: all tags clean distclean
