################################################################################
# Assignment 2, Problem 1                                                      #
# EECS 119, Fall 2024                                                          #
#                                                                              #
# This script uses the Quine-McCluskey algorithm to find simplified boolean    #
# expressions from the truth table for the Codebar decoder.                    #
#                                                                              #
# Author: Edward Speer                                                         #
# Revision History:                                                            #
# 10/9/2024  - Initial revision                                                #
# 10/14/2024 - Fill in remaining signals to solve                              #
################################################################################

################################################################################
# CONSTANTS                                                                    #
################################################################################

# Path to Quine-McCluskey algorithm implementation
QM_PATH = "../Q-M"

# Input values for each logic problem for the decoder
INPUTS = {
    "S":  {"mutex":    False,
           "active":   ["0011010", "0101001", "0001011", "0001110"],
           "inactive": ["0000011", "0000110", "0001001", "1100000", "0010010",
                        "1000010", "0100001", "0100100", "0110000", "1001000",
                        "0001100", "0011000", "1000101", "1010001", "1010100",
                        "0010101"]},
    "V3": {"mutex":    False,
           "active":   ["0001001", "0010010", "0110000", "0001100", "0011000",
                        "1000101", "1010001", "1010100", "0010101"],
           "inactive": ["0000011", "0000110", "1100000", "1000010", "0100001",
                        "0100100", "1001000"]},
    "V2": {"mutex":    False,
           "active":   ["1100000", "1000010", "1001000", "0001100", "0011000",
                        "1000101", "1010001", "1010100", "0010101"],
           "inactive": ["0000011", "0000110", "0001001", "0010010", "0100001",
                        "0100100", "0110000"]},
    "V1": {"mutex":    False,
           "active":   ["1100000", "0100001", "0100100", "0110000"],
           "inactive": ["0000011", "0000110", "0001001", "0010010", "1000010",
                        "1001000"]},
    "V0": {"mutex":    False,
           "active":   ["0000011", "0001001", "0100001", "1001000"],
           "inactive": ["0000110", "1100000", "0010010", "1000010", "0100100",
                        "0110000"]},
    "G":  {"mutex":    True,
           "active":   ["0000011", "0000110", "0001001", "1100000", "0010010",
                        "1000010", "0100001", "0100100", "0110000", "1001000",
                        "0001100", "0011000", "1000101", "1010001", "1010100",
                        "0010101", "0011010", "0101001", "0001011", "0001110"]}
}

################################################################################
# IMPORTS                                                                      #
################################################################################

import sys

# Add path to import Quine-McCluskey algorithm implementation
sys.path.append(QM_PATH)
import qm


"""
main()

Main function for the script. This function runs the Quine-McCluskey algorithm
on the input values for the logic problem and prints the most simplified prime
implicants for the truth table.
"""
def main():

    for input_name in INPUTS:
        print("-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-")
        print(f"Problem: {input_name}")
        print("Active Inputs:")
        active = INPUTS[input_name]["active"]
        print(active)
        mutex = INPUTS[input_name]["mutex"]
        if not mutex:
            print("Inactive Inputs:")
            inactive = INPUTS[input_name]["inactive"]
            print(inactive)
        else:
            inactive = []

        lp = qm.LogicProblem(active, inactive, mutex=mutex)
        lp.run_qm()

        print("-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-\n\n")


if __name__ == "__main__":
    main()
