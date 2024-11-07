################################################################################                                                                       #
# This file uses the Quine-McCluskey algorithm implemented in the Q-M module   #
# to solve for the prime implicants chart for each segment in the comparator   #
# for probelm 13 and 14 of HW5 in EECS119a.                                    #
#                                                                              #
# Author: Edward Speer                                                         #
# Revision History:                                                            #
# 11/5/2024 - Initial Revision                                                 #
################################################################################

################################################################################
# CONSTANTS                                                                    #
################################################################################

# Path to Quine-McCluskey algorithm implementation
QM_PATH = "../Q-M"

# This dictionary will hold the active and inactive inputs for the comparator
INPUTS = {
    "comparator": {
        "active":   [],
        "inactive": []},
}

################################################################################
# IMPORTS                                                                      #
################################################################################

import sys

# Add the path to the Quine-McCluskey algorithm to the system path
sys.path.append(QM_PATH)
import qm

################################################################################
# MAIN                                                                         #
################################################################################

"""
main()

The main function for this script runs the Quine-McCluskey on each of the
defined input tables in the INPUTS dict. The resulting prime implicants chart is
printed on stdout.
"""
def main():
    # Generate all 8 bit input values possible
    for i in range(256):  # 2^8 = 256 possible 8-bit combinations
        # Convert the number to an 8-bit binary string
        binary_string = f"{i:08b}"
        
        # Split the string into high nibble and low nibble
        high_nibble = int(binary_string[:4], 2)
        low_nibble = int(binary_string[4:], 2)
        
        # Check if high nibble is less than low nibble
        if high_nibble < low_nibble:
            INPUTS["comparator"]["active"].append(binary_string)
        else:
            INPUTS["comparator"]["inactive"].append(binary_string)

    for segment in INPUTS:
        print(f"Signal: {segment}")
        active = INPUTS[segment]["active"]
        inactive = INPUTS[segment]["inactive"]
        lp = qm.LogicProblem(active, inactive)
        lp.run_qm()
        lp.get_table()

if __name__ == "__main__":
    main()
