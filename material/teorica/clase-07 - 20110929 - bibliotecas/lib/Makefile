# Compiler/Linker/dynamic linker
CC = gcc
LD = gcc

# PIC  position-independent code para bibliotecas compartidas
CFLAGS = -fPIC

# Flags para crear una dynamic library.
DYNLINKFLAGS = -shared

# borrado
RM = /bin/rm -f

# library's object files.
LIB_OBJS = util_uno.o util_dos.o util_tres.o

# library's archive file
LIB_FILE = libutiles.so

# al compilar el main
# '-L.' indica donde buscar las libraries
# ademas de los directorios habituales de system library.
LIBS = -L. -lutiles

# program's object files
PROG_OBJS = main.o

# program's executable
PROG = prog

# top-level rule
all: $(LIB_FILE) $(PROG)

$(PROG): $(PROG_OBJS)
	$(LD) $(LDFLAGS) $(PROG_OBJS) $(LIBS) -o $(PROG)

# crear la  library
$(LIB_FILE): $(LIB_OBJS)
	$(LD) $(DYNLINKFLAGS) $(LIB_OBJS) -o $(LIB_FILE)

# compilar en object files. $< es el source file (automatico)
%.o: %.c
	$(CC) $(CFLAGS) -c $<


# clean 
clean:
	$(RM) $(PROG_OBJS) $(PROG) $(LIB_OBJS) $(LIB_FILE)

# clean  programa y object files, pero no la library.
cleanprog:
	$(RM) $(PROG_OBJS) $(PROG)

# clean  library y todos los object files 
cleanlib:
	$(RM) $(LIB_OBJS) $(LIB_FILE)

# clean  solo library's object files 
cleanlibobjs:
	$(RM) $(LIB_OBJS)
