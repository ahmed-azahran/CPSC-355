/*
CPSC 355, Fall 2018
Ahmed Zahran - 30040767
*/

//Macros

//Defining registers for the command line arguments
define(argc_r, w19)                                                                     //Number of arguments register
define(argv_r, x20)                                                                     //The arguments array register

//Defining registers for user iput and indices
define(season_r, w23)                                                                   //Index of the element in season array
define(month_r, w21)                                                                    //User input for month
define(day_r, w22)                                                                      //User input for day
define(suffix_r, w24)                                                                   //Index of the element in the suffix array

//Defining registers for starting addresses for arrays
define(season_base_r, x26)                                                              //Starting address for season array
define(month_base_r, x25)                                                               //Starting address for month array
define(suffix_base_r, x27)                                                              //Starting address for suffix array

//Declaring strings for all the seasons
spr_m:    .string "Spring"                                                              //Spring
sum_m:    .string "Summer"                                                              //Summer
fal_m:    .string "Fall"                                                                //Fall
win_m:    .string "Winter"                                                              //Winter

//Declaring strings for all the months
month1:     .string "January"                                                           //January
month2:     .string "February"                                                          //February
month3:     .string "March"                                                             //March
month4:     .string "April"                                                             //April
month5:     .string "May"                                                               //May
month6:     .string "June"                                                              //June
month7:     .string "July"                                                              //July
month8:     .string "August"                                                            //August
month9:     .string "September"                                                         //September
month10:    .string "October"                                                           //October
month11:    .string "November"                                                          //November
month12:    .string "December"                                                          //December


//Declaring strings for the suffixes
suff_th:    .string "th"                                                                 //th suffix
suff_st:    .string "st"                                                                 //st suffix
suff_nd:    .string "nd"                                                                 //nd suffix
suff_rd:    .string "rd"                                                                 //rd suffix

//Declaring printout strings for he answer and the error messages
usage:    .string "usage: a5b mm dd\n"                                                  //Error message for improper number of arguments
error1:   .string "Error: Invalid input\n"                                              //Invalid input error
error2:   .string "Error: This month doesn't have this number of days\n"                //Invalid day error (eg. November 31st)
answer:   .string "%s %d%s is %s\n"                                                     //Result output message

//Array creation
          .data                                                                         //Putss contents in the data section
          .balign 8                                                                     //Double-word allignment for the arrays

month_m:  .dword month1, month2, month3, month4, month5, month6, month7, month8, month9, month10, month11, month12  //Creates months array
season_m: .dword win_m, spr_m, sum_m, fal_m                                                                         //Creates seasons array
suffix_m: .dword suff_th, suff_st, suff_nd, suff_rd                                                                 //Creates suffix array



          .text                                                                         //Returns to text input
          .balign 4                                                                     //4-bit allignment
          .global main                                                                  //Makes main method visible to compiler

main:
          stp x29, x30, [sp, -16]!                                                      //Basic program structure to save state
          mov x29, sp                                                                   //Update x29 to sp

          mov argc_r, w0                                                                //Saving argc in a safe place since w0 will be modified by a function
          mov argv_r, x1                                                                //Saving argv in a safe place

          cmp argc_r, 3                                                                 //Makes sure that the number of arguments inputed is 3
          b.eq next1                                                                    //If it is equal to 3, branches to next1
          adrp x0, usage                                                                //If not, prints out an error message
          add x0, x0, :lo12:usage                                                       //Formats lower-order 12 bits correctly
          bl printf                                                                     //Branches and link with the printf function to print the error message
          b end                                                                         //Branchess to end of program (Terminates)

next1:
          mov suffix_r, 1                                                               //Sets suffix_r to 1
          ldr x0, [argv_r, suffix_r, SXTW 3]                                            //Loads the second element of argv (month) into x0
          bl atoi                                                                       //Calls atoi using branch and link
          mov month_r, w0                                                               //Puts atoi's returned value into month_r
          mov suffix_r, 2                                                               //Sets suffix_r to 2
          ldr x0, [argv_r, suffix_r, SXTW 3]                                            //Loads the third element of argv (day) into x0
          bl atoi                                                                       //Calls atoi
          mov day_r, w0                                                                 //Puts atoi's returned value into the day_r

          cmp month_r, 0                                                                //Compares month_r with 0
          b.le error                                                                    //If it is less than or equal to 0, Branches to error message
          cmp month_r, 12                                                               //Compares month_r with 12
          b.gt error                                                                    //If it is graeater than 12, Branches to error message
          cmp day_r, 31                                                                 //Compares day_r with 31
          b.gt error                                                                    //If it is greater than 31, Branches to error message
          cmp day_r, 0                                                                  //Compares day with 0
          b.le error                                                                    //If it is less than or equal to 0, Branches to error message
          b next2                                                                       //Otherwise, Branches to next2

error:
          adrp x0, error1                                                               //Sets up error message
          add x0, x0, :lo12:error1                                                      //Format its low-order 12 bits correctly
          bl printf                                                                     //Print error message
          b end                                                                         //Branches to end of program

next2:
          cmp month_r, 2                                                                //Checks if the value of month is 2(February)
          b.ne next3                                                                    //If the month is not February, branch to next3
          cmp day_r, 28                                                                 //Otherwise, if the month is February, check the number of days(less than 28)
          b.gt day_error                                                                //If it is, Branches to the error message

next3:
          cmp month_r, 4                                                                //Checks if month is 4 (April)
          b.eq check                                                                    //If it is, run the check
          cmp month_r, 6                                                                //Checks if month is June
          b.eq check                                                                    //If it is, run the check
          cmp month_r, 9                                                                //Checks if month is September
          b.eq check                                                                    //If it is, run the check
          cmp month_r, 11                                                               //Checks if month is November
          b.eq check                                                                    //If it is, run the check
          b next4                                                                       //Otherwise, the motnh is a 31 day month and day is valid. Brach to next4

check:
          cmp day_r, 31                                                                 //Checks if day is equal to 31
          b.ne next4                                                                    //If it is not, then branch to next4. If it is, branch to day_error

day_error:
          adrp x0, error2                                                              //Sets up invalid date message
          add x0, x0, :lo12:error2                                                     //Formats low-order 12-bits correctly
          bl printf                                                                    //Prints message
          b end                                                                        //Branches to end of program

next4:
          cmp month_r, 2                                                               //Checks if month is greater than 2
          b.gt april_may                                                               //If it is, Branches to the april_may.
          mov season_r, 0                                                              //If it's not,so set season_r to 0 (winter)
          b next5                                                                      //Branches to next5

april_may:
          cmp month_r, 4                                                               //Checks if month is less than 4 (April)
          b.lt march                                                                   //If it is, branch to march
          cmp month_r, 5                                                               //Checks if month is greater than 5 (May)
          b.gt july_august                                                             //If it is, branch to july_august
          mov season_r, 1                                                              //Otherwise,set season_r to 1 (Spring)
          b next5                                                                      //Branches to next5

july_august:
          cmp month_r, 7                                                               //Checks if month is less than 7 (July)
          b.lt june                                                                    //If it is, Branches to june
          cmp month_r, 8                                                               //Checks if month is greater than 8 (August)
          b.gt oct_nov                                                                 //If it is, Branches to oct_nov
          mov season_r, 2                                                              //Otherwise,sets season_r to 2 (summer)
          b next5                                                                      //Branches to next5

oct_nov:
          cmp month_r, 10                                                              //Checks if month is less than 10 (October)
          b.lt september                                                               //If it is, Branches to september
          cmp month_r, 11                                                              //Checks if month is greater than 11 (November)
          b.gt december                                                                //If it is, Branches to december
          mov season_r, 3                                                              //Otherwise, set the season_r to 3 (Fall)
          b next5                                                                      //Branches to next5

march:
          mov season_r, 0                                                              //Sets season index to 0 for Winter
          cmp day_r, 20                                                                //If the day_r is les than or equal to 20
          b.le next5                                                                   //Branches to next5
          mov season_r, 1                                                              //If not,Sets the season_r to 1 (Spring)
          b next5                                                                      //Branches to next5

june:
          mov season_r, 1                                                              //Sets season index to 1 for Spring
          cmp day_r, 20                                                                //If day_r is less than or equal to 20
          b.le next5                                                                   //Branches to next5
          mov season_r, 2                                                              //If not,Sets the season_r to 2 (Summer)
          b next5                                                                      //Branch to next5

september:
          mov season_r, 2                                                              //Sets season index to 2 for Summer
          cmp day_r, 20                                                                //If day_r is less than or equal to 20
          b.le next5                                                                   //Branches to next5
          mov season_r, 3                                                              //If not,Sets season index to 3 (Fall)
          b next5                                                                      //Branch to next5

december:
          mov season_r, 3                                                              //Sets season index to 3 for Fall.
          cmp day_r, 20                                                                //Checks if day_r is less than or equal to 20
          b.le next5                                                                   //Branches to next5
          mov season_r, 0                                                              //If not,sets season index to 0 (Winter)

next5:
          cmp day_r, 1                                                                 //Checks if the day is 1
          b.eq suff1                                                                   //If yes, branch to suff1 (st)
          cmp day_r, 21                                                                //Checks if the day is 21.
          b.eq suff1                                                                   //If it is, branch to suff1 (st)
          cmp day_r, 31                                                                //Checks if the day is 31,
          b.eq suff1                                                                   //Branch to suff1 (st)

          cmp day_r, 2                                                                 //Checks if the day is 2
          b.eq suff2                                                                   //Branch to suff2 (nd)
          cmp day_r, 22                                                                //Checks if the day is 22
          b.eq suff2                                                                   //Branch to suff2 (nd)

          cmp day_r, 3                                                                 //Checks if the day is 3
          b.eq suff3                                                                   //If yes, branch to suff3 (rd)
          cmp day_r, 23                                                                //Checks if the day is 23
          b.eq suff3                                                                   //Branch to suff3

          mov suffix_r, 0                                                              //Else,sets suffix index to 0 (th)
          b output                                                                     //Branches to output.
suff1:
          mov suffix_r, 1                                                              //If day is 1, 21 or 31 sets suffix_r to 1 (st)
          b output                                                                     //Branches to output.
suff2:
          mov suffix_r, 2                                                              //If day is 2 or 22, sets suffix_r to 2 (nd)
          b output                                                                     //Branches to output.
suff3:
          mov suffix_r, 3                                                              //If day index is 3 or 23, set suffix_r to 3 (rd)

output:
          adrp month_base_r, month_m                                                   //Loads month_m into month_base_r
          add month_base_r, month_base_r, :lo12:month_m                                //Format low-order 12 bits correctly

          adrp season_base_r, season_m                                                 //Loads season_m into season_base_r
          add season_base_r, season_base_r, :lo12:season_m                             //Format low-order 12 bits correctly.

          adrp suffix_base_r, suffix_m                                                 //Loads suffix_m into suffix_m
          add suffix_base_r, suffix_base_r, :lo12:suffix_m                             //Format low-order 12 bits correctly.

          sub month_r,month_r,1                                                        //Takes care of the zero-based indexing or arrays
          adrp x0, answer                                                              //Sets up result string
          add x0, x0, :lo12:answer                                                     //Format low-order 12 bits correctly
          ldr x1, [month_base_r, month_r, SXTW 3]                                      //Loads the appropriate month to x1
          mov w2, day_r                                                                //Puts the day value into w2
          ldr x3, [suffix_base_r, suffix_r, SXTW 3]                                    //Loads the appropriate suffix
          ldr x4, [season_base_r, season_r, SXTW 3]                                    //Loads the appropriate season 
          bl printf                                                                    //Calls printf

//End program
end:
          mov w0, 0                                                                    //Sets return value to 0
          ldp x29, x30, [sp], 16                                                       //Deallocates memory
          ret                                                                          //Return to the OS
