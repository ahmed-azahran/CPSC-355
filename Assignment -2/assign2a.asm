// Optimized program to implement the integer multiplication program in c Code by using 32-bit register for variables declared using int, and 64-bit register for variables declared using long int.

// Define M4 macros
//int
define(loop_r, w19)                                     // loop counter register
define(muler_r, w20)                                    // multiplier register
define(mulcand_r, w21)                                  // multiplicand register
define(product_r, w22)                                  // product register
define(flag_r, w26)                                     // flag register
define(muler1_r, w27)                                   // true or false (1 or 0) register
//long int
define(result_r, x23)                                   // result register
define(temp1_r, x24)                                    // temp value 1 register
define(temp2_r, x25)                                    // temp value 2 register
define(casting_r, x28)                                  // casting register

// Define format string for call to printf()
// print out initial values of variables
fmt_1:      .string "multiplier = 0x%08x (%d) multiplicand = 0x%08x (%d)\n\n"
// print out product and multiplier
fmt_2:      .string "product = 0x%08x multiplier = 0x%08x \n"
// print out 64-bit result
fmt_3:      .string "64_bit result = 0x%016lx (%ld)\n"

            // Define the main function for our program
            .balign 4                                   // Instruction must be word aligned
            .global main                                // Make "main" visible to the OS

main:       stp         x29, x30, [sp, -16]!              // Save frame pointer (fp, x29) and link register (lr, x30) to stock, allocating 16 bytes, ore_increment SP
            mov         x29, sp                          // Update frame pointer (fp) to current stack pointer (sp) (after we've increment sp in the last step)

            mov         loop_r, 0                       // sets w19 general purpose register to 0, this will be the loop counter
            mov         muler_r, 70                     // sets the multiplier register to a value of 70
            mov         mulcand_r, -16843010            // sets the multiplicant register to a value of -16843010 
            mov         product_r, 0                    // sets the product register f=toa value of 0
            mov         flag_r, 0                       // sets the flag register to 0 (false)

            // Print out the initial values of variables
            adrp        x0, fmt_1                       // sets the 1st argument of printf(fmt_1, var1, var2) (high-order bits)
            add         x0, x0, :lo12:fmt_1             // sets the 1st argument of printf(fmt_1, var1, var2) (lower 12 bits)
            mov         w1, muler_r                     // place the multiplier in the parameters
            mov         w2, muler_r                     // place it again, it is used twice in the string
            mov         w3, mulcand_r                   // place the multiplicand in the parameters
            mov         w4, mulcand_r                   // place it again, it is used twice in the string

            bl          printf                          // Calls the printf() function

            // Determine if multiplier is negative
            cmp         muler_r, 0                      // compares the multiplier register and zero
            b.ge        false                           // If multiplier >= 0, it will return false
            mov         muler1_r, 1                     // If it is true, make true/false register to 1
            b           true                            // unconditionally branch to true

false:      mov         muler1_r, 0                     // If it is false, make true/false register to 0


true:       // Do repeated add and shift
            b           test                            // Branch to loop test at bottom

top:        // Start of code inside loop
            ands        flag_r, muler_r, 0x1            // adds 0x1 to the multiplier and adds it to the flag register, it also sets the condition flag
            b.eq        continue                        // If addition = 0, branch to continue
            add         product_r, product_r, mulcand_r // adds the multiplicant and the product and puts the answer in the product register


continue:   // Arithmetic shift right the combined product and multiplier
            asr         muler_r, muler_r, 1             // do an arithmetic shift right on the w_multiplier by 1
            ands        flag_r, product_r, 0x1          // evaluate (proudct & 0x1)
            b.eq        continue1                       // if they are equal branch to continue 1

            orr         muler_r, muler_r, 0x80000000    // update the multiplier via inclusive or
            b           next                            // unconditionally branch to next

continue1:  and         muler_r, muler_r, 0x7FFFFFFF    // update the multiplier via and operation



next:       asr         product_r, product_r, 1         // update the product by an arithmetic shift right

// End of code inside the loop
            add         loop_r, loop_r, 1               		// Increment loop by 1

// Loop test
test:       cmp         loop_r, 32                      // compare the loop register value with 32
	    b.lt        top                             // If [loop counter] >= 32, exit loop and branch to "done"

done:       // Determine if multiplier is negative
	    cmp         muler1_r, 0                     // compares the multiplier register with zero to see if it is positive or negative
	    b.eq        else                            // If muler1_r == 0 (false condition), branch to else
	    sub         product_r, product_r, mulcand_r // update the product by changing the multiplicand

else:       // Print out product and multiplier
	    adrp        x0, fmt_2                       // Set the 1st argument of printf(fmt_2, var1, var2) (high-order bits)
	    add         x0, x0, :lo12:fmt_2             // Set the 1st argument of printf(fmt_2, var1, var2) (lower 12 bits)
	    mov         w1, product_r                   // place the producut in the paremeters
	    mov         w2, muler_r                     // place the multiplier in the parameters

	    bl          printf                          // Call the printf() function

	// Combine product and multiplier together
	    sxtw        casting_r, product_r            //sign extend the 32 bit product to 64 bits
            and         temp1_r, casting_r, 0xFFFFFFFF  //evaluate product & 0xFFFFFFF using and
	    lsl         temp1_r, temp1_r, 32            //update temp by doing a logical shift left
	    sxtw        casting_r, muler_r              //sign extend the 32 bit multiplier to 64 bits
	    and         temp2_r, casting_r, 0xFFFFFFFF  //evaluate multiplier & 0xFFFFFFFF
	    add         result_r, temp1_r, temp2_r      //evaluate result


// Print out 64-bit result
	    adrp        x0, fmt_3                       // Set the 1st argument of printf(fmt_3, var1, var2) (high-order bits)
            add         x0, x0, :lo12:fmt_3             // Set the 1st argument of printf(fmt_3, var1, var2) (lower 12 bits)
	    mov         x1, result_r                    // place the result in the parameters
	    mov         x2, result_r                    // place the result again

	    bl          printf                          // Call the printf() function

// Return 0 in main
            mov         w0, 0

// Restore Registers and return to calling code (OS)
	    ldp         x29, x30, [sp], 16                // Restore FP and LR from stack, post-increment SP
	    ret                                         // Return to caller
