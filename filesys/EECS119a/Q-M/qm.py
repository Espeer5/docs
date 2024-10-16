################################################################################
# qm.py                                                                        #
#                                                                              #
# This file contains a Quine-McCluskey algorithm implementation.               #
# Quine-McCluskey outputs a simplified boolean expression given a truth table. #
#                                                                              #
# Author: Edward Speer                                                         #
#                                                                              #
# Revision History:                                                            #
# 10/9/2024  - Initial revision                                                #
# 10/14/2024 - Debug repeated implicants in recursion                          #
# 10/15/2024 - Add nice printing of prime implicant chart                      #
################################################################################

################################################################################
# IMPORTS                                                                      #
################################################################################

from typing import List, Dict
from itertools import combinations, product
from re import findall

################################################################################
# HELPER FUNCTIONS                                                             #
################################################################################

"""
check_merge(minterm1: str, minterm2: str) -> bool

Check if two minterms can be merged. Minterms may be merged if they differ by a
single bit.
"""
def check_merge(minterm1: str, minterm2: str) -> bool:
    # Check that all dashes in minterms are in the same position
    if not [i for i, c in enumerate(minterm1) if c == '-'] == \
            [i for i, c in enumerate(minterm2) if c == '-']:
        return False

    # Obtain int representations of the minterms from binary strings
    minterm1_int, minterm2_int = list(map(lambda x:int(x.replace('-', 
                                            '0'), 2), [minterm1, minterm2]))

    # To merge, only one bit can be twiddled
    xor = minterm1_int ^ minterm2_int
    return xor != 0 and xor & (xor - 1) == 0

"""
merge(minterm1: str, minterm2: str) -> str

Merge two minterms. The minterms must be able to be merged. The function returns
a new minterm with a dash in the position of the single twiddled bit from the 
input minterms.
"""
def merge(minterm1: str, minterm2: str) -> str:
    return "".join(list(map(lambda x, y: x if x == y else '-', minterm1,
                            minterm2)))

################################################################################
# Logic Problem Class                                                          #
################################################################################

"""
LogicProblem

This class represents a logic problem. It contains a set of minterms for the 
problem, and holds methods for finding prime implicants and creating a prime
implicant chart. This will allow for the creation of a simplified boolean
expression.
"""
class LogicProblem():

    # CONSTRUCTORS

    """
    __init__(self, active: List[str], inactive: List[str], mutex: bool=False)

    Given a list of active and inactive minterms, create a new LogicProblem
    object. The active minterms are the minterms that are true in the truth
    table, and the inactive minterms are the minterms that are false in the
    truth table. The false minterms are used to collect the don't care terms
    for the problem. If mutex (mutally exclusive) is set to True, the inactive
    set will automatically be set to the complement of the active set.
    """
    def __init__(self, active: List[str], inactive: List[str],
                 mutex: bool=False):
        self.minterms = active
        self.vars = len(active[0])

        if mutex:
            self.super = self.minterms
        else:
            self.super = list(set([''.join(bits) for bits in product('01',
                          repeat=self.vars)]) - set(inactive))

    # METHODS

    """
    prime_implicants() -> None

    This function takes a list of minterms and returns a list of fully merged
    prime implicants. The implementation is recursive, calling itself until a
    traversal of the minterms has been completed without any further merging.
    """
    def get_prime_implicants(self, minterms=None) -> None:

        # If this is the first iteration, start from all active + don't cares
        if minterms is None:
            minterms = self.super

        # list of prime implicants
        p_is = []

        # List of minterms that have been merged (one bool per minterm)
        merged = {minterm: False for minterm in minterms}

        # Merge any possible minterms from all combinations and count merges
        merge_cnt = list(map(
            lambda t: (p_is.append(merge(t[0], t[1])) or
                    ((lambda i, j: merged.update({i: True}) or
                        merged.update({j: True}) or False)(t[0], t[1])) or
                    True) if check_merge(t[0], t[1]) and merge(t[0], t[1]) not
                    in minterms else False,
                    list(combinations(minterms, 2)))).count(True)
                
        # Add any unmerged terms to the prime implicants list
        p_is += list(set([minterm for minterm in minterms if not
                          merged[minterm]]))

        # If no merges were made, return the prime implicants list. Otherwise,
        # call the function recursively.
        self.p_is = list(set(p_is))
        if merge_cnt != 0:
            self.get_prime_implicants(minterms=self.p_is)

    """
    p_i_chart() -> None

    Create a prime implicant chart. The chart is a dictionary with the prime
    implicants as keys and the minterms that the prime implicant covers as
    values.
    """
    def p_i_chart(self) -> None:
        self.p_i_dict = {p_i.replace("-", "."): "" for p_i in self.p_is}
        for minterm in self.minterms:
            for p_i in self.p_i_dict:
                if findall(p_i, minterm):
                    self.p_i_dict[p_i] += "1"
                else:
                    self.p_i_dict[p_i] += "0"
        self.p_i_dict = {k: self.p_i_dict[k] for k in sorted(self.p_i_dict) if
                         "1" in self.p_i_dict[k]}

    """
    run_qm() -> None
    
    Run the Quine-McCluskey algorithm on the logic problem. This function will
    call the get_prime_implicants() and p_i_chart() functions, and will print
    the prime implicant chart.
    """
    def run_qm(self)->None:
        self.get_prime_implicants()
        self.p_i_chart()

    """
    get_table() -> None

    Print the prime implicant chart in a table format.
    """
    def get_table(self)->None:
        table_len = (5 * len(self.minterms) + self.vars + 4)
        print("=" * table_len)
        for p_i in self.p_i_dict:
            coverage = ["| x |" if c == "1" else "|   |" for c in
                        self.p_i_dict[p_i]]
            print(f"| {p_i} " + "".join(coverage))
            print("-" * table_len)
        print("=" * table_len)
