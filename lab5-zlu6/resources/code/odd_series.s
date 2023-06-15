#---------------------------------------------------------------
# This simple program is used in Lab_BasicBlock to demonstrate
# how a Control Flow Graph is created.
#
# Register Usage:
#
#       a0: contains the number to be converted
#       a1: contains the address of the output buffer
#
#---------------------------------------------------------------

	.text
main:
# print "p = "
        la      $a0, str_p      # load a0 with the address of the char
        li      $v0, 4          # invoke system call no. 4
        syscall                 # make the actual call

# print p	
	li    $a0, 20        # p <-- 20
	li    $v0, 4
	syscall              # print p

# print a newline character
        la      $a0, str_newline# load a0 with the address of the char
        li      $v0, 4          # invoke system call no. 4
        syscall                 # make the actual call
	
# print "odd_series = "
        la      $a0, str_p      # load a0 with the address of the char
        li      $v0, 4          # invoke system call no. 4
        syscall                 # make the actual call
	

	li    $a0, 20	     # p <-- 20	
	jal   odd_series

# print odd_series
        move      $a0, $v0      # load a0 with the address of the char
        li      $v0, 4        # invoke system call no. 4
        syscall               # make the actual call

# print a newline character
        la      $a0, str_newline# load a0 with the address of the char
        li      $v0, 4          # invoke system call no. 4
        syscall                 # make the actual call
	
	
odd_series:	
	ori   $t0, $0, 0	     # i <-- 0
	ori   $v0, $0, 0# j <-- 0
	blez  $a0, DONE      # if (p <= 0) goto DONE
LOOP:	
	andi  $t2, $t0, 0x1  # $t2 <-- bit0 of i
	bnez  $t2 ODD        # if i is odd goto ODD
	add   $v0, $v0, $t0  # j <-- j+i
        j     REINIT
ODD:	
	add   $v0, $v0, 1    # j <-- j+1
REINIT:
	add   $t0, $t0, 1    # i <-- i+1
	blt   $t0, $a0, LOOP # if i<p goto LOOP
DONE:	
	jr    $ra



.data
str_p:
	.asciiz "p = "
str_newline:
	.asciiz "\n"
str_odd_series:
	.asciiz "odd_series = "