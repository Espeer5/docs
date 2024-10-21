################################################################################
# p1.py                                                                        #
#                                                                              #
# This file uses the Quine-McCluskey algorithm implemented in the Q-M module   #
# to solve for the prim implicants chart for each segment in the 7 segmnent    #
# display for problem 1 of HW3 in EECS119a.                                    #
#                                                                              #
# Author: Edward Speer                                                         #
# Revision History:                                                            #
# 10/19/2024 - Initial Revision                                                #
################################################################################

################################################################################
# CONSTANTS                                                                    #
################################################################################

# Path to Quine-McCluskey algorithm implementation
QM_PATH = "../Q-M"

# Input values for each logic problem for the 7 segment display counter
INPUTS = {
    "a": {
        "active":   ["0110000", "1101101", "0110011", "0011111", "1110000",
                     "1111111", "1110011"],
        "inactive": ["1111110", "1111001", "1011011"]},
    "b": {
        "active":   ["1111110", "0110000", "1101101", "1111001", "0011111", 
                     "1110000", "1111111", "1110011"],
        "inactive": ["0110011", "1011011"]},
    "c": {
        "active":   ["1111110", "1101101", "1111001", "0110011", "1011011",
                     "0011111", "1110000", "1111111", "1110011"],
        "inactive": ["0110000"]},
    "d": {
        "active":   ["0110000", "1101101", "0110011", "1011011", "1110000",
                     "1110011"],
        "inactive": ["1111110", "1111001", "0011111", "1111111"]},
    "e": {
        "active":   ["0110000", "1011011", "1110000", "1110011"],
        "inactive": ["1111110", "1101101", "1111001", "0110011", "0011111",
                     "1111111"]},
    "f": {
        "active":   ["1111001", "0110011", "1011011", "1110000", "1111111",
                     "1110011"],
        "inactive": ["1111110", "0110000", "1101101", "0011111"]},
    "g": {
        "active":   ["0110000", "1101101", "1111001", "0110011", "1011011",
                     "1110000", "1111111"],
        "inactive": ["1111110", "0011111", "1110011"]}
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
defined input tables in the INPUTS dict. The resulting prime implicant charts
printed on stdout.
"""
def main():
    for segment in INPUTS:
        print(f"Signal: {segment}")
        active = INPUTS[segment]["active"]
        inactive = INPUTS[segment]["inactive"]
        lp = qm.LogicProblem(active, inactive)
        lp.run_qm()
        lp.get_table()

if __name__ == "__main__":
    main()
