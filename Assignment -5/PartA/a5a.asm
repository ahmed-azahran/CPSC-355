/*
CPSC 355, Fall 2018
Ahmed Zahran - 30040767
*/

//Assembler Equates
//Global variables
QUEUESIZE = 8                                                                   //Queuesize, set to 8
MODMASK = 0x7                                                                   //The modmask
FALSE = 0                                                                       //Sets FALSE to 0
TRUE = 1                                                                        //Sets TRUE to 1

//Strings Decleration
enq_str:       .string "\nQueue overflow! Cannot enqueue into a full queue.\n"
deq_str:       .string "\nQueue underflow! Cannot dequeue from an empty queue.\n"
disp_str:      .string "\nEmpty queue\n"
disp_curr:     .string "\nCurrent queue contents:\n"
disp_for:      .string " %d"
disp_head:     .string " <-- head of queue"
disp_tail:     .string " <-- tail of queue"
disp_newline:  .string "\n"

.data                                                                           //Puts  these variables in data section
   head: .word -1                                                               //Initialize head global variable and allocates it to memory
   tail: .word -1                                                               //Initialize tail global variable and allocates it to memory
.bss                                                                            //BSS section for queue
   queue: .skip QUEUESIZE * 4                                                   //Initialize queue int array global variable and allocates it to memory
.text                                                                           //Go back to text section

//Macros
//Defining variables of enqueue() function.
define(enqueue_val_r, w9)
define(enqueue_tail_r, w10)

//Defining variables of dequeue() function.
define(dequeue_val_r, w11)
define(dequeue_head_r, w12)
define(dequeue_tail_r, w13)

//Defining variables of queueFull() function.
define(Qfull_head_r, w14)
define(Qfull_tail_r, w15)

//Defining variables of queueEmpty() function.
define(Qempty_head_r, w19)

//Defining variables of display() function.
define(disp_i_r, w20)
define(disp_j_r, w21)
define(disp_count_r, w22)
define(disp_tail_r, w23)
define(disp_head_r, w24)
define(disp_base_r, x25)

//4-bit allignment
.balign 4
//Making the functions global
.global queueEmpty
.global queueFull
.global dequeue
.global display
.global enqueue

//enqueue function
enqueue:
            stp x29, x30, [sp, -16]!                                            //Memory Alloctaion
            mov x29, sp                                                         //Update x29

            mov enqueue_val_r, w0                                               //Stores the parameter to enqueue() in a safe place
            bl queueFull                                                        //Calls the queueFull function to ensure the queue isn't fill
            cmp w0, TRUE                                                        //Checks if the result of queueFull is TRUE (1)
            b.ne enqueue_next1                                                  //If it is not, continue the function and go to enqueue_next1
            adrp x0, enq_str                                                    //Else, set up the error message
            add x0, x0, :lo12:enq_str                                           //Formats the low order 12 bits  equally
            bl printf                                                           //Calls printf to print out the error message
            b enqueue_end                                                       //Branch to end of function

enqueue_next1:
            bl queueEmpty                                                       //Calls queueEmpty function
            cmp w0, TRUE                                                        //Checks if it returned true (meaning queue is empty)
            b.ne enqueue_next2                                                  //If it didn't, then continue the function at enqueue_next2

            adrp disp_base_r, head                                              //Puts head address in base array
            add disp_base_r, disp_base_r, :lo12:head                            //Formats low order 12 bits correctly
            str wzr, [disp_base_r]                                              //Sets head = 0
            adrp disp_base_r, tail                                              //Puts tail address in base array
            add disp_base_r, disp_base_r, :lo12:tail                            //Formats low order 12 bits correctly
            str wzr, [disp_base_r]                                              //Sets tail = 0
            b enqueue_next3                                                     //Then branch to enqueue_next3

enqueue_next2:
            adrp disp_base_r, tail                                              //Puts tail address in base array
            add disp_base_r, disp_base_r, :lo12:tail                            //Formats low order 12 bits correctly

            ldr enqueue_tail_r, [disp_base_r]                                   //Sets enqueue_tail_r to tail
            add enqueue_tail_r, enqueue_tail_r, 1                               //Sets enq_tail = tail++
            and enqueue_tail_r, enqueue_tail_r, MODMASK                         //enq_tail = tail++ & modmask
            str enqueue_tail_r, [disp_base_r]                                   //Update tail (tail = enq_yail)

enqueue_next3:
            ldr enqueue_tail_r, [disp_base_r]                                   //Load tail
            adrp disp_base_r, queue                                             //Puts queue address in base array
            add disp_base_r, disp_base_r, :lo12:queue                           //Formats low order 12 bits correctly
            str enqueue_val_r, [disp_base_r, enqueue_tail_r, SXTW 2]            //Stores the value parameter in the queue array at tail index

enqueue_end:
            ldp x29, x30, [sp], 16                                              //Deallocate memory
            ret                                                                 //Return to main function

//dequeue function
dequeue:
            stp x29, x30, [sp, -16]!                                            //Allocate memory
            mov x29, sp                                                         //Update x29

            bl queueEmpty                                                       //Calls queueEmpty
            cmp w0, TRUE                                                        //Checks if it returned true
            b.ne dequeue_next1                                                  //If it didn't continue the function at dequeue_next1
            adrp x0, deq_str                                                    //Else, place the string in x0
            add x0, x0, :lo12:deq_str                                           //Formats it's low order 12 bits correctly
            bl printf                                                           //Calls printf; output error message
            mov w0, -1                                                          //Sets return value to -1
            b dequeue_end                                                       //Branch to end of function at dequeue_end

dequeue_next1:
            adrp disp_base_r, head                                              //Puts head address in base array
            add disp_base_r, disp_base_r, :lo12:head                            //Formats low order 12 bits correctly

            ldr dequeue_head_r, [disp_base_r]                                   //Sets dequeue_head_r tothe value of head

            adrp disp_base_r, tail                                              //Puts tail address in base array
            add disp_base_r, disp_base_r, :lo12:tail                            //Formats low order 12 bits correctly
            ldr dequeue_tail_r, [disp_base_r]                                   //Get tail
            adrp disp_base_r, queue                                             //Puts queue address in base array
            add disp_base_r, disp_base_r, :lo12:queue                           //Formats low order 12 bits correctly
            ldr dequeue_val_r, [disp_base_r, dequeue_head_r, SXTW 2]            //Update dequeue's local variable value

            cmp dequeue_head_r, dequeue_tail_r                                  //Compare head and tail
            b.ne dequeue_next2                                                  //If they aren't equal, continue at dequeue_next2

            mov w28, -1                                                         //Else, set a temporary register to -1
            adrp disp_base_r, head                                              //Puts head address in base array
            add disp_base_r, disp_base_r, :lo12:head                            //Formats low order 12 bits correctly
            str w28, [disp_base_r]                                              //Sets head to -1
            adrp disp_base_r, tail                                              //Puts tail address in base array
            add disp_base_r, disp_base_r, :lo12:tail                            //Formats low order 12 bits correctly
            str w28, [disp_base_r]                                              //Sets tail to -1

            b dequeue_next3                                                     //Continue at dequeue_next3

dequeue_next2:
            add dequeue_head_r, dequeue_head_r, 1                               //++head (at this point in code, dequeue_head_r is up to date)
            and dequeue_head_r, dequeue_head_r, MODMASK                         //And head with the modmask
            adrp disp_base_r, head                                              //Puts head address in base array
            add disp_base_r, disp_base_r, :lo12:head                            //Formats low order 12 bits correctly
            str dequeue_head_r, [disp_base_r]                                   //Update head

dequeue_next3:
            mov w0, dequeue_val_r                                               //Sets the return value to dequeue_val_r
dequeue_end:
            ldp x29, x30, [sp], 16                                              //Deallocate memory
            ret                                                                 //Return

//queueFull function
queueFull:
            stp x29, x30, [sp, -16]!                                            //Allocate memory
            mov x29, sp                                                         //Update x29

            adrp disp_base_r, tail                                              //Puts tail address in base array
            add disp_base_r, disp_base_r, :lo12:tail                            //Formats low order 12 bits correctly
            ldr Qfull_tail_r, [disp_base_r]                                     //Sets qful_tail equal to tail
            add Qfull_tail_r, Qfull_tail_r, 1                                   //Increment it
            and Qfull_tail_r, Qfull_tail_r, MODMASK                             //And it with the modmask

            adrp disp_base_r, head                                              //Puts head address in base array
            add disp_base_r, disp_base_r, :lo12:head                            //Formats low order 12 bits correctly
            ldr Qfull_head_r, [disp_base_r]                                     //Stores it's value in qfull_head

            mov w0, TRUE                                                        //Sets w0 to TRUE
            cmp Qfull_tail_r, Qfull_head_r                                      //Checks if head and tail are equal
            b.eq queueFull_end                                                  //If they are, then w0 holds the correct value; branch to end of function
            mov w0, FALSE                                                       //If they aren't, then set w0 to the true value

queueFull_end:
            ldp x29, x30, [sp], 16                                              //Deallocate memory
            ret                                                                 //Return
//queueEmpty function
queueEmpty:
            stp x29, x30, [sp, -16]!                                            //Allocate memory
            mov x29, sp                                                         //Sets x29 to sp

            adrp disp_base_r, head                                              //Puts head address in base array
            add disp_base_r, disp_base_r, :lo12:head                            //Formats low order 12 bits correctly
            mov w0, TRUE                                                        //Sets w0 to true
            ldr Qempty_head_r, [disp_base_r]                                    //Get value of head
            cmp Qempty_head_r, -1                                               //See if head = -1
            b.eq queueEmpty_end                                                 //If it does, w0 has correct value, so branch to queueEmpty_end
            mov w0, FALSE                                                       //If it doesn't, update w0 appropriately

queueEmpty_end:
            ldp x29, x30, [sp], 16                                              //Deallocate memory
            ret                                                                 //Return

//display function
display:
            stp x29, x30, [sp, -16]!                                            //Allocate memory
            mov x29, sp                                                         //Return

            bl queueEmpty                                                       //Calls queueEmpty function
            cmp w0, TRUE                                                        //See if it returned TRUE
            b.ne display_next1                                                  //If it didn't continue with the function

            adrp x0, disp_str                                                   //Else, it did, so prepare error message
            add x0, x0, :lo12:disp_str                                          //Formats low order 12 bits
            bl printf                                                           //Calls printf
            b display_end                                                       //Branch to end of program

display_next1:
            adrp disp_base_r, head                                              //Puts head address in base array
            add disp_base_r, disp_base_r, :lo12:head                            //Formats low order 12 bits correctly

            ldr disp_head_r, [disp_base_r]                                      //Load head
            adrp disp_base_r, tail                                              //Puts tail address in base array
            add disp_base_r, disp_base_r, :lo12:tail                            //Formats low order 12 bits correctly
            ldr disp_tail_r, [disp_base_r]                                      //Load tail

            sub disp_count_r, disp_tail_r, disp_head_r                          //count = tail - head
            add disp_count_r, disp_count_r, 1                                   //cound = count + 1 = tail - head + 1

            cmp disp_count_r, 0                                                 //Compare count to 0
            b.gt display_next2                                                  //If it is greater than 0, skip the next instruction
            add disp_count_r, disp_count_r, QUEUESIZE                           //If it's less than or equal to, then add the size of the queue to count

display_next2:
            adrp x0, disp_curr                                                  //Prepare the current queue contents string
            add x0, x0, :lo12:disp_curr                                         //Formats bits correctly
            bl printf                                                           //Calls printf

            mov disp_i_r, disp_head_r                                           //i = head
            mov disp_j_r, 0                                                     //for loop initialize j to 0
            b loop_test                                                         //Branch to for loop test

loop:
            adrp x0, disp_for                                                   //Prepare the "element of" string"
            add x0, x0, :lo12:disp_for                                          //Formats its low order 12 bits correctly
            adrp disp_base_r, queue                                             //Puts queue address in base array
            add disp_base_r, disp_base_r, :lo12:queue                           //Formats low order 12 bits correctly
            ldr w1, [disp_base_r, disp_i_r, SXTW 2]                             //Sets w1 to the value of index i (w1 = queue[1])
            bl printf                                                           //Calls printf

            cmp disp_i_r, disp_head_r                                           //See if head == i
            b.ne loop_next                                                      //If not skip next instructions
            adrp x0, disp_head                                                  //If so, then prepare the "head of queue" string
            add x0, x0, :lo12:disp_head                                         //Formats bits
            bl printf                                                           //Print the string

loop_next:
            cmp disp_i_r, disp_tail_r                                           //Compare i to tail
            b.ne loop_end                                                       //If not skip next instructions
            adrp x0, disp_tail                                                  //If so, prepair "tail of queue" string
            add x0, x0, :lo12:disp_tail                                         //Formats low order 12 bits correctly
            bl printf                                                           //Calls printf

loop_end:
            adrp x0, disp_newline                                               //End of loop. First, set up newline string
            add x0, x0, :lo12:disp_newline                                      //Formats low order 12 bits correctly
            bl printf                                                           //Calls printf to print the newline
            add disp_i_r, disp_i_r, 1                                           //Increment i
            and disp_i_r, disp_i_r, MODMASK                                     //And it with modmask

            add disp_j_r, disp_j_r, 1                                           //Increment j for for loop

loop_test:
            cmp disp_j_r, disp_count_r                                          //See if j < count
            b.lt loop                                                           //Rerun the loop if so

display_end:
            ldp x29, x30, [sp], 16                                              //Deallocate memory
            ret                                                                 //Return
