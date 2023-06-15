# $s0: N
# $s1: ID
# $s2: N_ID

PathSum:
    add  $sp, $sp, -16
    sw   $s0, 0($sp)
    sw   $s1, 4($sp)
    sw   $s2, 8($sp)
    sw   $ra, 12($sp)
    bne  $a0, $zero, check_id # if N != NULL

    addi $v0, $0, -1          # $v0 <-- -1
    j    done
	
check_id:
    lw   $s2, 0($a0)          # N_ID <-- N->ID
    bne  $s2, $a1, go_left    # if N_ID != ID
	
    add  $v0, $0, $a1         # $v0 <-- ID
    j    done
	
go_left:
    add  $s1, $0, $a1         # $s1 <-- ID
    add  $s0, $0, $a0         # $s0 <-- N
    lw   $a0, 4($s0)          # $a0 <-- N->left
    jal  PathSum              # PathSum(N->left, ID)
	
    addi $t1, $0, -1
    bne  $v0, $t1 return      # if $v0 != -1
	
    lw   $a0, 8($s0)          # $a0 <-- N->right
    add  $a1, $0, $s1         # $a1 <-- ID
    jal  PathSum              # PathSum(N->right, ID)
	
    addi $t1, $0, -1
    beq  $v0, $t1, done       # if $v0 == -1
	
return:
    add  $v0, $v0, $s2        # $v0 <-- found + N_ID
	
done:
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $ra, 12($sp)
    addi  $sp, $sp, 16
    jr  $ra
