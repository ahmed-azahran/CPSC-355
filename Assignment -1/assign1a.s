// Ahmed Zahran - 30040767


fmt:  .string "   The current x value: %d \n   The curent y value: %d \n   The current maximum: %d \n \n"

      // Define the main function for our program
      .balign 4                    // Instructions must be word aligned
      .global main                 // Make "main" visible to the OS
main: stp x29, x30, [sp, -16]!     // Save frame pointer (fp, x29) and link register (lr, x30) to stack, allocating 16 bytes, pre-increment SP
      mov x29, sp                  // Update frame pointer (fp) to current stack pointer (sp) (after we've incremented sp in the last step)

      mov x20, -5000	  	    // setting the max value small enough for comparison 
      mov x21, -6		   // counter starts at -6
      mov x22, -5 		  // 1st term coefficient
      mov x23, -31               // 2nd term coeffecient
      mov x24,  4		// 3rd term coeffecient

      // While loop (pre-test, so check before the first iteration)
      
test: cmp  x21, 5                 // Compares loop counter and 5
      b.gt done                    // If [loop counter]>=5, exit loop and branch to "done"


loop:
      // Start of code inside the loop
     
      // calculations of the seperate terms
	
      mul x19,x21,x24       // = 4x
      mul x25,x21,x21       // = x*x
      mul x26,x21,x25       // = x*x*x
      
      mul x25,x25,x23      // = -3*x^2
      mul x26,x26,x22      // = -5*x^3
      
      // calculations for y
     
      add x26,x26,x25       // = -5x^3 - 3x^2 	
      add x26,x26,x19      // = -5x^3 - 3x^2 + 4x
      add x26,x26,31      // = -5x^3 - 3x^2 + 4x + 31

      cmp x26,x20        // compares the y value with the previous y value 
      b.gt max           // branches to max if the new y value is greater than the previous one
      b print		// branches to print uncondtionaly 
     	
 max:
      mov x20,x26       // puts the new max value in x20 register



print: 
      adrp x0, fmt                 // Set the 1st argument of printf(fmt, var1, var2...) (high-order bits)
      add  x0, x0, :lo12:fmt       // Set the 1st argument of printf(fmt, var1, var2...) (lower 12 bits)
     
      mov x2,x26		  // moves the y value to the x2 register to be returned 
      mov x1,x21		 // moves the x value to x1 register to be returned
      mov x3,x20		// moves the max value to x3 register to be returned

      bl   printf 		// Call the printf() function
      // End of code inside the loop

      add  x21, x21, 1             // Increment loop counter by 1
      b    test                    // Loop iteration has ended, goto test to see if we should execute loop again

      // Return 0 in main
done: mov  w0, 0

      // Restore registers and return to calling code (OS)
      ldp  x29, x30, [sp], 16      // Restore fp and lr from stack, post-increment sp
      ret                          // Return to calleri
