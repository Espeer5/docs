################################################################################
# This module is used for checking the correctness of my logic design for      #
# problem 1. It contains logic to run gate functions and check that the        #
# outputs are correct.                                                         #
#                                                                              #
# Author: Edward Speer                                                         #
# Revision History:                                                            #
# 10/14/2024  - Initial revision                                               #
################################################################################

################################################################################
# CONSTANTS                                                                    #
################################################################################

# Translate indices in the binary input to the index of the corresponding signal
# in an input string
IND = {0: 6, 1: 5, 2: 4, 3: 3, 4: 2, 5: 1, 6: 0}

# Inputs resulting in an active G output
G_ACTIVE   = ["0000011", "0000110", "0001001", "1100000", "0010010", "1000010",
              "0100001", "0100100", "0110000", "1001000", "0001100", "0011000",
              "1000101", "1010001", "1010100", "0010101", "0011010", "0101001",
              "0001011", "0001110"]

# Inputs resulting in an inactive G output
G_INACTIVE = [format(i, '07b') for i in range(128) if format(i, '07b') not in
              G_ACTIVE]

INPUTS = {
    "S":  {"active":   ["0011010", "0101001", "0001011", "0001110"],
           "inactive": ["0000011", "0000110", "0001001", "1100000", "0010010",
                        "1000010", "0100001", "0100100", "0110000", "1001000",
                        "0001100", "0011000", "1000101", "1010001", "1010100",
                        "0010101"]},
    "V3": {"active":   ["0001001", "0010010", "0110000", "0001100", "0011000",
                        "1000101", "1010001", "1010100", "0010101"],
           "inactive": ["0000011", "0000110", "1100000", "1000010", "0100001",
                        "0100100", "1001000"]},
    "V2": {"active":   ["1100000", "1000010", "1001000", "0001100", "0011000",
                        "1000101", "1010001", "1010100", "0010101"],
           "inactive": ["0000011", "0000110", "0001001", "0010010", "0100001",
                        "0100100", "0110000"]},
    "V1": {"active":   ["1100000", "0100001", "0100100", "0110000"],
           "inactive": ["0000011", "0000110", "0001001", "0010010", "1000010",
                        "1001000"]},
    "V0": {"active":   ["0000011", "0001001", "0100001", "1001000"],
           "inactive": ["0000110", "1100000", "0010010", "1000010", "0100100",
                        "0110000"]},
    "G":  {"active":   G_ACTIVE,
           "inactive": G_INACTIVE}
}

################################################################################
# LOGIC FUNCTIONS                                                              #
################################################################################

"""
INV(x: str) -> str:

Invert a bus of signals of any length.
"""
def INV(x: str) -> str:
    new_x = ""
    for i in range(len(x)):
        new_x += '1' if x[i] == '0' else '0'
    return new_x


"""
AND(x: str) -> str:

Perform a logical AND operation on a bus of signals of any length.
"""
def AND(x: str) -> str:
    return '1' if '0' not in x else '0'


"""
OR(x: str) -> str:

Perform a logical OR operation on a bus of signals of any length.
"""
def OR(x: str) -> str:
    return '0' if '1' not in x else '1'


"""
XOR(x: str) -> str:

Perform a logical XOR operation on a bus of signals of any length.
"""
def XOR(x: str) -> str:
    return '1' if x.count('1') % 2 == 1 else '0'


"""
NAND(x: str) -> str:

Perform a logical NAND operation on a bus of signals of any length.
"""
def NAND(x: str) -> str:
    return INV(AND(x))


"""
NOR(x: str) -> str:

Perform a logical NOR operation on a bus of signals of any length.
"""
def NOR(x: str) -> str:
    return INV(OR(x))


"""
XNOR(x: str) -> str:

Perform a logical XNOR operation on a bus of signals of any length.
"""
def XNOR(x: str) -> str:
    return INV(XOR(x))


################################################################################
# LOGIC DESIGN                                                                 #
################################################################################

"""
S(x: str) -> str:

Custom logic for output signal S.
"""
def S(x: str) -> str:
    return NOR(INV(x[IND[3]]) + NOR(x[IND[5]] + x[IND[1]]))


"""
V3(x: str) -> str:

Custom logic for output signal V3.
"""
def V3(x: str) -> str:
    return NAND(NAND(INV(x[IND[6]]) + x[IND[3]]) + INV(x[IND[4]]) +
                NAND(x[IND[6]] + x[IND[2]]))


"""
V2(x: str) -> str:

Custom logic for output signal V2.
"""
def V2(x: str) -> str:
    return NAND(NAND(x[IND[3]] + INV(x[IND[0]])) + INV(x[IND[6]]) +
                NAND(x[IND[2]] + x[IND[0]]))


"""
V1(x: str) -> str:

Custom logic for output signal V1.
"""
def V1(x: str) -> str:
    return x[IND[5]]


"""
V0(x: str) -> str:

Custom logic for output signal V0.
"""
def V0(x: str) -> str:
    return NAND(INV(x[IND[3]]) + INV(x[IND[0]]))


"""
G(x: str) -> str:

Custom logic for output signal G.
"""
def G(x: str) -> str:
    P1 = NOR(
        NOR(x[IND[3]] + x[IND[1]]) +
        XNOR(x[IND[2]] + x[IND[0]]) +
        x[IND[6]] + x[IND[5]] + x[IND[4]]
    )

    P2 = NOR(
            NOR(
                NOR(x[IND[2]] + INV(x[IND[1]]) + x[IND[0]]) +
                NOR(x[IND[3]] + x[IND[1]] + INV(x[IND[2]] + x[IND[0]])) +
                NOR(INV(x[IND[3]]) + x[IND[2]] + x[IND[0]])
            ) +
            x[IND[6]] + x[IND[5]] + INV(x[IND[4]])
    )

    P3 = NOR(
            NOR(
                NOR(x[IND[2]] + x[IND[1]] + INV(x[IND[0]])) +
                NOR(x[IND[3]] + INV(x[IND[2]]) + x[IND[1]] + x[IND[0]])
            ) +
            x[IND[6]] + INV(x[IND[5]]) + x[IND[4]]
    )

    P4 = NOR(x[IND[6]] + INV(x[IND[5]] + x[IND[4]]) + x[IND[3]] + x[IND[2]] + 
             x[IND[1]] + x[IND[0]])

    P5 = NOR(
            NOR(
                NOR(x[IND[3]] + x[IND[2]] + INV(x[IND[1]]) + x[IND[0]]) +
                NOR(INV(x[IND[3]]) + x[IND[2]] + x[IND[1]] + x[IND[0]]) + 
                NOR(x[IND[3]] + INV(x[IND[2]]) + x[IND[1]] + INV(x[IND[0]]))
            ) +
            INV(x[IND[6]]) + x[IND[5]] + x[IND[4]]
    )

    P6 = NOR(
            INV(x[IND[6]]) + x[IND[5]] + INV(x[IND[4]]) + x[IND[3]] + x[IND[1]]
            + XNOR(x[IND[2]] + x[IND[0]])
    )

    P7 = NOR(INV(x[IND[6]] + x[IND[5]]) + x[IND[4]] + x[IND[3]] + x[IND[2]] + 
             x[IND[1]] + x[IND[0]])

    return OR(P1 + P2 + P3 + P4 + P5 + P6 + P7)


################################################################################
# HELPER FUNCTIONS                                                             #
################################################################################

"""
check_signal(signal: function, active: List[str], inactive: List[str]) -> bool:

Check if a signal is correct for a given set of active and inactive inputs.
"""
def check_signal(signal, active, inactive) -> bool:
    for a in active:
        if signal(a) != '1':
            print(f"Signal {signal.__name__} failed for active input {a}")
    for i in inactive:
        if signal(i) != '0':
            print(f"Signal {signal.__name__} failed for inactive input {i}")

################################################################################
# MAIN                                                                         #
################################################################################

"""
main() -> None

The main method of this module checks the correctness of the logic design for 
every signal in the design for problem 1.
"""
def main() -> None:
    # All logic functions to check
    logic_functions = [S, V3, V2, V1, V0, G]
   
    # Check all signals
    for signal in logic_functions:
        check_signal(signal, INPUTS[signal.__name__]["active"],
                            INPUTS[signal.__name__]["inactive"])

    print("Finished checking logic design for problem 1")


if __name__ == "__main__":
    main()
