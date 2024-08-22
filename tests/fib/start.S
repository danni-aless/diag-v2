.section .text.init;
.align  6;
.globl _start;

_start:
	# Initialize stack pointer
	la sp, 0x3ff8
	
	call main;