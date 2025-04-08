/* 
 * hello1.c
 *     This file defines a simple program used to print "hello, world!" to the
 *     terminal using the `printf` function. The program takes no arguments.
 * 
 * Author:   Edward Speer
 * Date:     4/7/2025
 * Revision: 1.0
*/

/* IMPORTS */

#include <stdio.h>
#include <stdlib.h>

/* 
 * CONSTANTS
*/

/* Define the proper number of arguments for program invocation. */
#define NUM_ARGS 0

/* Define the message printed to the terminal on program execution. */
const char *hello_msg = "hello, world!\n";

/*
 * MAIN EXECUTABLE
*/

/*
 * main(argc, argv)
 *     This is the main executable for the hello1 program. It prints the hello
 *     world message to the terminal using printf.
 * 
 * Parameters:
 *     argc - The argument count passed to the program. Should be 1.asm
 *     argv - The argument vector passed to the program. Should be empty.
 *
 * Returns:
 *     0 - The program executed successfully.
 *     1 - The program failed to execute successfully.
 *
 * Notes:
 *     - The program will print an error message to the terminal if the user
 *       does not provide the proper number of arguments.
 *     - The program will print an error message to the terminal if `scanf`
 *       fails to read the user name from stdin.
*/
int main(int argc, char **argv)
{
    /* Ensure no arguments were passed by the user. */
    if (argc != NUM_ARGS + 1)
    {
        fprintf(stderr, "Usage: %s\n", argv[0]);
        exit(1);
    }

    /* Print the hello world message to the terminal. */
    printf("%s", hello_msg);
    return 0;
}
