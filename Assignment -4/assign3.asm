/*
CPSC 355, Fall 2018
Assignment 3, Ahmed Zahran (30040767)
*/

//Assembler Equates
SIZE = 50                                     //Size of array
v_size = 4*SIZE                               // Allocate 50 * 4 bytes in memory for the array.
i_size = 4                                    //Size of int i
j_size = 4                                    //Size of int j
temp_size = 4                                 //Size of int temp


//Memory Allocation
alloc = -(16 + i_size + j_size + temp_size + v_size) & -16    // Set the pre-increment value "alloc", for updating the Stack Pointer. "AND" -16 to quadword align.
dealloc = -alloc                              // Set the post-increment value, for updating SP after frame record is popped.

//Offsets
i_s = 16                                      // Set the stack offset (from fp) for variable i to 16
j_s = 20                                      // Set the stack offset (from fp) for variable i to 20
temp_s = 24                                   // Set the stack offset (from fp) for variable i to 24
v_s = 28                                      // Set the stack offset (from fp) for v[0] to 28

// Print Statements
string1: .string "v[%d]: %d\n"                // The print function for printing each line in the array.
string2: .string "\nSorted Array:\n"          // The second print function, which produces the title "Sorted array: "

define(base_r, x19)                           // Define the register holding the stack adress for the base of the array.
define(ls_r, w22)						                  // Define the register for multiple load and store ls_r.
define(temp_r,w21)                            // Define the register holding the temp values in register w21

fp .req x29						                       	// Define fp as fp
lr .req x30						                       	// Define lr as x30

         .balign 4                            // Instructions must be quadword aligned (4 bytes)
         .global main                         // Make main visible to the OS

main:
         stp fp, lr , [sp, alloc]!            // Save FP and LR to stack, allocating by the amount "alloc", pre-increment SP.
         mov fp, sp                           // Update frame pointer (FP) to current stack pointer (SP)
         add base_r, fp, v_s                  // Calculate base_r to be the sum of the frame pointer and v[0]'s offset

         mov ls_r, 0                          // Set index to zero.
         str ls_r, [fp, i_s]                  // Initialize i to 0 for the for loop
         b test_1                             // Branch to optimized test_1

loop_1:
         bl rand                              // Get a random number from the pseudo-random number generator.
         and temp_r, w0, 0xFF                 // AND value of random with 0xFF, so that the number is between 0 and 255
         str temp_r, [base_r, ls_r, SXTW 2]   // Note that ls_r always = i at this point in code. So, v[i] is stored in the temp_r

         adrp x0, string1                     // Print out the value to standard output, in the form "v[i] = x"
         add x0, x0, :lo12:string1            // Add lower-order bits to x0 for string1
         mov w1, ls_r                         // Move i into w1
         mov w2, temp_r                       // Load v[i] from memory, and put it into register w2
         bl printf                            // Use bl (branch to label) to call function printf()

         add ls_r, ls_r, 1                    // Increment i by 1
         str ls_r, [fp, i_s]                  // Store new i in memory

test_1:
         cmp ls_r, SIZE                       // See if i is greater than SIZE
         b.lt loop_1                          // If i < 50 , rerun loop

         mov ls_r, 1                          // Set ls_r to 1
         str ls_r, [fp, i_s]                  // Initialize i to 1 for the outer loop
         b test_2a                            // Branch to outer loop's test

loop_2a:
         ldr temp_r , [base_r, ls_r, SXTW 2]  // Set temp_r to v[1]
         str temp_r, [fp, temp_s]             // Store value of v[i] to temp_r

         ldr ls_r, [fp, i_s]                  // Set ls_r to i
         str ls_r, [fp, j_s]                  // Initialize j to i for the inner loop
         b test_2b                            // Branch to inner loop's test

loop_2b:
         ldr ls_r, [fp, j_s]                  // Set ls_r to j
         sub ls_r, ls_r, 1                    // Set ls_r to j-1
         ldr temp_r, [base_r, ls_r, SXTW 2]   // load v[j-1] to temp_r
         add ls_r, ls_r, 1                    // Increment ls_r, so now ls_r = j
         str temp_r, [base_r, ls_r, SXTW 2]   // Store v[j-1] in temp_r
         sub ls_r, ls_r, 1                    // Decrement ls_r, so now ls_r = j - 1
         str ls_r, [fp, j_s]                  // Decrement j and store it's new value in memory at the end of inner loop

test_2b:
         ldr ls_r, [fp, j_s]                  // ls_r = j
         cmp ls_r, 0                          // Compare ls_r(=j) to 0
         b.le post_inner                      // If j is less than or equal to 0, exit the loop
         ldr temp_r, [fp, temp_s]             // temp_r = temp
         sub w22, ls_r, 1                     // w22 = j-1
         ldr w23, [base_r, w22, SXTW 2]       // w23 = v[j-1]
         cmp temp_r, w23                      // Compare temp and v[j-1]
         b.ge post_inner                      // If temp is greater than or equal to 0, exit the loop
         b loop_2b                            // If both of the above conditions are false, then rerun loop_2a

//post_inner loop
post_inner:
         ldr ls_r, [fp, temp_s]               // load the temp value to the ls_r
         ldr temp_r, [fp, j_s]                // load the j index to the temp_r
         str ls_r, [base_r, temp_r, SXTW 2]   // v[j] = temp

         ldr ls_r, [fp, i_s]                  // load theh i index to the ls_r
         add ls_r, ls_r, 1                    // Increment i at the end of outer loop
         str ls_r, [fp, i_s]                  // Store new i

test_2a:
        cmp ls_r, SIZE                        // Compare i to SIZE
         b.lt loop_2a                         // If i is less than SIZE, rerun loop_2a

         //end of program
         adrp x0, string2                     // Print out the value to standard output, in the form "Sorted Array:"
         add x0, x0, :lo12:string2            // Add lower-order bits to x0 for string2
         bl printf                            // Use bl (branch to label) to call function printf()

         mov ls_r, 0                          // ls_r = 0
         str ls_r, [fp, i_s]                  // Initialize i to 0 and store it in memory for final loop
         b endtest                            // Branch to endtest

endloop:
         adrp x0, string1                     // Print out the value to standard output, in the form "v[i] = x"
         add x0, x0, :lo12:string1            // Add lower-order bits to x0 for string1
         mov w1, ls_r                         // Set w1 to i
         ldr temp_r, [base_r, ls_r, SXTW 2]   // Load value of v[i] to temp_r
         mov w2, temp_r                       // Move temp_r in w2
         bl printf                            // Use bl (branch to label) to call function printf()
         add ls_r, ls_r, 1                    // Increment i for outer loop
         str ls_r, [fp, i_s]                  // Store new i value in memory

endtest:
         cmp ls_r, SIZE                       // Compare i to SIZE
         b.lt endloop                         // Rerun endloop if i is less than SIZE

         mov w0, 0                            // Return 0 to OS
         ldp fp, x30, [sp], dealloc           // Deallocate stack memory
         ret                                  // Returns to caling code in OS
