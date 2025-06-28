.data

Mat1:  	.word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
Mat2:	.word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
resMat: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 , 0 , 0 , 0 , 0 , 0 , 0
M:	.word 4

.text
main:
la $a0, Mat1	# $a0 = address of Mat1
la $a1, Mat2	# $a1 = address of Mat2
la $a2, resMat	# $a2 = address of resMat
lw $a3, M	# $a3 = matrix size 
jal addMats	# Call addMats function

j finish

# Write to reg file for fpga memory debug
#addi 	$t0, $0, 0
#addi 	$t1, $0, 16
#lw_loop:
#beq	$t0, $t1, finish
#mul	$t2, $t0, $a3
#add 	$t2, $t2, $a2
#lw	$t3, 0($t2)
#addi	$t0, $t0, 1
#j	lw_loop


addMats:
## Sums two matrixes $a0 and $a1 and put it in $a2
addi	$s0, $0, 0	# element_bytes_pointer = 0
addi 	$t0, $0, 4	# const of 4
mul	$s1, $a3, $a3
mul	$s1, $s1, $t0	# num_elements_bytes = 4*M*M

add_loop:
beq	$s0, $s1, done	# while element_bytes_pointer != num_elements_bytes
add	$t0, $a0, $s0	# find Mat1 pointer with offset 
add	$t1, $a1, $s0	# find Mat2 pointer with offset 
add	$t2, $a2, $s0	# find resMat pointer with offset 

lw	$t0, 0($t0)	# get Mat1 pointer value
lw	$t1, 0($t1)	# get Mat2 pointer value
add	$t3, $t1, $t0	
sw	$t3, 0($t2)	# resMat[i] <=  Mat1[i]+Mat2[i]

addi	$s0, $s0, 4	# next word
j	add_loop
	
done: 
jr	$ra	


finish:
