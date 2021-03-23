# make         : build in release mode in $(RELEASEDIR).
# make release : build in release mode in $(RELEASEDIR).
# make debug   : build in debug mode in $(DEBUGDIR).
# make run     : run debug build.
# make gdb     : run debug build under gdb.
# make CI      : build in debug mode in $(DEBUGDIR) for CI.
# make clean   : clean up along with $(BUILDDIR).

# make run_release : run release build.


# toolchain:
CC  = gcc
CXX = g++
AS  = nasm
DBG = gdb

# COMPILER (change here):
COMPILER = $(CC)
LINKER   = $(COMPILER)

# c/c++ release optimization level:
OPT   = 2

# outputs:
BIN = template.elf64

# output dirs:
BUILDDIR   := build
RELEASEDIR  = $(BUILDDIR)/release
DEBUGDIR    = $(BUILDDIR)/debug

OUTDIR    := $(RELEASEDIR)

# srcs:
SRCDIR   = src
C_SRC   := $(shell find ./$(SRCDIR)/ -type f -name '*.c')
CPP_SRC := $(shell find ./$(SRCDIR)/ -type f -name '*.cpp')
ASM_SRC := $(shell find ./$(SRCDIR)/ -type f -name '*.asm')
#CPP_SRC := $(shell find ./$(SRCDIR)/ -type d \( -path ./excludedir1 -o -path ./excludedir2 -o -path ./excludedir3 \) -prune -false -o -name '*.cpp')

# objs:
OBJ := ${C_SRC:.c=.o} ${ASM_SRC:.asm=.o} ${CPP_SRC:.asm=.o}


# toolchain flags:
CFLAGS := -O$(OPT)					\
		  -m64						\
		  -std=c17					\
		  -Wall						\
		  -Wextra					\
		  -pedantic-errors			\
		  -pipe						\
		  -Isrc/inc

CDEBUGFLAGS := -g					\
			   -O0					\
			   -m64					\
			   -std=c17				\
			   -Wall				\
			   -Wextra				\
			   -pedantic-errors		\
			   -pipe				\
			   -Isrc/inc

CXXFLAGS := -O$(OPT)				\
			-m64					\
		    -std=c++20				\
		    -Weffc++				\
		    -Wall					\
		    -Wextra					\
		    -pedantic-errors		\
		    -pipe					\
		    -Isrc/inc


CXXDEBUGFLAGS := -g					\
				 -O0				\
				 -m64				\
		   		 -std=c++20			\
		   		 -Weffc++			\
		   		 -Wall				\
		   		 -Wextra			\
		   		 -pedantic-errors 	\
		   		 -pipe				\
		   		 -Isrc/inc

ASMFLAGS := -O0						\
		    -f elf64

ASMDEBUGFLAGS := -O0				\
		    	 -f	elf64			\
		    	 -g					\
				 -F dwarf

LDFLAGS := -O$(OPT)					\
		   -m64						\
		   -no-pie

LDDEBUGFLAGS := -O0				 	\
				-m64		 		\
				-g			 		\
		  		-no-pie


# START:
all : release
	@echo "\nOutput: ./$(RELEASEDIR)/$(BIN)"


# build the application:
release : dirs_release link
	rm -rf $(shell find ./$(SRCDIR)/ -type f -name '*.o')
	@echo "\nRELEASE: DONE!"

# gen release build folder:
dirs_release:
	$(eval OUTDIR   = $(RELEASEDIR))
	mkdir -p $(BUILDDIR)
		mkdir -p $(RELEASEDIR)

# gen debug build folder:
dirs_debug:
	$(eval OUTDIR   = $(DEBUGDIR))
	mkdir -p $(BUILDDIR)
		mkdir -p $(DEBUGDIR)

# build the application:
test  : debug
debug : dirs_debug prep_debug link
	@echo "\nDEBUG: DONE!"
	@echo "\nOutput: ./$(DEBUGDIR)/$(BIN)"

prep_debug :
	$(eval CFLAGS   = $(CDEBUGFLAGS))
	$(eval CXXFLAGS = $(CXXDEBUGFLAGS))
	$(eval LDFLAGS  = $(LDDEBUGFLAGS))
	$(eval ASMFLAGS = $(ASMDEBUGFLAGS))

# link the application:
link : $(OBJ)
	$(LINKER) $(LDFLAGS) $^ -o $(OUTDIR)/$(BIN)

# compile .c:
%.o : %.c
	$(COMPILER) $(CFLAGS) -c $< -o $@

# compile .cpp:
%.o : %.cpp
	$(COMPILER) $(CXXFLAGS) -c $< -o $@

# compile .asm:
%.o : %.asm
	$(COMPILER) $(ASMFLAGS) -c $< -o $@


# clean:
clear : clean
clean:
	rm -rf $(BUILDDIR)
	rm -rf $(shell find ./$(SRCDIR)/ -type f -name '*.o')


# CI:
ci : debug
ci_clean : clean


# run debug build:
testrun: run
testrun: run_debug
run:
	clear
	@./$(DEBUGDIR)/$(BIN)

# run release build:
run_release:
	clear
	@./$(RELEASEDIR)/$(BIN)

# run debug build under gdb:
gdb :
	clear
	@gdb ./$(DEBUGDIR)/$(BIN)
