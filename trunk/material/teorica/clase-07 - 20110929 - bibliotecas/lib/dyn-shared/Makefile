# Compiler/Linker/dynamic linker
CC = gcc
LD = gcc

# Codigo independiente de la posicion
CFLAGS = -fPIC

# Flags para dynamic library.
DYNLINKFLAGS = -shared -nostdlib
# on some platforms, use '-G' instead.

#borrando
RM = /bin/rm -f

# program's object files
PROG_OBJS = main.o

# program's executable
PROG = prog

# libraries to link with the program during compile time.
LIBS = -ldl

# shared library files
LIB_FILES = lib1.so lib2.so lib3.so

# shared libraries object files
LIB_OBJS = lib1.o lib2.o lib3.o

# top-level rule
all: $(LIB_FILES) $(PROG)

$(PROG): $(PROG_OBJS)
	$(LD) $(LDFLAGS) $(PROG_OBJS) $(LIBS) -o $(PROG)

# crear las librarys
lib1.so: lib1.o
	$(LD) $(DYNLINKFLAGS) $< -o $@

lib2.so: lib2.o
	$(LD) $(DYNLINKFLAGS) $< -o $@

lib3.so: lib3.o
	$(LD) $(DYNLINKFLAGS) $< -o $@

# compilar
%.o: %.c Makefile
	$(CC) $(CFLAGS) -c $<


clean:
	$(RM) $(PROG_OBJS) $(PROG) $(LIB_OBJS) $(LIB_FILES)

cleanprog:
	$(RM) $(PROG_OBJS) $(PROG)

cleanlib:
	$(RM) $(LIB_OBJS) $(LIB_FILES)


cleanlibobjs:
	$(RM) $(LIB_OBJS)
