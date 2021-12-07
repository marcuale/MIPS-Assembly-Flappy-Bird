#####################################################################
#
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
#
#
#####################################################################

# - Bird 7 units ahead
# - Pipe 4 units wide, 8 units apart
# - Next pipe appears when pipe pass halfway
# - bid 4 units long, 3 units high

# - pipe 1 memory -> $s0
# - bird memory -> $s1
.data
	pipeColor: .word 0x74C029	# Color of pipes
	DayColor: .word 0x72C7D0	# Color of sky during day
	SkyColor1: .word 0x72C7D0
	SkyColor2: .word 0x72aed0
	SkyColor3: .word 0x54829c
	SkyColor4: .word 0x485485
	SkyColor5: .word 0x363a69
	birdColor: .word 0xD1C429	# Color of bird
	birdColor2: .word 0xdb2525	# Colour of second bird
	s0: .space 8			# Space allocated for Pipe 1
	s1: .space 8			# Space allocated for Pipe 2
	s2: .space 8			# Space allocated for Bird
	s3: .space 4			# Space allocated for skycolor
	s4: .space 4			# Space allocated for game-loop counter
	s5: .space 8			# Space allocated for Bird #2
	s6: .space 4			# Space allocated for death check
	newline: .asciiz "\n"

.globl main
.text

main:			# Load memory addresses
	la $s0, s0			# Store pipe 1 memory address at $s0
	la $s1, s1			# Store pipe 2 memory address at $s1
	la $s2, s2		
	la $s3, s3	
	la $s4, s4
	la $s5, s5
	la $s6, s6
	
	add $t0, $zero, $zero
	sw $t0, 0($s4)
	add $t1, $zero, $zero
	addi $t1, $t1, 1
	sw $t1, 0($s6)
	
full_fill_prep:		# Prep for filling background
	add $t0, $zero, $gp		# Load bitmap address to $t0
	lw $t1, DayColor		# Load sky color to #t1
	sw $t1 0($s3)
	li $t2, 0			# Store a counter at $t2
	li $t3, 1024			# Store the counter limit at $t3

full_fill:		# Loop for filling background
	sw $t1, 0($t0)			# paint a unit on bitmap
	addi $t0, $t0, 4		# increment bitmap address
	addi $t2, $t2, 1		# increment counter
	bne $t2, $t3, full_fill 	# loop drawing background
	
bird_start_prep: 		# Initializing our birds
	add $t0, $zero, $zero
	addi $t0, $t0, 1948		# The bird will always first load in here
	sw $t0, 0($s1)			# Save into memory	
	
	add $t1, $zero, $zero
	addi $t1, $t1, 1692		# The second bird will always first load in here
	sw $t1, 0($s5)			# Save into memory

draw_pipe_prep:	# Initiating a pipe	
	li $a1, 16 			# Load random number max to $a1
    	li $v0, 42			# Load random generator syscall to $v0
    	syscall
	addi $a0, $a0, 2		# Add 2 to randomly generator number, now between 2-18
    	sw $a0, 0($s0)			# Store random number to pipe 1 memory
	li $t0, 32   			# Set location of pipe 1
	sw $t0	4($s0)			# Store location of pipe 1 to pipe 1 memory	
	li $a1, 16 			# Load random number max to $a1
    	li $v0, 42			# Load random generator syscall to $v0
    	syscall
	addi $a0, $a0, 2		# Add 2 to randomly generator number, now between 2-18
    	sw $a0, 0($s1)			# Store random number to pipe 2 memory
	li $t0, 50   			# Set location of pipe 2
	sw $t0	4($s1)			# Store location of pipe 2 to pipe 2 memory

game_loop:		# --GAME LOOP--
	li $v0, 32			# Load pause syscall to $v0
	li $a0, 160			# Load pause duration to $a0
	syscall
	jal draw_sky
	jal input_check
	#jal input_check_2
	jal draw_bird
	jal draw_bird_2
	jal pipe1_branch		# Draw Pipe 1 method
	jal pipe2_branch		# Draw Pipe 1 method
	j game_loop			# loop game
	
draw_sky:
	add $t0, $zero, $zero
	lw $t0, 0($s4)
	addi $t0, $t0, 1
	
	add $t1, $zero, 15
	beq $t0, $t1, set2

	add $t1, $zero, 30
	beq $t0, $t1, set3
	
	add $t1, $zero, 45
	beq $t0, $t1, set4
	
	add $t1, $zero, 60
	beq $t0, $t1, set5
	
	
	add $t1, $zero, 75
	beq $t0, $t1, set4

	add $t1, $zero, 90
	beq $t0, $t1, set3
	
	add $t1, $zero, 105
	beq $t0, $t1, set3
	
	add $t1, $zero, 120
	beq $t0, $t1, set1
	
	
	
	sw $t0, 0($s4)
	jr $ra
	
set1:
	 add $t0, $zero, $zero
	 sw $t0, 0($s4) 		# Save current count
	 lw $t1, SkyColor1
	 sw $t1, 0($s3)
	 j draw_background
	
set2:
	 sw $t0, 0($s4) 		# Save current count
	 lw $t1, SkyColor2
	 sw $t1, 0($s3)
	 j draw_background
	 
set3:
	 sw $t0, 0($s4) 		# Save current count
	 lw $t1, SkyColor3
	 sw $t1, 0($s3)
	 j draw_background
	 
set4:
	 sw $t0, 0($s4) 		# Save current count
	 lw $t1, SkyColor4
	 sw $t1, 0($s3)
	 j draw_background
	 
set5:
	 sw $t0, 0($s4) 		# Save current count
	 lw $t1, SkyColor5
	 sw $t1, 0($s3)
	 j draw_background

draw_background:
	add $t0, $zero, $gp		# Load bitmap address to $t0
	lw $t4, pipeColor		
	lw $t5, birdColor
	li $t2, 0			# Store a counter at $t2
	li $t3, 1024			# Store the counter limit at $t3
full_fill_cycle:			# Loop for filling background
	lw $t6, 0($t0)
	beq $t4, $t6, skip		# If the pipe is drawn there, skip
	beq $t5, $t6, skip		# If the bird is drawn there, skip
	sw $t1, 0($t0)			# Else, redraw the sky
skip:
	addi $t0, $t0, 4		# increment bitmap address
	addi $t2, $t2, 1		# increment counter
	bne $t2, $t3, full_fill_cycle 	# loop drawing background
		  	 	 	 	 	 
	jr $ra				# Go back to game loop

draw_pipe1_prep:	# Initiating a pipe	
	li $a1, 16 			# Load random number max to $a1
    	li $v0, 42			# Load random generator syscall to $v0
    	syscall
	addi $a0, $a0, 2		# Add 2 to randomly generator number, now between 2-18
    	sw $a0, 0($s0)			# Store random number to pipe 1 memory
	li $t0, 32   			# Set location of pipe 1
	sw $t0	4($s0)			# Store location of pipe 1 to pipe 1 memory
	jr $ra				# Return to game loop

draw_pipe2_prep:	# Initiating a pipe	
	li $a1, 16 			# Load random number max to $a1
    	li $v0, 42			# Load random generator syscall to $v0
    	syscall
	addi $a0, $a0, 2		# Add 2 to randomly generator number, now between 2-18
    	sw $a0, 0($s1)			# Store random number to pipe 2 memory
	li $t0, 32   			# Set location of pipe 2
	sw $t0	4($s1)			# Store location of pipe 2 to pipe 2 memory
	jr $ra				# Return to game loop

pipe1_branch:		# Drawing pipe 1 method head
	add $t0, $zero, $gp		# Load bitmap address to $t0
	lw $t1, pipeColor		# Load pipe color into $t1
	lw $t2, 0($s3)		# Load sky color to $t2
	lw $t3, 0($s0)			# Load pipe gap top to $t3
	lw $t4, 4($s0)			# Load pipe location to $t4
	li $t6, 0			# Store a counter at $t6
	subi $t4, $t4, 1		# Decrement pipe location
	li $t7, 4			# Set $t7 to 4
	mult $t7, $t4			# Get address offset of pipe for bitmap
	mflo $t7
	add $t0, $t0, $t7		# Add offest to bitmap address
	bge $t4, 32, pipe1_store	# Loop, Nothing drawn
	bge $t4, -4, Pipe1Loop		# Draw pipe when in locations on screen
	j draw_pipe1_prep		# Generate new pipe

Pipe1Loop:			# Draw pipe 1 loop
	addi $t6, $t6, 1		# Increment counter
	bge $t4, 28, Pipe1R		# Draw pipe comming in from right
	bge $t4, 0, Pipe1M		# Draw pipe when moving through middle

Pipe1L:				# Draw pipe 1 disappearing into left
	sw $t2, 16($t0)			# paint back of pipe over with sky
	j Pipe1End			# Go to rest of loop

Pipe1R:				# Draw pipe 1 appearing from right
	sw $t1, 0($t0)			# Paint pipe
	j Pipe1End			# Go to rest of loop

Pipe1M:				# Draw pipe 1 moving through middle
	sw $t1, 0($t0)			# paint pipe 
	sw $t2, 16($t0)			# paint back of pipe over with sky

Pipe1End:			# Rest of pipe 1 loop
	addi $t0, $t0, 128		# Increment bitmap address
	li $t5, 0			# Store a counter at $t5 for gap
	beq $t6, $t3, Pipe1Skip		# If at gap position, do gap method
	bne $t6, 32, Pipe1Loop		# Loops until pipe is fully drawn
	j pipe1_store			# Save variables into memory

Pipe1Skip:			# Draw pipe 1 gap 
	addi $t6, $t6, 1		# Increment pipe counter
	addi $t5, $t5, 1		# Increment gap counter
	addi $t0, $t0, 128		# Increment bitmap address
	bne $t5, 12, Pipe1Skip		# Loop skip until gap is 12 units long
	j Pipe1Loop			# Return to drawing pipe loop

pipe1_store:			# Store pipe 1 variables into memory
	sw $t3 0($s0)			# Save pipe gap top into memory
	sw $t4 4($s0)			# Save pipe location into memory
	jr $ra				# Return to game loop

pipe2_branch:		# Drawing pipe 2 method head
	add $t0, $zero, $gp		# Load bitmap address to $t0
	lw $t1, pipeColor		# Load pipe color into $t1
	lw $t2, 0($s3)			# Load sky color to $t2
	lw $t3, 0($s1)			# Load pipe gap top to $t3
	lw $t4, 4($s1)			# Load pipe location to $t4
	li $t6, 0			# Store a counter at $t6
	subi $t4, $t4, 1		# Decrement pipe location
	li $t7, 4			# Set $t7 to 4
	mult $t7, $t4			# Get address offset of pipe for bitmap
	mflo $t7
	add $t0, $t0, $t7		# Add offest to bitmap address
	bge $t4, 32, pipe2_store	# Loop, Nothing drawn
	bge $t4, -4, Pipe2Loop		# Draw pipe when in locations on screen
	j draw_pipe2_prep		# Generate new pipe

Pipe2Loop:			# Draw pipe 2 loop
	addi $t6, $t6, 1		# Increment counter
	bge $t4, 28, Pipe2R		# Draw pipe comming in from right
	bge $t4, 0, Pipe2M		# Draw pipe when moving through middle

Pipe2L:				# Draw pipe 2 disappearing into left
	sw $t2, 16($t0)			# paint back of pipe over with sky
	j Pipe2End			# Go to rest of loop

Pipe2R:				# Draw pipe 2 appearing from right
	sw $t1, 0($t0)			# Paint pipe
	j Pipe2End			# Go to rest of loop

Pipe2M:				# Draw pipe 2 moving through middle
	sw $t1, 0($t0)			# paint pipe 
	sw $t2, 16($t0)			# paint back of pipe over with sky

Pipe2End:			# Rest of pipe 2 loop
	addi $t0, $t0, 128		# Increment bitmap address
	li $t5, 0			# Store a counter at $t5 for gap
	beq $t6, $t3, Pipe2Skip		# If at gap position, do gap method
	bne $t6, 32, Pipe2Loop		# Loops until pipe is fully drawn
	j pipe2_store			# Save variables into memory

Pipe2Skip:			# Draw pipe 2 gap 
	addi $t6, $t6, 1		# Increment pipe counter
	addi $t5, $t5, 1		# Increment gap counter
	addi $t0, $t0, 128		# Increment bitmap address
	bne $t5, 12, Pipe2Skip		# Loop skip until gap is 12 units long
	j Pipe2Loop			# Return to drawing pipe loop

pipe2_store:			# Store pipe 2 variables into memory
	sw $t3 0($s1)			# Save pipe gap top into memory
	sw $t4 4($s1)			# Save pipe location into memory
	jr $ra				# Return to game loop
	
	
input_check:
	lw $t0, 0xffff0000
	andi $t0, $t0, 0x00000001  # Isolate ready bit
	beqz $t0, bird_both_fall	# If no input, both birds must fall
	# beq $t0, $zero, bird_fall
	#sw $zero, 0xffff0000
	
	# Check if they pressed "f"
	lbu $t0, 0xffff0004
	add $t1, $zero, $zero
	addi $t1, $t1, 102
	bne $t0, $t1, check_bird_2
	#sw $zero, 0xffff0000
	
	# If here, than there was input to the keyboard, and we must "raise" the bird
	add $t0, $zero, $zero

	lw $t0, 0($s2)
	addi $t0, $t0, 128
	sw $t0, 4($s2)
	subi $t0, $t0, 128
	subi $t0, $t0, 128
	sw $t0, 0($s2)
	j bird_2_fall

check_bird_2:

	# If 'f' wasn't inputted, the first bird must fall
	add $t4, $zero, $zero

	lw $t4, 0($s2)
	sw $t4, 4($s2)
	addi $t4, $t4, 128
	sw $t4, 0($s2)
	
	# Check if 'j' was pressed
	add $t1, $zero, $zero
	addi $t1, $t1, 106
	bne $t0, $t1, bird_2_fall

	# If here, than there was input to the keyboard, and we must "raise" the bird
	add $t0, $zero, $zero

	lw $t0, 0($s5)
	add $t2, $zero, $zero
	lw $t2, 0($s6)
	blez $t2, go_back
	
	addi $t0, $t0, 128
	sw $t0, 4($s5)
	subi $t0, $t0, 128
	subi $t0, $t0, 128
	sw $t0, 0($s5)

	j DONE
	
bird_both_fall:
	add $t4, $zero, $zero

	lw $t4, 0($s2)
	sw $t4, 4($s2)
	addi $t4, $t4, 128
	sw $t4, 0($s2)
	
bird_2_fall:
	# If no input at all, second bird needs to fall
	add $t0, $zero, $zero

	lw $t0, 0($s5)
	add $t2, $zero, $zero
	lw $t2, 0($s6)
	blez $t2, DONE
	sw $t0, 4($s5)
	addi $t0, $t0, 128
	sw $t0, 0($s5)
	
DONE:
	jr $ra
	
draw_bird:
	add $t0, $zero, $gp
	add $t1, $zero, $zero 		# Current position of bird
	lw $t1, 0($s2) 
	
	add $t2, $zero, $zero		# Old position (to re-color back the sky)
	lw $t2, 4($s2)
	
	# Color the previous (old first row back to sky)
	lw $t3, 0($s3)
	add $t4, $t0, $t2
	sw $t3, 0($t4)
	sw $t3, 4($t4)
	
	add $t5, $zero, $zero
	lw $t5, 0($t4)
	lw $t6, pipeColor
	beq $t5, $t6, Exit
	
	sw $t3, 8($t4)
	sw $t3, 12($t4)
	
	lw $t3, birdColor
	add $t4, $t0, $t1
	
	
	# Collision check [Top of bird] : Bird must fully clear pipe
	add $t5, $zero, $zero
	lw $t5, 0($t4)
	lw $t6, pipeColor
	beq $t5, $t6, Exit
	
	add $t5, $zero, $zero
	lw $t5, 4($t4)
	lw $t6, pipeColor
	beq $t5, $t6, Exit

	add $t5, $zero, $zero
	lw $t5, 8($t4)
	lw $t6, pipeColor
	beq $t5, $t6, Exit
	# End collision

	# First row
	sw $t3, 0($t4)
	sw $t3, 4($t4)
	sw $t3, 8($t4)
	sw $t3, 12($t4)
	
	# Collision check [Front of bird] : 
	add $t5, $zero, $zero
	lw $t5, 16($t4)
	lw $t6, pipeColor
	beq $t5, $t6, Exit
	
	add $t5, $zero, $zero
	lw $t5, 144($t4)
	lw $t6, pipeColor
	beq $t5, $t6, Exit
	
	# Second row
	sw $t3, 128($t4)
	sw $t3, 132($t4)
	sw $t3, 136($t4)
	sw $t3, 140($t4)
	
	# Collision check [Bottom of bird] : Bird must fully clear the pipe
	add $t5, $zero, $zero
	lw $t5, 256($t4)
	lw $t6, pipeColor
	beq $t5, $t6, Exit
	
	add $t5, $zero, $zero
	lw $t5, 260($t4)
	lw $t6, pipeColor
	beq $t5, $t6, Exit

	add $t5, $zero, $zero
	lw $t5, 264($t4)
	lw $t6, pipeColor
	beq $t5, $t6, Exit
	# End collision
	
	# Check if under the map
	add $t7, $zero, $zero
	add $t6, $zero, $zero
	addi $t6, $t6, 3968
	lw $t7, 0($s2)
	beq $t7, $t6, Exit
	# End collision
	
	# Check if over the map
	add $t7, $zero, $zero
	lw $t7, 0($s2)
	bltz $t7, Exit
	# End collision
	
	jr $ra
	
draw_bird_2:
	add $t0, $zero, $gp
	add $t1, $zero, $zero 		# Current position of bird
	lw $t1, 0($s5) 
	
	add $t2, $zero, $zero
	lw $t2, 0($s6)
	blez $t2, delete_bird_2
	
	add $t2, $zero, $zero		# Old position (to re-color back the sky)
	lw $t2, 4($s5)
	
	# Color the previous (old first row back to sky)
	lw $t3, 0($s3)
	add $t4, $t0, $t2
	sw $t3, 0($t4)
	sw $t3, 4($t4)
	
	add $t5, $zero, $zero
	lw $t5, 0($t4)
	lw $t6, pipeColor
	beq $t5, $t6, delete_bird_2
	
	sw $t3, 8($t4)
	sw $t3, 12($t4)
	
	lw $t3, birdColor2
	add $t4, $t0, $t1
	
	
	# Collision check [Top of bird] : Bird must fully clear pipe
	add $t5, $zero, $zero
	lw $t5, 0($t4)
	lw $t6, pipeColor
	beq $t5, $t6, delete_bird_2
	
	add $t5, $zero, $zero
	lw $t5, 4($t4)
	lw $t6, pipeColor
	beq $t5, $t6, delete_bird_2

	add $t5, $zero, $zero
	lw $t5, 8($t4)
	lw $t6, pipeColor
	beq $t5, $t6, delete_bird_2
	# End collision

	# First row
	sw $t3, 0($t4)
	sw $t3, 4($t4)
	sw $t3, 8($t4)
	sw $t3, 12($t4)
	
	# Collision check [Front of bird] : 
	add $t5, $zero, $zero
	lw $t5, 16($t4)
	lw $t6, pipeColor
	beq $t5, $t6, delete_bird_2
	
	add $t5, $zero, $zero
	lw $t5, 144($t4)
	lw $t6, pipeColor
	beq $t5, $t6, delete_bird_2
	
	# Second row
	sw $t3, 128($t4)
	sw $t3, 132($t4)
	sw $t3, 136($t4)
	sw $t3, 140($t4)
	
	# Collision check [Bottom of bird] : Bird must fully clear the pipe
	add $t5, $zero, $zero
	lw $t5, 256($t4)
	lw $t6, pipeColor
	beq $t5, $t6, delete_bird_2
	
	add $t5, $zero, $zero
	lw $t5, 260($t4)
	lw $t6, pipeColor
	beq $t5, $t6, delete_bird_2

	add $t5, $zero, $zero
	lw $t5, 264($t4)
	lw $t6, pipeColor
	beq $t5, $t6, delete_bird_2
	# End collision
	
	# Check if under the map
	add $t7, $zero, $zero
	add $t6, $zero, $zero
	addi $t6, $t6, 3968
	lw $t7, 0($s5)
	beq $t7, $t6, delete_bird_2
	# End collision
	
	# Check if over the map
	add $t7, $zero, $zero
	lw $t7, 0($s5)
	bltz $t7, delete_bird_2
	# End collision
go_back:
	jr $ra

delete_bird_2:

	add $t2, $zero, $zero
	lw $t2, 0($s6)
	blez $t2, go_back
	
	add $t0, $zero, $gp
	add $t1, $zero, $zero 		# Current position of bird
	lw $t1, 0($s5)
	lw $t3, 0($s3)
	sw $t3, 0($t4)
	sw $t3, 4($t4)
	sw $t3, 8($t4)
	sw $t3, 12($t4)
	sw $t3, 128($t4)
	sw $t3, 132($t4)
	sw $t3, 136($t4)
	sw $t3, 140($t4)
	add $t1, $zero, $zero
	sw $t1, 0($s5)
	sw $t1, 0($s6)
	jr $ra

Exit:
	
	add $t0, $zero, $gp		# Load bitmap address to $t0
	lw $t1, 0($s3)		# Load sky color to #t1
	sw $t1 0($s3)
	li $t2, 0			# Store a counter at $t2
	li $t3, 1024			# Store the counter limit at $t3

full_fill_end_screen:		# Loop for filling background
	sw $t1, 0($t0)			# paint a unit on bitmap
	addi $t0, $t0, 4		# increment bitmap address
	addi $t2, $t2, 1		# increment counter
	bne $t2, $t3, full_fill_end_screen 	# loop drawing background
	
	add $t0, $zero, $gp
	lw $t1, birdColor
	
	# Drawing the b
	sw $t1, 1576($t0)
	sw $t1, 1704($t0)
	sw $t1, 1832($t0)
	sw $t1, 1836($t0)
	sw $t1, 1840($t0)
	sw $t1, 1960($t0)
	sw $t1, 1968($t0)
	sw $t1, 2088($t0)
	sw $t1, 2092($t0)
	sw $t1, 2096($t0)
	
	# Drawing the y
	sw $t1, 1848($t0)
	sw $t1, 1856($t0)
	sw $t1, 1976($t0)
	sw $t1, 1984($t0)
	sw $t1, 2104($t0)
	sw $t1, 2108($t0)
	sw $t1, 2112($t0)
	sw $t1, 2240($t0)
	sw $t1, 2360($t0)
	sw $t1, 2364($t0)
	sw $t1, 2368($t0)
	
	# Drawing the E
	sw $t1, 1608($t0)
	sw $t1, 1612($t0)
	sw $t1, 1616($t0)
	sw $t1, 1736($t0)
	sw $t1, 1864($t0)
	sw $t1, 1868($t0)
	sw $t1, 1872($t0)
	sw $t1, 1992($t0)
	sw $t1, 2120($t0)
	sw $t1, 2124($t0)
	sw $t1, 2128($t0)
	
	# Drawing the !
	sw $t1, 1624($t0)
	sw $t1, 1752($t0)
	sw $t1, 1880($t0)
	sw $t1, 2136($t0)

	li $v0, 10 # terminate the program gracefully
	syscall
