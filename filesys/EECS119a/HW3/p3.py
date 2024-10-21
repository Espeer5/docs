################################################################################
# p3.py                                                                        #
#                                                                              #
# This file uses the Quine-McCluskey algorithm implemented in the Q-M module   #
# to solve for the prime implicants chart of the 7 bit 8-89 counter for        #
# problem 3 of HW3 in EECS119a.                                                #
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

################################################################################
# IMPORTS                                                                      #
################################################################################

import sys
from typing import List, Dict

# Add the path to the Quine-McCluskey algorithm to the system path
sys.path.append(QM_PATH)
import qm

################################################################################
# HELPER FUNCTIONS                                                             #
################################################################################

"""
pad_bin(bin_str: str, n: int) -> str

Pad the passed binary string out to the passed length with leading zeros. If the
input is longer than the passed length, throws an error. If the input is already
the correct length, returns the input.
"""
def pad_bin(bin_str: str, n: int) -> str:
    if len(bin_str) > n:
        raise ValueError("Input is longer than desired length.")
    return "0" * (n - len(bin_str)) + bin_str

"""
gen_inputs() -> Dict[str, Dict[str, List[str]]]

This function generates the active and inactive inputs for each of the 7 bits of
the 8-89 counter.
"""
def gen_inputs()-> Dict[str, Dict[str, List[str]]]:
    signals = {
        "I6" : 0,
        "I5" : 1,
        "I4" : 2,
        "I3" : 3,
        "I2" : 4,
        "I1" : 5,
        "I0" : 6
    }
    inputs = {}
    for sig in signals:
        inputs[sig] = {
            "active":   [],
            "inactive": []
        }
        for i in range(8, 90):
            prev_i = 89 if i == 8 else i - 1
            input_bin = pad_bin(bin(prev_i)[2:], 7)
            bin_str = pad_bin(bin(i)[2:], 7)
            if bin_str[signals[sig]] == "1":
                inputs[sig]["active"].append(input_bin)
            else:
                inputs[sig]["inactive"].append(input_bin)
    return inputs


################################################################################
# MAIN                                                                         #
################################################################################

"""
main() -> None

The main method of this script collects the active input sets for each of 
"""
def main() -> None:
    inputs = gen_inputs()
    for sig in inputs:
        print(f"Prime Implicants Chart for {sig}")
        active = inputs[sig]["active"]
        inactive = inputs[sig]["inactive"]
        lp = qm.LogicProblem(active, inactive)
        lp.run_qm()
        lp.get_table()

if __name__ == "__main__":
    main()
