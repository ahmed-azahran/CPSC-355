// Ahmed Zahran - 30040767


//Defining all the m4 macros for x,y and max values 

define(x_r,x21)  //assigns x/loop counter to x21
define(y_r,x26)  //assigns y value to x26
define(max,x20)  //assigns max value to x20

//Defining m4 macros for coefficients

define(int_5,x22) // -5 --> x22
define(int_31,x23) // -31 --> x23
define(int4,x24)  // 4 --> x24
define(int31,x28) // 31 --> x28

// Defining m4 macros for intermediate terms

define(xcube,x26) // x^3 --> x26
define(xsec,x25)  // 2nd term --> x25
define(x34,x27) // 3rd and 4th term --> x27




fmt:  .string "   The current x value: %d \n   The curent y value: %d \n   The current maximum: %d \n \n"

      // Define the main function for our program
      .balign 4                    // Instructions must be word aligned
      .global main                 // Make "main" visible to the OS
main: stp x29, x30, [sp, -16]!     // Save frame pointer (fp, x29) and link register (lr, x30) to stack, allocating 16 bytes, pre-increment SP
      mov x29, sp                  // Update frame pointer (fp) to current stack pointer (sp) (after we've incremented sp in the last step)

      mov max, -5000	            // setting the intial max value small enough for comparison 
      mov x_r, -6		   // x value counter starts at -6
      mov int_5, -5 		  // 1st term coefficient
      mov int_31, -31            // 2nd term coeffecient
      mov int4, 4		// 3rd term coeffecient
      mov int31, 31            // the constant value 
         			
 	// While loop (pre-test, so check before the first iteration)     
         
      b test	               

loop:
      // Start of code inside the loop
     
      // calculations of the seperate terms
	
      mul xsec,x_r,x_r       // = x*x
      mul xcube,xsec,x_r       // = x*x*x
       
      // calculations for y
     
      madd x34,x_r,int4,int31  // = 4x+31
      madd xsec,xsec,int_31,x34      // = -31*x^2+4x+31
      madd y_r,xcube,int_5,xsec      // = -5*x^3-31*x^2+4x+31

      cmp y_r,max        // compares the y value with the previous y value 
      b.gt max		// branches to max if y > max 
     
      b print		// branches to print unconditioanly 

test: cmp  x_r, 5                 // Compares loop counter and 5
      b.le loop                    // If [loop counter]<=5, branch to loop 
      b done	                  // branch to done 
 
   	
max:
      mov max,y_r       // puts the new max value in x20 register



print: 
      adrp x0, fmt                 // Set the 1st argument of printf(fmt, var1, var2...) (high-order bits)
      add  x0, x0, :lo12:fmt       // Set the 1st argument of printf(fmt, var1, var2...) (lower 12 bits)
     
      mov x1,x_r		  // moves the x value to x1 register to be returned 
      mov x2,y_r		 // moves the y value to x2 register to be returned
      mov x3,max		// moves the max value to x3 register to be returned

      bl   printf // Call the printf() function
      // End of code inside the loop

      add  x_r, x_r, 1             // Increment loop counter by 1
      b    test                    // Loop iteration has ended, goto test to see if we should execute loop again

      // Return 0 in main
done: mov  x0, 0

      // Restore registers and return to calling code (OS)
      ldp  x29, x30, [sp], 16      // Restore fp and lr from stack, post-increment sp
      ret                          // Return to calleri
