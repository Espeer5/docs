################################################################################
# test_p2.py                                                                   #
#                                                                              #
# This file tests my LFSR solution for problem 2 of HW3 in EECS119a.           #
#                                                                              #
# Author: Edward Speer                                                         #
# Revision History:                                                            #
# 10/19/2024 - Initial Revision                                                #
################################################################################

################################################################################
# IMPORTS                                                                      #
################################################################################

from typing import List, Callable

################################################################################
# CLASS: DFF                                                                   #
################################################################################

"""
DFF()

This class represents a simple D flip-flop. This is essentially a single bit of
memory that can be set oe reset via a D input. On each clock, the value on the
D inpus is stored into the flip-flop.
"""
class DFF:

    def __init__(self):
        self.q     = False
        self.q_bar = True
        self.d     = False

    def set_d(self, d: bool) -> None:
        self.d = d
    
    def clock(self) -> None:
        self.q = self.d
        self.q_bar = not self.q

    def __str__(self) -> str:
        return "1" if self.q else "0"

################################################################################
# CLASS: LFSR                                                                  #
################################################################################

"""
LFSR(n: int, f_feedback: Callable[[List[DFF]], bool])

This class represents an n bit LFSR with the given custom feedback logic
function. An LFSR is n D flip-flops connected in series, with the output
connected to the input of the first flip-flop through a custom set of
combinatorial logic. On each clock, the bits in the register are shifted to 
the right, and the output of the custom logic is shifted into the leftmost bit.
"""
class LFSR:

    def __init__(self, n: int, f_feedback: Callable[[List[DFF]], bool]):
        self.f_feedback = f_feedback
        self.dffs = [DFF() for _ in range(n)]
        # Set the flip-flop to a known state to start
        self.dffs[0].set_d(True)
        self.dffs[0].clock()

    def clock(self) -> None:
        feedback = self.f_feedback(self.dffs)
        self.dffs[0].set_d(feedback)
        for i in range(1, len(self.dffs)):
            self.dffs[i].set_d(self.dffs[i-1].q)
        for dff in self.dffs:
            dff.clock()
    
    def __str__(self) -> str:
        return "".join([str(dff) for dff in self.dffs])

################################################################################
# CUSTOM FEEDBACK FUNCTION                                                     #
################################################################################

"""
f_feedback(dffs: List[DFF]) -> bool

This function implements the custom feedback logic for my propsed LFSR solution
to problem 2 of HW3 in EECS119a.
"""
def f_feedback(dffs: List[DFF]) -> bool:
    term1 = True not in [dff.q for dff in dffs[0:8]]
    term2 = dffs[4].q ^ dffs[8].q
    return term1 ^ term2

################################################################################
# MAIN                                                                         #
################################################################################

"""
main()

The main function of this file sets up my proposed LFSR and tests that it
outputs every possible 9 bit sequence including 0 exactly 1 time.
"""
def main():
    lfsr = LFSR(9, f_feedback)
    outputs = []
    while str(lfsr) not in outputs:
        outputs.append(str(lfsr))
        lfsr.clock()
        print(lfsr)
    assert(len(outputs) == 512)
    assert("000000000" in outputs)
    print("tests passed")


if __name__ == "__main__":
    main()
