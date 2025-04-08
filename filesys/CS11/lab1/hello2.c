/* 
 * hello2.c
 *     This file defines a simple program used to print a personalized greeting,
 *     "hello, <name>!", to the terminal using the `printf` function. The
 *     program takes in the user name as input from the terminal using the
 *     `scanf` function. The user name is required to be a single word of less
 *     than 100 characters. The program takes in no arguments. If the name is
 *     longer than 100 characters, it will be truncated to 99 characters when
 *     the greeting message is printed.
 * 
 * Author:   Edward Speer
 * Date:     4/7/2025
 * Revision: 1.0
*/

/*
 * IMPORTS
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* 
 * CONSTANTS
*/

/* Define the maximum number of characters allowed in the user name. */
#define NAME_BUFFER_LENGTH 100

/* Define the proper number of arguments for program invocation. */
#define NUM_ARGS 0

/*
 * MAIN EXECUTABLE
*/

/*
 * main(argc, argv)
 *     This is the main executable for the hello2 program. It takes in the
 *     user's name from stdin and prints the proper greeting message to the
 *     terminal.
 * 
 * Parameters:
 *     argc - The argument count passed to the program. Should be 1.
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
    /* Declare a buffer to hold the user name. */
    char name[NAME_BUFFER_LENGTH];

    /* Ensure no arguments were passed by the user. */
    if (argc != NUM_ARGS + 1)
    {
        fprintf(stderr, "Usage: %s\n", argv[0]);
        exit(1);
    }

    /* Prompt the user to input their name. */
    printf("Enter your name: ");

    /* Read up to 99 characters of user input from the command line. */
    if (scanf("%99s", name) != 1)
    {
        fprintf(stderr, "Error reading name.\n");
        exit(1);
    }

    /* Print the personalized greeting to the terminal. */
    printf("hello, %s!\n", name);
    return 0;
}
