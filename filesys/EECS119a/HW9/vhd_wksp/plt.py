import re
import numpy as np
import matplotlib.pyplot as plt

def extract_binary_results(file_path):
    binary_results = []

    with open(file_path, 'r') as file:
        for line in file:
            # Use regular expression to find the binary pattern in the line
            match = re.search(r"'\d''\d''\d''\d''\d''\d''\d''\d''\d''\d''\d''\d''\d''\d''\d''\d'", line)
            if match:
                # Extract the binary string and remove the single quotes
                binary_string = match.group().replace("'", "")
                binary_results.append(binary_string)

    return binary_results

def convert_to_float(binary_string):
    # Convert the binary string to a decimal number
    return int(binary_string, 2) / (1 << 14)

def get_act_cos():
    return [convert_to_float(str) for str in extract_binary_results("res.txt")[132:]]

def get_act_sin():
    return [convert_to_float(str) for str in extract_binary_results("res.txt")[88:132]]

def get_act_cosh():
    return [convert_to_float(str) for str in extract_binary_results("res.txt")[44:88]]

def get_act_sinh():
    return [convert_to_float(str) for str in extract_binary_results("res.txt")[:44]]

def get_exp_cos():
    return np.cos(get_inputs())

def get_exp_sin():
    return np.sin(get_inputs())

def get_exp_cosh():
    return np.cosh(get_inputs())

def get_exp_sinh():
    return np.sinh(get_inputs())

def get_inputs():
    return np.arange(np.radians(2), np.radians(90), np.radians(2))[::-1]



if __name__ == "__main__":
    inputs = get_inputs()
    cos_res = get_act_cos()
    sin_res = get_act_sin()
    cosh_res = get_act_cosh()
    sinh_res = get_act_sinh()
    exp_cos = get_exp_cos()
    exp_sin = get_exp_sin()
    exp_cosh = get_exp_cosh()
    exp_sinh = get_exp_sinh()
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
