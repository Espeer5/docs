from math import atan, atanh, sqrt
import numpy as np

def dec_to_fp(x):
    return format(int(round(x * (1 << 14))), '016b')

def dec_to_fp18(x):
    return format(int(round(x * (1 << 18))), '018b')

def gen_const():
    for i in range(18):
        print(dec_to_fp18(atan(2 ** -i)))

def gen_hconst():
    for i in range(1, 19):
        print(dec_to_fp18(atanh(2 ** -i)))

def k_vals():
    k = 1 / sqrt(1 + 2**0)
    for i in range(1, 18):
        k *= 1 / sqrt(1 + (2**(-2*i)))
        print(k)
    print(dec_to_fp18(k))

def hk_vals():
    k = 1 / sqrt(1 + 2**0)
    for i in range(1, 18):
        k *= 1 / sqrt(1 - (2**(-2*i)))
        print(k)
    print(dec_to_fp18(k))

def gen_tests():
    th = np.radians(2)
    while th < np.radians(90):
        out = dec_to_fp(th)
        print("\"" + out + "\" &")
        th += np.radians(2)

if __name__ == '__main__':
    gen_tests()
