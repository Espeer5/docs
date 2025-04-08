/* 
 * hello3.c
 *     This file defines a simple program used to print a personalized greeting
 *     to the terminal a randomly generated number (1 - 10) of times. If the
 *     random number generated is even, "<n>: hello, <name>!" is printed, and if
 *     odd, "<n>: hi there, <name>!" is printed, where <name> is the user name
 *     read in from the terminal using the `scanf` function. The user name is
 *     required to be a single word of less than 100 characters. The program
 *     takes in no arguments. If the name is longer than 100 characters, it will
 *     be truncated to 99 characters when the greeting message is printed.
 * 
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
#include <time.h>

/*
 * CONSTANTS
*/

/* Define the proper number of arguments for program invocation. */
#define NUM_ARGS 0

/* Define the maximum number of characters allowed in the user name. */
#define NAME_BUFFER_LENGTH 100

/* Define the minimum and maximum number of times to print the greeting. */
#define MIN_PRINTS 1
#define MAX_PRINTS 10

/*
 * MAIN EXECUTABLE
*/

/*
 * main(argc, argv)
 *     This is the main executable for the hello3 program. It generates a random
 *     number, takes in the user's name, and prints the proper greeting message
 *     based on the values of each.
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
    /* Declare a buffer to hold the user name. */
    char name[NAME_BUFFER_LENGTH];

    /* Declare a loop index. */
    int i;

    /* Declare a variable to hold the number of prints. */
    int num_prints;

    /* Declare a variable to hold the greeting message. */
    char *greeting_msg;

    /* Ensure no arguments were passed by the user. */
    if (argc != NUM_ARGS + 1)
    {
        fprintf(stderr, "Usage: %s\n", argv[0]);
        exit(1);
    }

    /* Seed the random number generator. */
    srand(time(0));

    /* Generate a random number between MIN and MAX prints. */
    num_prints = (rand() % (MAX_PRINTS - MIN_PRINTS + 1)) + MIN_PRINTS;

    /* Prompt the user to input their name. */
    printf("Enter your name: ");

    /* Read up to 99 characters of user input from the command line. */
    if (scanf("%99s", name) != 1)
    {
        fprintf(stderr, "Error reading name.\n");
        exit(1);
    }

    /* 
     * Determine the greeting message based on the random number generated.
    */
    if (num_prints % 2 == 0)
    {
        greeting_msg = "%d: hello, %s!\n";
    } else
    {
        greeting_msg = "%d: hi there, %s!\n";
    }

    /* Print the greeting message the designated number of times. */
    for (i = 0; i < num_prints; i++)
    {
        printf(greeting_msg, num_prints, name);
    }

    return 0;
}
