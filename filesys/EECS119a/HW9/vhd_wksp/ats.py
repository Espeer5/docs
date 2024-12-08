from math import atan, atanh, sqrt

def dec_to_fp(x):
    return bin(int((2 ** 14) * x))

def dec_to_fp17(x):
    return bin(int((2 ** 17) * x))

def dec_to_fp18(x):
    return bin(int((2 ** 18) * x))

def gen_const():
    for i in range(18):
        print(dec_to_fp18(atan(2 ** -i)))

def gen_hconst():
    for i in range(1, 19):
        print(dec_to_fp18(atanh(2 ** -i)))

def k_vals():
    k = 1 / sqrt(1 + 2**0)
    for i in range(1, 100):
        k *= 1 / sqrt(1 + (2**(-2*i)))
        print(k)
    print(dec_to_fp18(k))

def hk_vals():
    k = 1 / sqrt(1 + 2**0)
    for i in range(1, 100):
        k *= 1 / sqrt(1 - (2**(-2*i)))
        print(k)
    print(dec_to_fp18(k))

if __name__ == '__main__':
    gen_hconst()
