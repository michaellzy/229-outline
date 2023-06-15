# CMPUT 229 Student Submission License (Version 1.1)
#
# Copyright 2018 Zhiyuan Lu
#
# Unauthorized redistribution is forbidden in all circumstances. Use of this software without explicit authorization from the author **or** CMPUT 229 Teaching Staff is prohibited.
#
# This software was produced as a solution for an assignment in the course CMPUT 229 (Computer Organization and Architecture I) at the University of Alberta, Canada. This solution is confidential and remains confidential after it is submitted for grading. The course staff has the right to run plagiarism-detection tools on any code developed under this license, even beyond the duration of the course.
#
# Copying any part of this solution without including this copyright notice is illegal.
#
# If any portion of this software is included in a solution submitted for grading at an educational institution, the submitter will be subject to the sanctions for plagiarism at that institution.
#
# This software cannot be publicly posted under any circumstances, whether by
# the original student or by a third party. If this software is found in any public website or public repository, the person finding it is kindly requested to immediately report, including the URL or other repository locating information, to the following email address: [cmput229@ualberta.ca](mailto:cmput229@ualberta.ca).
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; # # OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.#---------------------------
# ---------------------------
# Lab 5-Basic Blocks
# CMPUT 229, LEC B1 Wi20
# Zhiyuan Lu
# 1579050
#---------------------------
.data
  .align 2
  array: .space 2048
  .align 2
  edgesList:
	.space 2048
  .align 2
  dominatorList:
	.space 2048
  blockCount: .word 1
  edgesCount:   # Total edges count
	.word 0
  tmpData01:
  	.space 320
  tmpData02:
  	.space 320

# main getControlFlow function
.text
getControlFlow:
addi $sp, $sp, -16
sw  $ra, 0($sp)
sw  $s0, 4($sp)
sw  $s1, 8($sp)
sw  $s2, 12($sp)

jal countBlock
jal findEdge
jal find_dominator


lw  $ra, 0($sp)
lw  $s0, 4($sp)
lw  $s1, 8($sp)
lw  $s2, 12($sp)
addi $sp, $sp, 16

lw $v0, blockCount
lw $v1, edgesCount
addi $sp, $sp, -12 # Stack record
la $t1, array
sw $t1, 0($sp)
la $t1, edgesList
sw $t1, 4($sp)
la $t1, dominatorList
sw $t1, 8($sp)
jr $ra



.text
countBlock:
	addi  $sp, $sp, -44
	sw  $ra, 0($sp)
	sw  $t0, 4($sp)
	sw  $t1, 8($sp)
	sw  $t2, 12($sp)
	sw  $t3, 16($sp)
	sw  $t4, 20($sp)
	sw  $a0, 24($sp)
	sw  $a1, 28($sp)
	sw  $a2, 32($sp)
	sw  $a3, 36($sp)
	sw  $v0, 40($sp)


	la  $t0, array  # $t0 = Addr(array)
	sw  $a0, 0($t0) # Array[0] = $a0
	la  $s5, blockCount
	lw  $s0, 0($s5)
	li  $s7, -1
	# li  $s0, 1      # count = 1
	main_branchFixLoop:
	  addi $s7, $s7, 1
	  lw  $t1, 0($a0) # $t1 = Memory[$a0]
	  srl $t2, $t1, 26  # get opcode
	  li  $t3, 6		# $t3 = 000110
	  beq $t2, $t3, main_branchLead  # save the leader and its offset
	  li  $t3, 5        #t3 = 000101
	  beq $t2, $t3, main_branchLead
	  li  $t3, 4        # t3 = 000100
	  beq $t2, $t3, main_branchLead
	  li  $t3, 1
	  beq $t2, $t3, main_branchLead
	  li  $t3, 7
	  beq $t2, $t3, main_branchLead
	  li  $s3, 2
	  beq $t2, $s3, main_branchLead
	  li  $s3, 3
	  beq $t2, $s3, main_branchLead
	  li  $t4, 0xFC1FFFFF
	  and $t4, $t4, $t1
	  andi $t4, $t4, 0x08
	  bne $t4, $zero, else
	  j main_branchIncrem
	  else:
	  j main_branchIncrem
	  main_branchLead:
	    # 1. any instuction that follows a branch or jump is a leader
	    move  $t5, $a0
	    addi  $t5, $t5, 4 #leader = addr(b-branch) + 4
	    la  $a1, 0($t0)    # $a1 = addr(array)
	    move  $a2, $t5	  # $a2 = value to be insereted to array
	    move  $a3, $s0	  # length of the array
	    jal  checkDuplicate
	    move    $s2, $zero
	    bne   $s2, $v0, goto
	    jal   insertionSort
		j  main_offsetFix
		goto:
	    j  main_offsetFix

	  main_offsetFix:
	  	beq   $t2, $s3, jumpOffsetFix
		move  $t7, $a0     # get address of the branch instruction
	    addiu $t8, $t7, 4
	    sll   $t6, $t1, 16
	    sra   $t6, $t6, 16 # sign extend
	    sll   $t6, $t6, 2 # get byte offset
	    add   $t8, $t8, $t6
	    move  $a2, $t8
	    move  $a3, $s0
		jal   checkDuplicate
		move    $s2, $zero
	    bne   $s2, $v0, goto1
	    jal   insertionSort
		j	  main_branchIncrem
		goto1:
		j     main_branchIncrem
		jumpOffsetFix:
		move  $t6, $a0    # get address of the jump branch instruction
		addi $t6, $t6, 4 # Add 4 to the address of the jump instruction.
		and  $t7, $t6, 0xF0000000 # Extract bits 28-31 from the resulting sum.
		and  $t8, $t1, 0x03FFFFFF # Extract the address field from the jump instruction.
		sll   $t8, $t8, 2           # Multiply the address field by 4, to convert from words to bytes.
		or    $t9, $t8, $t7
		move  $a2, $t9
	    move  $a3, $s0
		jal   checkDuplicate
		move    $s2, $zero
	    bne   $s2, $v0, goto2
	    jal   insertionSort
		j	  main_branchIncrem
		goto2:
		j     main_branchIncrem


	  main_branchIncrem:
	  addi  $a0, $a0, 4
	  li  $s1, -1
	  bne  $t1, $s1, main_branchFixLoop

	la     $a1, 0($t0)
	addi   $s7, $s7, -1
	move   $a2, $s7  # the last instruction num
	move   $a3, $s0
	jal    getSize
	lw  $ra, 0($sp)
	lw  $t0, 4($sp)
	lw  $t1, 8($sp)
	lw  $t2, 12($sp)
	lw  $t3, 16($sp)
	lw  $t4, 20($sp)
	lw  $a0, 24($sp)
	lw  $a1, 28($sp)
	lw  $a2, 32($sp)
	lw  $a3, 36($sp)
	lw  $v0, 40($sp)
	addi  $sp, $sp, 44
	jr  $ra

# subprogram: check duplicate lead address
# a1: addr[array]
# a2: key to insert
# a3: array size
.text
checkDuplicate:
	addi  $sp, $sp, -36
	sw    $ra, 0($sp)
	sw    $a1, 4($sp)
	sw    $a2, 8($sp)
	sw    $a3, 12($sp)
	sw    $t0, 16($sp)
	sw    $t1, 20($sp)
	sw    $t2, 24($sp)
	sw    $t3, 28($sp)
	sw    $t7, 32($sp)

	move  $t0, $zero # i = 0
	move  $v0, $zero
	Loop:
		slt   $t3, $t0, $a3
		beqz  $t3, end_loop1
		#code block
		la    $t7, 0($a1)	# t7 = addr of array[0]
		sll   $t1, $t0, 3   # $t1 = i * 8
		add   $t2, $t7, $t1 # $t2 = addr of array[i]
		lw    $t7, 0($t2)   # $t7 = array[i]
		beq   $t7, $a2, onSuccess
		li    $v0, 0
		addi  $t0, $t0, 1
		b Loop
		onSuccess:
		li	  $v0, 1
		j	end_loop1
	end_loop1:
		lw  $ra, 0($sp)
		lw  $a1, 4($sp)
		lw  $a2, 8($sp)
		lw  $a3, 12($sp)
		lw  $t0, 16($sp)
		lw  $t1, 20($sp)
		lw  $t2, 24($sp)
		lw  $t3, 28($sp)
		lw  $t7, 32($sp)
		addi $sp, $sp, 36
		jr  $ra
# subprogram: get size of the leader
.text
getSize:
	addi  $sp, $sp, -20
	sw    $ra, 0($sp)
	sw    $a1, 4($sp)	# $a1 = addr(array)
	sw    $a3, 8($sp)	# $a3 = array.length
	sw    $v1, 12($sp)
	sw    $v0, 16($sp)

	move  $t0, $zero    # #t0 -> i = 0
	addi  $t1, $a3, -1  # t1 = array.length - 1
	li  $v1, 1
	size_loop:
	slt   $t2, $t0, $t1
	beqz  $t2, end_sizeLoop
	# code block
	la    $t3, 0($a1)  #t3 = addr of array[0]
	sll   $t4, $t0, 3   # t4 = i * 8
	add   $t5, $t3, $t4 #$t5 = addr of array[i]
	lw    $t6, 0($t5)   # $t6 = array[i]
	addi  $t7, $t0, 1  # $t7 = i+1
	sll   $t7, $t7, 3  # t7 = (i+1)*8
	add   $t5, $t3, $t7
	lw    $t8, 0($t5)  # t8 = array[i+1]
	sub   $t9, $t8, $t6
	srl   $t9, $t9, 2  # $t9=array[i+1]-array[i]
	sll   $v0, $v1, 2
	add   $t5, $t3, $v0 # $t5 = addr of array[4]
	sw    $t9, 0($t5)
	addi  $v1, $v1, 2
	addi  $t0, $t0, 1
	b     size_loop
	end_sizeLoop:
	lw    $t0, 0($t5) #t0=size
	addi  $t0, $t0, -1 #t0-1
	sll   $t0, $t0, 2 # t0 * 4
	add  $t1, $t6, $t0 # prev branch addr
	sll  $s7, $s7, 2  # get last instruction num
	lw   $t4, 0($a1)
	add  $t2, $t4, $s7 # get last instruction addr
	sub  $t9, $t2, $t1
	srl  $t9, $t9, 2   # $t9/4
	sll   $v0, $v1, 2
	add   $t5, $t3, $v0
	# li    $t9, 1
	sw    $t9, 0($t5)
	lw    $ra, 0($sp)
	lw    $a1, 4($sp)
	lw    $a3, 8($sp)
	lw    $v1, 12($sp)
	lw    $v0, 16($sp)
	addi  $sp, $sp, 20
	jr $ra




#  subprogram:insertionSort
#  returns:-
.text
insertionSort:
	addi  $sp, $sp, -52
	sw  $ra, 0($sp)
	sw  $a1, 4($sp)
	sw  $a2, 8($sp)
	sw  $a3, 12($sp)
	sw  $t0, 16($sp)
	sw  $t1, 20($sp)
	sw  $t2, 24($sp)
	sw  $t3, 28($sp)
	sw  $t4, 32($sp)
	sw  $t5, 36($sp)
	sw  $t6, 40($sp)
	sw  $t7, 44($sp)
	sw  $t8, 48($sp)

	move  $t0, $zero  #i = 0
	move  $t5, $zero
	# la    $t5, 0($a1)
	addi  $t0, $a3, -1  # $t0 -> i = n-1
	start_loop:
		la    $t7, 0($a1)	# t7 = addr of array[0]
		sll   $t1, $t0, 3   # $t1 = i * 8
		add   $t2, $t7, $t1 # $t2 = addr of array[i]
		lw    $t7, 0($t2)   # $t7 = array[i]
		sle   $t6, $a2, $t7 # $t6 = 0 if (arr[i] < key)
		beqz  $t6, end_loop
		#code block
		addi  $t3, $t0, 1   # $t3 = i+1
		sll   $t4, $t3, 3   # t4 = (i+1) * 8
		add   $t5, $a1, $t4	# $t5 = addr(array[i+1])
		sw	  $t7, 0($t5)	# $t7 = address in $a1
		addi  $t0, $t0, -1  # i = i-1
		b  start_loop
	end_loop:
		addi  $t0, $t0, 1
		sll   $t8, $t0, 3
		add   $t9, $a1, $t8
		sw    $a2, 0($t9)
		addi  $s0, $s0, 1  # array.length++
		sw    $s0, 0($s5)

	lw  $ra, 0($sp)
	lw  $a1, 4($sp)
	lw  $a2, 8($sp)
	lw  $a3, 12($sp)
	lw  $t0, 16($sp)
	lw  $t1, 20($sp)
	lw  $t2, 24($sp)
	lw  $t3, 28($sp)
	lw  $t4, 32($sp)
	lw  $t5, 36($sp)
	lw  $t6, 40($sp)
	lw  $t7, 44($sp)
	lw  $t8, 48($sp)
	addi  $sp, $sp, 52
	jr $ra

.text
findEdge:
	addi  $sp, $sp, -40
	sw  $ra, 0($sp)
	sw  $t0, 4($sp)
	sw    $t1, 8($sp)
	sw    $t2, 12($sp)
	sw    $t3, 16($sp)
	sw    $t4, 20($sp)
	sw    $t5, 24($sp)
	sw    $t6, 28($sp)
	sw    $t7, 32($sp)
	sw    $t8, 36($sp)
	la  $s0, array
	la  $s1, blockCount
	la  $s2, edgesList
	la  $s3, edgesCount
	la  $a0, 0($s0) # $s4=addr of array[0]
	lw  $a1, 0($s1) # array.length

	move  $t0, $zero # i = 0
	li  $t9, 1
	findEdge_Loop:
	slt   $t1, $t0, $a1  # if (i < array.size)
	beqz  $t1, end_findEdgeLoop
	# code block
	la    $t2, 0($a0)    # t2 = addr of array[0]
	sll   $t3, $t9, 2
	add   $t5, $t2, $t3  # $t5 = addr of array[4]
	lw    $t8, 0($t5)    # $t8 = branch size
	addi  $t8, $t8, -1
	sll   $t8, $t8, 2
	sll   $t3, $t0, 3    # t3 = i * 8
	add   $t4, $t2, $t3  #$t4 = addr of array[i]
	lw    $t5, 0($t4)
	move  $v0, $t5
	add   $t4, $t5, $t8  # get branch address
	lw    $t5, 0($t4)
	srl   $t6, $t5, 26   # get opcode
	li    $t7, 6
	beq   $t6, $t7, b_edge
	li    $t7, 5
	beq   $t6, $t7, b_edge
	li    $t7, 4
	beq   $t6, $t7, b_edge
	li    $t7, 1
	beq   $t6, $t7, b_edge
	li    $t7, 7
	beq   $t6, $t7, b_edge
	li    $t7, 2
	beq   $t6, $t7, j_edge
	li    $t7, 3
	beq   $t6, $t7, j_edge
	li    $t7, 0xFC1FFFFF
	and   $t7, $t7, $t5
	andi  $t7, $t7, 0x08
	bne   $t7, $zero, jr_branch
	move  $a2, $t4 # else branch address
	jal   find_else_edge
	j     findEdge_Increm

	b_edge:
	move  $a2, $t4 # b branch address
	move  $a3, $t5 # PC
	jal   find_b_edge
	j     findEdge_Increm

	j_edge:
	move  $a2, $t4 # j branch address
	move  $a3, $t5 # PC
	jal   find_j_edge
	j     findEdge_Increm

	jr_branch:
	j 	  findEdge_Increm

	findEdge_Increm:
	addi  $t9, $t9, 2
	addi  $t0, $t0, 1
	j 	  findEdge_Loop

	end_findEdgeLoop:
	lw    $ra, 0($sp)
	lw    $t0, 4($sp)
	lw    $t1, 8($sp)
	lw    $t2, 12($sp)
	lw    $t3, 16($sp)
	lw    $t4, 20($sp)
	lw    $t5, 24($sp)
	lw    $t6, 28($sp)
	lw    $t7, 32($sp)
	lw    $t8, 36($sp)
	addi  $sp, $sp, 40
	jr    $ra

.text
find_b_edge:
	addi  $sp, $sp, -36
	sw    $ra, 0($sp)
	sw    $s4, 4($sp)
	sw    $s5, 8($sp)
	sw    $t0, 12($sp)
	sw    $t1, 16($sp)
	sw    $t2, 20($sp)
	sw    $t3, 24($sp)
	sw    $t4, 28($sp)
	sw    $t5, 32($sp)
	move  $t0, $a2       # $t0 = branch address
	move  $t4, $a3
	addi  $t1, $t0, 4    # $t1 = first target edge in b branch
	move  $s4, $t1       # save 1st b branch target address
	# get target address
	addiu  $t2, $t0, 4
	sll    $t3, $t4, 16
	sra    $t3, $t3, 16  # sign extend
	sll    $t3, $t3, 2   # get byte offset
	add    $t2,$t2, $t3
	move   $s5, $t2      # save 2nd b branch target address
	jal    store_b_edge

	lw    $ra, 0($sp)
	lw    $s4, 4($sp)
	lw    $s5, 8($sp)
	lw    $t0, 12($sp)
	lw    $t1, 16($sp)
	lw    $t2, 20($sp)
	lw    $t3, 24($sp)
	lw    $t4, 28($sp)
	lw    $t5, 32($sp)
	addi  $sp, $sp, 36
	jr    $ra

.text
find_j_edge:
	addi  $sp, $sp, -24
	sw    $ra, 0($sp)
	sw    $t0, 4($sp)
	sw    $t1, 8($sp)
	sw    $t2, 12($sp)
	sw    $t3, 16($sp)
	sw    $t4, 20($sp)

	move  $t0, $a2  # $t0 = j branch address
	move  $t1, $a3  # $t1 = PC
	addi  $t0, $t0, 4
	and   $t2, $t0, 0xF0000000
	and   $t3, $t1, 0x03FFFFFF
	sll   $t3, $t3, 2
	or    $t4, $t3, $t2
	move  $s6, $t4
	jal   store_j_edge

	lw    $ra, 0($sp)
	lw    $t0, 4($sp)
	lw    $t1, 8($sp)
	lw    $t2, 12($sp)
	lw    $t3, 16($sp)
	lw    $t4, 20($sp)
	addi  $sp, $sp, 24
	jr    $ra

.text
find_else_edge:
	addi  $sp, $sp,-8
	sw    $ra, 0($sp)
	sw    $t0, 4($sp)
	move  $t0, $a2
	addi  $t0, $t0, 4
	move  $s7, $t0
	jal   store_else_edge
	lw    $ra, 0($sp)
	lw    $t0, 4($sp)
	addi  $sp, $sp, 8
	jr    $ra

.text
store_b_edge:
	addi  $sp, $sp, -36
	sw    $ra, 0($sp)
	sw    $t0, 4($sp)
	sw    $t1, 8($sp)
	sw    $t2, 12($sp)
	sw    $t3, 16($sp)
	sw    $t4, 20($sp)
	sw    $t5, 24($sp)
	sw    $t6, 28($sp)
	sw    $t7, 32($sp)
	move  $t6, $s4
	move  $t7, $s5
	la    $t0, edgesList  # $t0 = addr of edgesList
	la    $t1, edgesCount
	lw    $t2, 0($t1)     # t2 = edge num
	sll   $t2, $t2, 1
	sll   $t4, $t2, 2     # $t4 = $t2 * 4
	add  $t5, $t4, $t0   # array address to store the first edge
	slt   $t3, $t6, $t7
	beqz  $t3, store_reverse
	sw    $v0, 0($t5)     # store the leader
	addi  $t2, $t2, 1
	sll   $t4, $t2, 2
	add  $t5, $t4, $t0
	sw    $t6, 0($t5)     # store first edge
	addi  $t2, $t2, 1
	sll   $t4, $t2, 2
	add  $t5, $t4, $t0
	sw    $v0, 0($t5)     # store the leader
	addi  $t2, $t2, 1
	sll   $t4, $t2, 2
	add  $t5, $t4, $t0
	sw    $t7, 0($t5)     # store second
	addi  $t2, $t2, 1
	srl   $t2, $t2, 1
	sw    $t2, 0($t1)
	lw    $ra, 0($sp)
	lw    $t0, 4($sp)
	lw    $t1, 8($sp)
	lw    $t2, 12($sp)
	lw    $t3, 16($sp)
	lw    $t4, 20($sp)
	lw    $t5, 24($sp)
	lw    $t6, 28($sp)
	lw    $t7, 32($sp)
	addi  $sp, $sp, 36
	jr    $ra
	store_reverse:
	sw    $v0, 0($t5)     # store the leader
	addi  $t2, $t2, 1
	sll   $t4, $t2, 2
	add  $t5, $t4, $t0
	sw    $t7, 0($t5)     # store first edge
	addi  $t2, $t2, 1
	sll   $t4, $t2, 2
	add  $t5, $t4, $t0
	sw    $v0, 0($t5)     # store the leader
	addi  $t2, $t2, 1
	sll   $t4, $t2, 2
	add  $t5, $t4, $t0
	sw    $t6, 0($t5)     # store second edge
	addi  $t2, $t2, 1
	srl   $t2, $t2, 1
	sw    $t2, 0($t1)
	lw    $ra, 0($sp)
	lw    $t0, 4($sp)
	lw    $t1, 8($sp)
	lw    $t2, 12($sp)
	lw    $t3, 16($sp)
	lw    $t4, 20($sp)
	lw    $t5, 24($sp)
	lw    $t6, 28($sp)
	lw    $t7, 32($sp)
	addi  $sp, $sp, 36
	jr    $ra

.text
store_j_edge:
	addi  $sp, $sp, -28
	sw    $ra, 0($sp)
	sw    $t0, 4($sp)
	sw    $t1, 8($sp)
	sw    $t2, 12($sp)
	sw    $t3, 16($sp)
	sw    $t4, 20($sp)
	sw    $t5, 24($sp)
	la    $t0, edgesList
	la    $t1, edgesCount
	move  $t5, $s6
	lw    $t2, 0($t1)  # $t2 = edge size
	sll   $t2, $t2, 1  # edge size total include leader
	sll   $t3, $t2, 2  #t3 = $t2 * 4
	add   $t4, $t3, $t0 # array address to store the leader
	sw    $v0, 0($t4)
	addi  $t2, $t2, 1
	sll   $t3, $t2, 2
	add   $t4, $t3, $t0
	sw    $t5, 0($t4)
	addi  $t2, $t2, 1
	srl   $t2, $t2, 1
	sw    $t2, 0($t1)
	lw    $ra, 0($sp)
	lw    $t0, 4($sp)
	lw    $t1, 8($sp)
	lw    $t2, 12($sp)
	lw    $t3, 16($sp)
	lw    $t4, 20($sp)
	lw    $t5, 24($sp)
	addi  $sp, $sp, 28
	jr    $ra

.text
store_else_edge:
	addi  $sp, $sp, -28
 	sw    $ra, 0($sp)
 	sw    $t0, 4($sp)
	sw    $t1, 8($sp)
	sw    $t2, 12($sp)
	sw    $t3, 16($sp)
	sw    $t4, 20($sp)
	sw    $t5, 24($sp)
	la    $t0, edgesList
	la    $t1, edgesCount
	move  $t5, $s7
	lw    $t2, 0($t1)  # $t2 = edge size
	sll   $t2, $t2, 1  # edge size total include leader
	sll   $t3, $t2, 2  #t3 = $t2 * 4
	add   $t4, $t3, $t0 # array address to store the leader
	sw    $v0, 0($t4)
	addi  $t2, $t2, 1
	sll   $t3, $t2, 2
	add   $t4, $t3, $t0
	sw    $t5, 0($t4)
	addi  $t2, $t2, 1
	srl   $t2, $t2, 1
	sw    $t2, 0($t1)
	lw    $ra, 0($sp)
	lw    $t0, 4($sp)
	lw    $t1, 8($sp)
	lw    $t2, 12($sp)
	lw    $t3, 16($sp)
	lw    $t4, 20($sp)
	lw    $t5, 24($sp)
	addi  $sp, $sp, 28
	jr    $ra


.text
find_dominator:
	addi   $sp, $sp, -4
	sw     $ra, 0($sp)
	lw     $s0, blockCount
	la     $s1, array
	la     $s2, edgesList
	la     $s3, edgesCount

	srl    $s5, $s0, 5
	sll    $t0, $s5, 5
	beq    $s0, $t0, dom_noAddCom
	addi   $s5, $s5, 1
dom_noAddCom:
	jal    initialize
	jal    main_control
	lw     $ra, 0($sp)
	addi   $sp, $sp, 4
	jr     $ra

.text
main_control:
	addi   $sp, $sp, -36
	sw     $ra, 0($sp)
	sw    $t0, 4($sp)
	sw    $t1, 8($sp)
	sw    $t2, 12($sp)
	sw    $t3, 16($sp)
	sw    $t4, 20($sp)
	sw    $t5, 24($sp)
	sw    $t6, 28($sp)
	sw    $t7, 32($sp)

	lw     $s3, edgesCount
	sll    $t2, $s5, 2
	li     $s4, 0    # flag
	start_flag_loop:
	la     $a2, dominatorList
	li     $t3, 0
	start_iter_loop:
	slt    $t6, $t3, $s3 # i < edgeList size
	beqz   $t6, end_iter_loop
	# code block start
	lw     $a0, 0($s2) # edgeList leader
	jal    getIndex   # n(j) index
	mul    $a3, $t2, $v0  # recordSize(Nword) x index=offset
	move   $v1, $v0  # $v1: n(j) index. $v1<-$v0
	add    $a3, $a3, $a2  # $a3:n(j) address in dominator list

	lw	$a0,4($s2)	# edgesList. destination
	jal	getIndex	# $v0: n(i) index
	mul	$t7, $t2, $v0	# recordSize(Nword) x index=offset
	add	$t7, $t7, $a2	# $t7:n(i) address in dominator list

	add	$a0, $zero, $v0  # $v0: n(i) index
	la 	$a1, tmpData01
	jal setBit  # set {n_i} in tmpData01

	# Dom(n_i) ∩ Dom(n_j)
	move	$a0, $a3	# $a3:n(j) address
	move	$a1, $t7	# $t7:n(i) address
	jal	andOper		# Dom(n_i) ∩ Dom(n_j) save in tmpData02

	# Dom(n_i) = {n_i} ∪ (Dom(n_i) ∩ Dom(n_j))
	la	$a0, tmpData01
	la	$a1, tmpData02
	jal orOper		# save in tmpData01

	# save Dom(n_i)
	la	$a0, tmpData01
	move 	$a1, $t7
	jal	saveVector

	# reset tmp
	la	$a0, tmpData01
	jal 	resetVector
	la	$a0, tmpData02
	jal	resetVector

	addi   $t3, $t3, 1
	addi   $s2, $s2, 8
	b      start_iter_loop
end_iter_loop:

	beqz   $s4, end_flag_loop
	li    $s4, 0
	b      start_flag_loop
end_flag_loop:


	lw    $ra, 0($sp)
	lw    $t0, 4($sp)
	lw    $t1, 8($sp)
	lw    $t2, 12($sp)
	lw    $t3, 16($sp)
	lw    $t4, 20($sp)
	lw    $t5, 24($sp)
	lw    $t6, 28($sp)
	lw    $t7, 32($sp)
	addi   $sp, $sp, 36
	jr     $ra



# testBit:
#	addi   $s5, $zero, 2
#	addi   $a0, $zero, 32
#	la     $a1, tmpData01
#	jal    setBit

# subprogram: setBit
# $a0: bit position  $a1: target pointer
.text
setBit:
	addi    $sp, $sp,-40
	sw      $ra, 0($sp)
 	sw      $t0, 4($sp)
	sw      $t1, 8($sp)
	sw      $t2, 12($sp)
	sw      $t3, 16($sp)
	sw      $t4, 20($sp)
	sw      $t5, 24($sp)
	sw      $t6, 28($sp)
	sw      $t7, 32($sp)
	sw      $t9, 36($sp)

	move    $t0, $a0   # $t0 = bit position
	move    $t1, $a1   # $t1 = target address
	move    $t3, $s5
	li      $t2, 1     # $t2 -> i = 1
	sll     $t3, $t3, 2 # word->byte $t3=total bytes
	setBit_Loop:
	slt     $t4, $t2, $t3  # while (i < $t3)
	beqz    $t4, end_setBit_loop
	# code block
	sll     $t5, $t2, 3 # $t5 = i*8
	slt     $t6, $t0, $t5 # if bitposition<$t5
	beqz    $t6, end_setBit_if
	addi    $t7, $t5, -8
	sub     $t7, $t0, $t7 # 11-8=3
	li      $t4, 1
	sll     $t7, $t4, $t7 # shift left to target address
	lb      $t9, 0($t1)
	or      $t5, $t9, $t7
	sb      $t5, 0($t1)
	j       end_setBit_loop
	end_setBit_if:
	addi    $t2, $t2, 1
	addi    $t1, $t1, 1
	b 		setBit_Loop
	end_setBit_loop:
	lw      $ra, 0($sp)
 	lw      $t0, 4($sp)
	lw      $t1, 8($sp)
	lw      $t2, 12($sp)
	lw      $t3, 16($sp)
	lw      $t4, 20($sp)
	lw      $t5, 24($sp)
	lw      $t6, 28($sp)
	lw      $t7, 32($sp)
	lw      $t9, 36($sp)
	addi    $sp, $sp, 40
	jr      $ra

.text
initialize:
	addi   $sp, $sp, -36
	sw     $ra, 0($sp)
	sw    $t0, 4($sp)
	sw    $t1, 8($sp)
	sw    $t2, 12($sp)
	sw    $t3, 16($sp)
	sw    $t4, 20($sp)
	sw    $t5, 24($sp)
	sw    $t6, 28($sp)
	sw    $t7, 32($sp)
	addi   $a0, $zero, 0
	la     $a1, dominatorList
	jal    setBit
	la     $a1, dominatorList
	move   $t0, $a1  # $t0 = addr of dominatorList
	sll    $t2, $s5, 2 # get next word
	add    $t0, $t0, $t2 # address of next word
	addi   $t7, $s0, -1   # $t7->leadersize-1
	li     $t3, 1        # i=1
	start_outer_loop:
	sle    $t4, $t3, $t7
	beqz   $t4, end_outer_loop
	addi   $t3, $t3, 1
	li     $t5, 0   # j = 0
	start_inner_loop:
	sle    $t4, $t5, $t7
	beqz   $t4, end_inner_loop
	move   $a0, $t5
    move     $a1, $t0
	jal    setBit
	addi   $t5, $t5, 1
	j      start_inner_loop
	end_inner_loop:
	add    $t0, $t0, $t2
	j      start_outer_loop
	end_outer_loop:
	lw     $ra, 0($sp)
	lw    $t0, 4($sp)
	lw    $t1, 8($sp)
	lw    $t2, 12($sp)
	lw    $t3, 16($sp)
	lw    $t4, 20($sp)
	lw    $t5, 24($sp)
	lw    $t6, 28($sp)
	lw    $t7, 32($sp)
	addi   $sp, $sp, 36
	jr     $ra
# subprogram: get index of the leader
# param:  $a0: leader

.text
getIndex:
	addi   $sp, $sp, -28
	sw     $ra, 0($sp)
	sw    $t0, 4($sp)
	sw    $t1, 8($sp)
	sw    $t2, 12($sp)
	sw    $t3, 16($sp)
	sw    $t4, 20($sp)
	sw    $t5, 24($sp)
	move   $t0, $zero #i=0
	li     $v0, -1  #v0=index
	start_getIndex_loop:
	slt    $t1, $t0, $s0
	beqz   $t1, end_getIndex_loop
	# code block
	la     $t2, array # $t2 = addr of blockList
	sll    $t3, $t0, 3     # t3 = i*8
	add    $t4, $t3, $t2   # $t4 = addr of blockList[i]
	lw     $t5, 0($t4)     # $t5 = blockList[i]
	beq    $t5, $a0, index_increm
	addi   $v0, $v0, 1
	addi   $t0, $t0, 1
	b      start_getIndex_loop
	index_increm:
	addi   $v0, $v0, 1
	j      end_getIndex_loop
	end_getIndex_loop:
	lw     $ra, 0($sp)
	lw    $t0, 4($sp)
	lw    $t1, 8($sp)
	lw    $t2, 12($sp)
	lw    $t3, 16($sp)
	lw    $t4, 20($sp)
	lw    $t5, 24($sp)
	addi   $sp, $sp, 28
	jr     $ra

.text
andOper:
	addi  $sp, $sp, -32
	sw    $ra, 0($sp)
	sw    $t0, 4($sp)
	sw    $t1, 8($sp)
	sw    $t2, 12($sp)
	sw    $t3, 16($sp)
	sw    $t4, 20($sp)
	sw    $t5, 24($sp)
	sw    $t6, 28($sp)
	move    $t0, $s5   # t0 = word of the record
	sll   $t0, $t0, 2 # t0->bytes of the record
	li    $t1, 1    # i = 1
	la    $t2, tmpData02
	start_and_loop:
	sle   $t3, $t1, $t0 # i < byte of the record
	beqz  $t3, end_and_loop
	lb    $t4, 0($a0)
	lb    $t5, 0($a1)
	and   $t6, $t4, $t5
	sb    $t6, 0($t2)
	addi  $t1, $t1, 1 #i++
	addi  $a0, $a0, 1
	addi  $a1, $a1, 1
	addi  $t2, $t2, 1 #addr of $t5 + 1
	b 	  start_and_loop
	end_and_loop:
	lw    $ra, 0($sp)
	lw    $t0, 4($sp)
	lw    $t1, 8($sp)
	lw    $t2, 12($sp)
	lw    $t3, 16($sp)
	lw    $t4, 20($sp)
	lw    $t5, 24($sp)
	lw    $t6, 28($sp)
	addi  $sp, $sp, 32
	jr    $ra

.text
orOper:
	addi  $sp, $sp, -32
	sw    $ra, 0($sp)
	sw    $t0, 4($sp)
	sw    $t1, 8($sp)
	sw    $t2, 12($sp)
	sw    $t3, 16($sp)
	sw    $t4, 20($sp)
	sw    $t5, 24($sp)
	sw    $t6, 28($sp)
	move    $t0, $s5   # t0 = word of the record
	sll   $t0, $t0, 2 # t0->bytes of the record
	li    $t1, 1    # i = 1
	la    $t2, tmpData01
	start_or_loop:
	sle   $t3, $t1, $t0 # i < byte of the record
	beqz  $t3, end_or_loop
	lb    $t4, 0($a0)
	lb    $t5, 0($a1)
    or    $t6, $t4, $t5
	sb    $t6, 0($t2)
	addi  $t1, $t1, 1 #i++
	addi  $a0, $a0, 1
	addi  $a1, $a1, 1
	addi  $t2, $t2, 1 #addr of $t5 + 1
	b 	  start_or_loop
	end_or_loop:
	lw    $ra, 0($sp)
	lw    $t0, 4($sp)
	lw    $t1, 8($sp)
	lw    $t2, 12($sp)
	lw    $t3, 16($sp)
	lw    $t4, 20($sp)
	lw    $t5, 24($sp)
	lw    $t6, 28($sp)
	addi  $sp, $sp, 32
	jr    $ra

# a0: source address
# a1: target
.text
saveVector:
	addi  $sp, $sp, -32
	sw    $ra, 0($sp)
	sw    $t0, 4($sp)
	sw    $t1, 8($sp)
	sw    $t2, 12($sp)
	sw    $t3, 16($sp)
	sw    $t4, 20($sp)
	sw    $t5, 24($sp)
	sw    $t6, 28($sp)
	move  $t0, $a0 # $t0 = source address to read from
	move  $t4, $a1 # target address
	move    $t1, $s5 # $t1=word of the record
	sll   $t1, $t1, 2 # $t1->bytes of the record
	li    $t2, 1 # i = 1
	start_saveVector_loop:
	sle   $t3, $t2, $t1 # i<bytes
	beqz  $t3, end_saveVector_loop
	lb    $t5, 0($t0)
	lb    $t6, 0($t4) # load byte from target address
	beq   $t5, $t6, noSetFlag
	li    $s4, 1  # set flag to 1
	sb    $t5, 0($t4)
	addi  $t2, $t2, 1
	addi  $t0, $t0, 1
	addi  $t4, $t4, 1
	b     start_saveVector_loop
	noSetFlag:

	addi  $t2, $t2, 1
	addi  $t0, $t0, 1
	addi  $t4, $t4, 1
	b      start_saveVector_loop
	end_saveVector_loop:
	lw    $ra, 0($sp)
	lw    $t0, 4($sp)
	lw    $t1, 8($sp)
	lw    $t2, 12($sp)
	lw    $t3, 16($sp)
	lw    $t4, 20($sp)
	lw    $t5, 24($sp)
	lw    $t6, 28($sp)
	addi  $sp, $sp, 32
	jr    $ra

.text
resetVector:
	addi  $sp, $sp, -20
	sw    $ra, 0($sp)
	sw    $t0, 4($sp)
	sw    $t1, 8($sp)
	sw    $t2, 12($sp)
	sw	  $t3, 16($sp)

	move    $t0, $s5   # t0 = word of the record
	sll   $t0, $t0, 2 # t0->bytes of the record
	li    $t1, 1    # i = 1
	move    $t2, $a0
	start_reset_loop:
	sle   $t3, $t1, $t0 # i < byte of the record
	beqz  $t3, end_reset_loop
	sb    $zero, 0($t2)
	addi  $t1, $t1, 1 # i++
	addi  $t2, $t2, 1 # byte address ++
	b 	  start_reset_loop
	end_reset_loop:
	lw    $ra, 0($sp)
	lw    $t0, 4($sp)
	lw    $t1, 8($sp)
	lw    $t2, 12($sp)
	lw	  $t3, 16($sp)
	addi  $sp, $sp, 20
	jr    $ra
