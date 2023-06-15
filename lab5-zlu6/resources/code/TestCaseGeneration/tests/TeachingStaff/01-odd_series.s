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
	ori   $t0, $0, 0	     # i <-- 0
	ori   $v0, $0, 0# j <-- 0
	blez  $a0, DONE      # if (p <= 0) goto DONE
LOOP:	
	andi  $t2, $t0, 0x1  # $t2 <-- bit0 of i
	bne   $t2, $0,  ODD  # if i is odd goto ODD
	add   $v0, $v0, $t0  # j <-- j+i
        j     REINIT
ODD:	
	add   $v0, $v0, 1    # j <-- j+1
REINIT:
	add   $t0, $t0, 1    # i <-- i+1
	slt   $at, $t0, $a0
	bne   $at, $a0, LOOP # if i<p goto LOOP
DONE:	
	jr    $ra
