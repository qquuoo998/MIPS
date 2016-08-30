# CS 61C Spring 2016 Project 2-2 
# symbol_list.s

#==============================================================================
#                              Project 2-2 Part 2
#                               SymbolList README
#==============================================================================
# In this file you will be implementing a linked list-based data structure for
# storing symbols. Its purpose is analogous to SymbolTable from Proj2-1, but to
# disinguish it we will call it SymbolList.
#
# Each node in the SymbolList contains a (addr, name) pair. An empty SymbolList
# is simply a pointer to NULL. As (addr, name) pairs are added to a SymbolList,
# new list nodes are dynamically allocated and appended to the front of the list. 
# However, as there is no free() in MARS, you do not need to write a free_list()
# function. You may use the functions in string.s during your implementation.
#
# You do not need to perform error checking on duplicate addr or name entries
# in SymbolList, nor do you need to do alignment checking. Don't worry about
# provided addresses being too big.
#
# If SymbolList were to be written in C, each list node would be declared as 
# follows:
#   typedef struct symbollist { 
#       int addr;
#       char* name;
#       struct symbollist* next; 
#   } SymbolList;
#
# You need to write addr_for_symbol().
# You will find test cases in linker-tests/test_symbol_list.s
#==============================================================================

.include "string.s"

.text

#------------------------------------------------------------------------------
# function addr_for_symbol()
#------------------------------------------------------------------------------
# Iterates through the SymbolList and searches for an entry with the given name.
# If an entry is found, return that addr. Otherwise return -1.
#
# Arguments:
#  $a0 = pointer to a SymbolList (NULL indicates empty list)
#  $a1 = name to look for
#
# Returns:  address of symbol if found or -1 if not found
#------------------------------------------------------------------------------
addr_for_symbol:
	# YOUR CODE HERE
	addiu $sp,$sp,-12
	sw $ra,0($sp)
	sw $s0,4($sp)
	sw $s1,8($sp)
	add $s0,$0,$a0			# s0 = pointer to a SymbolList (NULL indicates empty list)
	add $s1,$0,$a1			# s1 = name to look for
	
addr_for_symbol_loop:	
	beq $s0, $0, name_not_found	# Begin symbol_for_addr
	lw $t0, 4($s0)
	
	add $a0,$t0,$0
	add $a1,$s1,$0
	jal streq			# Compare strings
	
	beq $v0, 0, name_found
	lw $s0, 8($s0)
	j addr_for_symbol_loop
	
name_found:
	lw $v0, 0($s0)
	j addr_for_symbol_exit
	
name_not_found:
	li $v0, -1
	j addr_for_symbol_exit

addr_for_symbol_exit:
	lw $ra,0($sp)
	lw $s0,4($sp)
	lw $s1,8($sp)
	addiu $sp,$sp,12
	jr $ra			# End addr_for_symbol
	
###############################################################################
#                 DO NOT MODIFY ANYTHING BELOW THIS POINT                       
###############################################################################

#------------------------------------------------------------------------------
# function add_to_list()
#------------------------------------------------------------------------------
# Adds a (name, addr) pair to the FRONT of the list. 
#
# Arguments:
#   $a0 = ptr to list (may be NULL)
#   $a1 = address of symbol (integer)
#   $a2 = pointer to name of symbol (string)
#
# Returns: the new list
#------------------------------------------------------------------------------
add_to_list:	
	addiu $sp, $sp, -16		# Begin add_to_list
	sw $s0, 12($sp)
	sw $s1, 8($sp)
	sw $s2, 4($sp)
	sw $ra, 0($sp)
	move $s0, $a0	# $s0 = ptr to list
	move $s1, $a1	# $s1 = address of symbol 
	
	move $a0, $a2
	jal copy_of_str	# create copy of str
	move $s2, $v0
	
	jal new_node	# allocate space for new ListNode
	sw $s1, 0($v0)	# set node.addr = addr
	sw $s2, 4($v0)	# set node.name = copy of name
	sw $s0, 8($v0)	# set node.next = head
add_to_list_exit:
	lw $s0, 12($sp)
	lw $s1, 8($sp)
	lw $s2, 4($sp)
	lw $ra, 0($sp)
	addiu $sp, $sp, 16
	jr $ra			# End add_to_list

#------------------------------------------------------------------------------
# function symbol_for_addr()
#------------------------------------------------------------------------------
# Iterates through the SymbolList and searches for an entry with the given addr.
# If an entry is found, return a pointer to the name. Otherwise return NULL.
#
# Arguments:
#  $a0 = pointer to a SymbolList (NULL indicates empty list)
#  $a1 = addr to look for
#
# Returns: a pointer to the name if found or NULL if not found
#------------------------------------------------------------------------------
symbol_for_addr:
	beq $a0, $0, symbol_not_found	# Begin symbol_for_addr
	lw $t0, 0($a0)
	beq $t0, $a1, symbol_found
	lw $a0, 8($a0)
	j symbol_for_addr
symbol_found:
	lw $v0, 4($a0)
	jr $ra
symbol_not_found:
	li $v0, 0
	jr $ra			# End addr_for_symbol

#------------------------------------------------------------------------------
# function print_list() - DO NOT MODIFY THIS FUNCTION
#------------------------------------------------------------------------------
# Arguments:
#  $a0 = pointer to a SymbolList (NULL indicates empty list)
#  $a1 = print function
#  $a2 = file pointer
#------------------------------------------------------------------------------
print_list:
	addiu $sp, $sp, -16		# Begin print_list
	sw $s0, 12($sp)
	sw $s1, 8($sp)
	sw $s2, 4($sp)
	sw $ra, 0($sp)
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
print_list_loop:
	beq $s0, $0, print_list_end
	lw $a0, 0($s0)
	lw $a1, 4($s0)
	move $a2, $s2
	jalr $s1
	lw $s0, 8($s0)
	j print_list_loop
print_list_end:
	lw $s0, 12($sp)
	lw $s1, 8($sp)
	lw $s2, 4($sp)
	lw $ra, 0($sp)
	addiu $sp, $sp, 16
	jr $ra			# End print_list	

#------------------------------------------------------------------------------
# function print_symbol() - DO NOT MODIFY THIS FUNCTION
#------------------------------------------------------------------------------
# Prints one symbol to standard output.
#
# Arguments:
#  $a0 = addr of symbol
#  $a1 = name of symbol
#  $a2 = file pointer (this argument is actually ignored)
#
# Returns: none
#------------------------------------------------------------------------------
print_symbol:
	li $v0, 36			# Begin print_symbol()
	syscall
	la $a0, tab
	li $v0, 4
	syscall
	move $a0, $a1
	syscall
	la $a0, newline
	syscall
	jr $ra			# End print_symbol()

#------------------------------------------------------------------------------
# function write_symbol() - DO NOT MODIFY THIS FUNCTION
#------------------------------------------------------------------------------
# Writes one symbol to the file specified
#
# Arguments:
#  $a0 = addr of symbol
#  $a1 = name of symbol
#  $a2 = file pointer
#
# Returns: none
#------------------------------------------------------------------------------
write_symbol:		
	addiu $sp, $sp, -20		# Begin write_symbol()
	sw $s0, 16($sp)
	sw $s1, 12($sp)
	sw $a1, 8($sp)
	sw $a2, 4($sp)
	sw $ra, 0($sp)
	
	la $s0, temp_buf
	
	move $a1, $s0
	jal dec_to_str	# write int
	move $s1, $v0	
	
	addu $a0, $s0, $s1
	addiu $s1, $s1, 1
	la $a1, tab
	li $a2, 1
	jal strncpy		# write tab
	
	lw $a0, 8($sp)
	jal strlen
	
	addu $a0, $s0, $s1
	addu $s1, $s1, $v0
	lw $a1, 8($sp)
	move $a2, $v0
	jal strncpy		# write string
	
	addu $a0, $s0, $s1
	addiu $s1, $s1, 1
	la $a1, newline
	li $a2, 1
	jal strncpy		# write newline
	
	lw $a0, 4($sp)	# file ptr
	move $a1, $s0	# buffer to write
	move $a2, $s1	# num chars to write
	li $v0, 15
	syscall		# write to file
	
	lw $s0, 16($sp)
	lw $s1, 12($sp)
	lw $ra, 0($sp)
	addiu $sp, $sp, 20
	jr $ra			# End write_symbol()
	
#------------------------------------------------------------------------------
# function new_node() - DO NOT MODIFY THIS FUNCTION
#------------------------------------------------------------------------------
# Creates a new uninitialized SymbolList node.
# Arguments: none
# Returns: pointer to a SymbolList node
#------------------------------------------------------------------------------
new_node:	
	li $a0, 12			# Begin new_node()
	li $v0, 9
	syscall
	jr $ra			# End new_node()
	
.data 
temp_buf:	.space 1024
