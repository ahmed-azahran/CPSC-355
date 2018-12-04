/*
CPSC 355, Fall 2018
Assignment 4, Ahmed Zahran - 30040767
*/

//FALSE and TRUE equates
FALSE = 0                                        // Sets FALSE to 0
TRUE = 1                                         // Sets TRUE to 1

//Box variable offsets; box size
point_x_s = 0                                    // Offset for point x
point_y_s = 4                                    // Offset for point y
dim_width_s = 8                                  // Offset for dimension width
dim_height_s = 12                                // Offset for dimension height
area_s = 16                                      // Offset for area
box_size = 20                                    // Total size of box (5*4=20)

//Extra memory allocation and offsets for main
alloc = -(16 + (box_size * 2)) & -16             // Extra memory allocated for the two boxes in main
dealloc = -alloc                                 // Amount to deallocate when done
first_s = 16                                     // Offset for first box
second_s = first_s + box_size                    // Offset for second box

//Memory allocation for newbox
newbox_alloc = -(16 + box_size) & -16            // Extra memory allocated for newbox
newbox_dealloc = -newbox_alloc                   // Amount to deallocate when done

//Memory Allocation for the equal method
result_s = 16                                    // Offset for the result variable in stack
result_size = 4                                  // Size for the result variable
equal_alloc = (-16+ result_size) & -16           // Extra memory allocated for the eual method
equal_dealloc = -alloc                           // Amount to deallocate when done

//Register equates
fp        .req x29                               // x29 --> fp
lr        .req x30                               // x30 --> lr

//Strings
printbox: .string "Box %s origin = (%d, %d)  width = %d  height = %d  area = %d\n" //String for printbox method

first:    .string "first"                        // "first" string
second:   .string "second"                       // "second" string
initial:  .string "Initial box values:\n"        // String for intial box
changed:  .string "\nChanged box values:\n"      // String for changed box

          .balign 4                              // word allignment

//newBox method
newBox:
          stp fp, lr, [sp, newbox_alloc]!        // Allocate needed memory for function
          mov fp, sp                             // Set sp equal to fp

          add x9, fp, box_size                   // Set x9 equal to fp + box size (x9 is base memory address of the local variable in newbox)
          str xzr, [x9, point_x_s]               // Store zero in the local variable's point_x field
          str xzr, [x9, point_y_s]               // Store zero in its point_y field
          mov w10, 1                             // Set w10 equal to the constant 1
          str w10, [x9, dim_width_s]             // Set the local variable's dimension width field to 1
          str w10, [x9, dim_height_s]            // Set it's height field to 1
          ldr w10, [x9, dim_width_s]             // Set w10 equal to the width field
          ldr w11, [x9, dim_height_s]            // Set w11 equal to the height field
          mul w10, w11, w10                      // Set w10 equal to the product of it and w11 (height * width)
          str w10, [x9, area_s]                  // Put w10 in the area field

          ldr w10, [x9, point_x_s]               // Load off memory the value of the point_x field of the local variable
          str w10, [x8, point_x_s]               // Store it's contents in the memory address pointed to by x8 (the main method Puts the memory address of either first or second in x8, so to modify first/second, we have to  access x8)
          ldr w10, [x9, point_y_s]               // Load off memory point_y
          str w10, [x8, point_y_s]               // Store it in the main method's variable
          ldr w10, [x9, dim_width_s]             // Load off memory dim_width
          str w10, [x8, dim_width_s]             // Store it in the main method's variable
          ldr w10, [x9, dim_height_s]            // Load off memory dim_height
          str w10, [x8, dim_height_s]            // Store it in the main method's variable
          ldr w10, [x9, area_s]                  // Load off memory the area
          str w10, [x8, area_s]                  // Store it in the main method's variable

          ldp fp, lr, [sp], newbox_dealloc       // Deallocate extra memory allocated to newbox
          ret                                    // Return to main method

//move method
move:
          stp fp, lr, [sp, -16]!                 // Allocate memory for move method
          mov fp, sp                             // Update fp

          ldr w9, [x0, point_x_s]                // Set w9 to the value of point_x (x0 holds the memory address of the struct in main)
          add w9, w9, w1                         // Set w9 equal to point_x + deltax
          str w9, [x0, point_x_s]                // Set the updated w9 back into the struct
          ldr w9, [x0, point_y_s]                // Set w9 equal to point_y
          add w9, w9, w2                         // Set w9 equal to point_y + deltay
          str w9, [x0, point_y_s]                // Set the updated w9 back into the struct

          ldp fp, lr, [sp], 16                   // Deallocate used memory
          ret                                    // Return

//expand method
expand:
          stp fp, lr, [sp, -16]!                 // Allocated memory for expand method
          mov fp, sp                             // Update fp

          ldr w9, [x0, dim_width_s]              // Set w9 equal to the width (x0 holds the memory address of the struct in main)
          mul w9, w9, w1                         // Multiply w9 by the factor
          str w9, [x0, dim_width_s]              // Set the updated w9 back into the struct
          ldr w9, [x0, dim_height_s]             // Set w9 equal to the height
          mul w9, w9, w1                         // Multiply w9 by the factor
          str w9, [x0, dim_height_s]             // Set the updated w9 back into the struct
          ldr w10, [x0, dim_width_s]             // Set w10 equal to the updated width
          mul w9, w9, w10                        // Multiply w9 (the updated height) by the updated height to make w9 the updated area
          str w9, [x0, area_s]                   // Set the updated area in w9 back into the struct

          ldp fp, lr, [sp], 16                   // Deallocate used memory
          ret                                    // Return

//printBox method
printBox:
          stp fp, lr, [sp, -16]!                 // Allocate printbox memory
          mov fp, sp                             // Update fp

          //x1 will hold the memory address of the provided variable, allowing it to be accessed
          ldr x2, [x1, point_x_s]                // Set x2 to the value of point_x
          ldr x3, [x1, point_y_s]                // Set x3 to the value of point_y
          ldr x4, [x1, dim_width_s]              // Set x4 to the value of dim_width
          ldr x5, [x1, dim_height_s]             // Set x5 to the value of dim_height
          ldr x6, [x1, area_s]                   // Set x6 to the value of area

          mov x1, x0                             // Move the string parameter (already set up in main) to the second parameter
          adrp x0, printbox                      // Put the box string in x0
          add x0, x0, :lo12:printbox             // Format it's lower 12 bits correctly
          bl printf                              // Call printf

          ldp fp, lr, [sp], 16                   // Deallocate used memory
          ret                                    // Return

//equal method
equal:
          stp fp, lr, [sp, equal_alloc]!         // Allocate memory for method
          mov fp, sp                             // Update fp

          mov w9, FALSE                          // Initially, set w9 to FALSE (0)
          str w9, [fp,result_s]

          ldr w10, [x0, point_x_s]               // Set w10 to the point_x variable in first
          ldr w11, [x1, point_x_s]               // Set w11 to the point_x variable in second
          cmp w10, w11                           // Compare them
          b.ne equal_end                         // If they aren't equal, branch to equal_end

         ldr w10, [x0, point_y_s]               // Set w10 to the point_y variable in first
         ldr w11, [x1, point_y_s]               // Set w11 to the point_y variable in second
         cmp w10, w11                           // Compare them
         b.ne equal_end                         // If they aren't equal, branch to equal_end

         ldr w10, [x0, dim_width_s]             // Set w10 to the width variable in first
         ldr w11, [x1, dim_width_s]             // Set w11 to the width variable in second
         cmp w10, w11                           // Compare them
         b.ne equal_end                         // If they aren't equal branch to equal_end

         ldr w10, [x0, dim_height_s]            // Set w10 to the height variable in first
         ldr w11, [x1, dim_height_s]            // Set w11 to the height variable in second
         cmp w10, w11                           // Compare them
         b.ne equal_end                         // If they aren't equal, branch to equal_end

         mov w9, TRUE                           // Set w9 to TRUE.
         str w9, [fp, result_s]
         ldr w0, [fp, result_s]

equal_end:
          ldp fp, lr, [sp], 16                   // Deallocate used memory
          ret                                    // Return (result is in w0)

          .global main                           // Make main method visible to compiler
//Main method
main:
          stp fp, lr, [sp, alloc]!               // Allocate  memory
          mov fp, sp                             // Set fp equal to sp


          add x8, fp, first_s                    // Put fp plus the offset for first in x8 (this sets x8 equal to the memory address for first, allowing newbox to modify it)
          bl newBox                              // Call newbox for first

          add x8, fp, second_s                   // Put fp plus the offset for second in x8 (this sets x8 equal to the memory address for second, allowing newbox to modify it)
          bl newBox                              // Call newbox for second

          adrp x0, initial                       // Set up the string for initial box values
          add x0, x0, :lo12:initial              // Load lower 12 bits
          bl printf                              // Call printf

          adrp x0, first                         // Set up printBox parameter string correctly
          add x0, x0, :lo12:first                // Load  lower 12 bits
          add x1, fp, first_s                    // Put memory address of first in x1
          bl printBox                            // Call printBox (when printbox calls printf, the string in x0 is prepared for it already)

          adrp x0, second                        // Set up printbox parameter string correctly
          add x0, x0, :lo12:second               // Load lower 12 bits
          add x1, fp, second_s                   // Put memory address of second in x1 (it is prepared for printbox already)
          bl printBox                            // Call printBox

          add x0, fp, first_s                    // Put memory address of first in x0
          add x1, fp, second_s                   // Put memory address of second in x1
          bl equal                               // Call equal
          cmp w0, FALSE                          // Compare result of equal cal with FALSE (which is 0)
          b.eq continue                          // If the result is 0, skip next instructions and go to continue

          add x0, fp, first_s                    // Put memory address of first in x0
          mov w1, -5                             // Put constant -5 in w1
          mov w2, 7                              // Put constant 7 in w2
          bl move                                // Call move function

          add x0, fp, second_s                   // Put memory address of second in x0
          mov w1, 3                              // Put constant 3 in w1
          bl expand                              // Call expand function

continue:
          adrp x0, changed                       // Set up changed box values string
          add x0, x0, :lo12:changed              // Load lower 12 bits
          bl printf                              // Call printf

          adrp x0, first                         // Format first string
          add x0, x0, :lo12:first                // Load lower 12 bits
          add x1, fp, first_s                    // Put memory address of first in x1
          bl printBox                            // Call printbox

          adrp x0, second                        // Format second string
          add x0, x0, :lo12:second               // Load lower 12 bits
          add x1, fp, second_s                   // Put memory address of first in x1
          bl printBox                            // Call printbox

          ldp fp, lr, [sp], dealloc              // End instruction; deallocate used memory
          ret                                    // End program

