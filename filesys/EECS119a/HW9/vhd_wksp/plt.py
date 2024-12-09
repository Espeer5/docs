################################################################################
#                                                                              #
#  MODULE plt                                                                  #
#                                                                              #
#  This module contains functions to read in the output of the CORDIC16 VHDL   #
#  testbench and plot the results of the 6 CORDIC functions compared to the    #
#  expected results from the input space.                                      #
#                                                                              #
#  Revision History:                                                           #
#      12/8/2024  Edward Speer  Initial Revision                               #
#                                                                              #
################################################################################

################################################################################
#  IMPORTS                                                                     #
################################################################################

import re
import numpy as np
import matplotlib.pyplot as plt


################################################################################
#  FUNCTIONS                                                                   #
################################################################################


"""
This function reads the output of the CORDIC16 VHDL testbench and extracts the
binary results from the file. The binary results are stored in a list and
returned to the caller.
"""
def extract_binary_results(file_path):
    binary_results = []

    with open(file_path, 'r') as file:
        for line in file:
            # Use regular expression to find the binary pattern in the line
            match = re.search(r"'\d''\d''\d''\d''\d''\d''\d''\d''\d''\d''\d'" +
                              r"'\d''\d''\d''\d''\d'", line)
            if match:
                # Extract the binary string and remove the single quotes
                binary_string = match.group().replace("'", "")
                binary_results.append(binary_string)

    return binary_results


"""
This function converts a binary string to a floating point number. The binary
string is converted to a decimal number and then divided by 2^14 to get the
floating point representation.
"""
def convert_to_float(binary_string):
    # Convert the binary string to a decimal number
    return int(binary_string, 2) / (1 << 14)


"""
This function returns the computed cosine values from the VHDL testbench.
"""
def get_act_cos():
    return [convert_to_float(str) for str in
            extract_binary_results("res.txt")[212:]]


"""
This function returns the computed sine values from the VHDL testbench.
"""
def get_act_sin():
    return [convert_to_float(str) for str in
            extract_binary_results("res.txt")[168:212]]


"""
This function returns the computed hyperbolic cosine values from the VHDL
"""
def get_act_cosh():
    return [convert_to_float(str) for str in
            extract_binary_results("res.txt")[124:168]]


"""
This function returns the computed hyperbolic sine values from the VHDL
testbench.
"""
def get_act_sinh():
    return [convert_to_float(str) for str in
            extract_binary_results("res.txt")[80:124]]


"""
This function returns the computed multiplication values from the VHDL
testbench.
"""
def get_act_mul():
    return [convert_to_float(str) for str in
            extract_binary_results("res.txt")[40:80]]


"""
This function returns the computed division values from the VHDL testbench.
"""
def get_act_div():
    return [convert_to_float(str) for str in
            extract_binary_results("res.txt")[0:40]]


"""
This function returns the expected cosine values for the input space.
"""
def get_exp_cos():
    return np.cos(get_inputs())


"""
This function returns the expected sine values for the input space.
"""
def get_exp_sin():
    return np.sin(get_inputs())


"""
This function returns the expected hyperbolic cosine values for the input space.
"""
def get_exp_cosh():
    return np.cosh(get_inputs())


"""
This function returns the expected hyperbolic sine values for the input space.
"""
def get_exp_sinh():
    return np.sinh(get_inputs())


"""
This function returns the expected multiplication values for the input space.
"""
def get_exp_mul():
    b = np.arange(0.1, 1.1, .025)[::-1]
    a = np.arange(1.1, 0.1, -.025)[::-1]
    return (b * a)


"""
This function returns the expected division values for the input space.
"""
def get_exp_div():
    b = np.arange(0.1, 1.1, .025)[::-1]
    a = np.arange(1.1, 0.1, -.025)[::-1]
    return (b / a)


"""
This function returns the input angles for the trigonometric functions.
"""
def get_inputs():
    return np.arange(np.radians(2), np.radians(90), np.radians(2))[::-1]


################################################################################
#  MAIN                                                                        #
################################################################################


if __name__ == "__main__":

    # Compute the input angles for trig functions
    inputs   = get_inputs()

    # Parse all test results
    cos_res  = get_act_cos()
    sin_res  = get_act_sin()
    cosh_res = get_act_cosh()
    sinh_res = get_act_sinh()
    mul_res  = get_act_mul()
    div_res  = get_act_div()

    # Compute the expected results for each function
    exp_cos  = get_exp_cos()
    exp_sin  = get_exp_sin()
    exp_cosh = get_exp_cosh()
    exp_sinh = get_exp_sinh()
    exp_mul  = get_exp_mul()
    exp_div  = get_exp_div()

    # Plot the expected vs actual results for each function
    plt.plot(inputs, exp_cos, label="Expected Cosine")
    plt.plot(inputs, cos_res, label="Actual Cosine")
    plt.title("Expected vs Actual CORDIC16 Outputs")
    plt.xlabel("Angle (radians)")
    plt.legend()
    plt.savefig("cordic16_cos.png")
    plt.clf()
    plt.plot(inputs, exp_sin, label="Expected Sine")
    plt.plot(inputs, sin_res, label="Actual Sine")
    plt.title("Expected vs Actual CORDIC16 Outputs")
    plt.xlabel("Angle (radians)")
    plt.legend()
    plt.savefig("cordic16_sin.png")
    plt.clf()
    plt.plot(inputs, exp_cosh, label="Expected Cosh")
    plt.plot(inputs, cosh_res, label="Actual Cosh")
    plt.title("Expected vs Actual CORDIC16 Outputs")
    plt.xlabel("Angle (radians)")
    plt.legend()
    plt.savefig("cordic16_cosh.png")
    plt.clf()
    plt.plot(inputs, exp_sinh, label="Expected Sinh")
    plt.plot(inputs, sinh_res, label="Actual Sinh")
    plt.title("Expected vs Actual CORDIC16 Outputs")
    plt.xlabel("Angle (radians)")
    plt.legend()
    plt.savefig("cordic16_sinh.png")
    plt.clf()
    plt.plot(range(len(exp_mul)), exp_mul, label="Expected Mul")
    plt.plot(range(len(mul_res)), mul_res, label="Actual Mul")
    plt.title("Expected vs Actual CORDIC16 Outputs")
    plt.xlabel("Test case")
    plt.legend()
    plt.savefig("cordic16_mul.png")
    plt.clf()
    plt.plot(range(len(exp_div)), exp_div, label="Expected Div")
    plt.plot(range(len(div_res)), div_res, label="Actual Div")
    plt.title("Expected vs Actual CORDIC16 Outputs")
    plt.xlabel("Test case")
    plt.legend()
    plt.savefig("cordic16_div.png")
    plt.clf()
