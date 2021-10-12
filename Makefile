NAME=DLL

all: DLL

DLL: DLL.asm
	nasm -f elf -F dwarf -g DLL.asm
	gcc -g -m32 -o DLL DLL.o
	rm -rf DLL.o
