# $Id: makefile.in,v 1.12 2012/03/18 15:38:59 tom Exp $
# Makefile-template for 'bcpp'

THIS		= bcpp

#### Start of system configuration section. ####

srcdir		= .


CXX		= g++
CXXFLAGS	= -m32
EXTRA_CXXFLAGS	= -W -Wall -Wabi -fabi-version=0 -Woverloaded-virtual -Wsign-promo -Wsynth -Wold-style-cast -Wcast-align -Wcast-qual -Wmissing-prototypes -Wpointer-arith -Wshadow -Wundef -Weffc++

INSTALL		= /usr/bin/install -c
INSTALL_PROGRAM	= ${INSTALL}
INSTALL_DATA	= ${INSTALL} -m 644
INSTALL_SCRIPT	= ${INSTALL}

LINK		= $(CXX)
LIBS		= 
LDFLAGS		= 

prefix		= /usr/local
exec_prefix	= ${prefix}

bindir		= ${exec_prefix}/bin

BINDIR		= $(DESTDIR)$(bindir)

x		= 
o		= .o

#### End of system configuration section. ####

SHELL		= /bin/sh

OBJS	= \
	bcpp$o \
	anyobj$o \
	backup$o \
	baseq$o \
	cmdline$o \
	config$o \
	debug$o \
	execsql$o \
	hanging$o \
	html$o \
	stacklis$o \
	strings$o \
	tabs$o \
	verbose$o

CPPFLAGS	= -I. -I$(srcdir) \
		-DVERSION=\"`cat $(srcdir)/../VERSION`\" \
		-DHAVE_CONFIG_H # -DDEBUG -DDEBUG2

PROG	= $(THIS)$x

.SUFFIXES: .cpp $o

.cpp$o:
	
	$(CXX) $(CXXFLAGS) $(EXTRA_CXXFLAGS) $(CPPFLAGS) -c $< -o $@

all:	$(PROG)

$(PROG): $(OBJS)
	$(LINK) $(LDFLAGS) -o $(PROG) $(OBJS) $(LIBS)

install: all installdirs
	$(INSTALL_PROGRAM) $(PROG) $(BINDIR)/$(PROG)
	$(INSTALL_SCRIPT) cb++ $(BINDIR)/cb++

installdirs:
	mkdir -p $(BINDIR)

uninstall:
	rm -f $(BINDIR)/$(PROG)
	rm -f $(BINDIR)/cb++

mostlyclean:
	rm -f *$o core *~ *.out *.BAK *.atac

clean: mostlyclean
	rm -f $(PROG)

distclean: clean
	rm -f makefile config.log config.cache config.status autoconf.h

realclean: distclean
	rm -f tags TAGS # don't remove configure!

check:	$(PROG)
	$(SHELL) ./run-test

tags:
	ctags *.cpp *.h

TAGS:
	etags *.cpp *.h

$(OBJS):	autoconf.h bcpp.h
