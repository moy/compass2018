#! /usr/bin/make -f
#
#	Architecture, Systems, Networks 2017 course at ENS Lyon
#	An emulator and debugger for the fictional processor
#
#---

target	= emu
src	= $(wildcard src/*.c)
obj	= $(src:src/%=build/%.o)

# _DEFAULT_SOURCE is for endian.h
cflags	= -Wall -Wextra -std=c11 -I include -D_DEFAULT_SOURCE -O0 -g
dflags	= -MT $@ -MMD -MP -MF $(@:.o=.d)
lflags	= $(cflags) -lncurses

# On some platforms where binutils does not automatically link in libtinfo as a
# dependency to ncurses, it may be required to link it manually.
# On some others, the libtinfo doesn't exist. Hence this switch.
ifdef USE_LIBTINFO
lflags += -ltinfo
endif

# Disable SDL-related functionalities and link without SDL.
ifdef NO_SDL
cflags += -D NO_SDL
else
lflags += -lSDL2
endif

$(target): $(obj)
	gcc $^ -o $@ $(lflags)

build/%.o: src/% | build
	gcc -c $< -o $@ $(cflags) $(dflags)

build:
	@ mkdir -p $@

# Dependency files. Force building when they don't exist, and keep them.
build/%.d:;
.PRECIOUS: build/%.d
# Include header dependencies
-include $(wildcard build/*.d)

clean:
	@ rm -f build/*.o
distclean: clean
	@ rm -rf build
	@ rm -f $(target)

.PHONY: clean distclean
