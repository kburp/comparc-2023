# input for left shifter
"""
for i in range(32):
    print(f".in{i}({{in[N-{i+1}:0], {i}'b0}}), ", end="")
print()
"""

"""
# input for logic right shifter
for i in range(32):
    print(f".in{i}({{{i}'b0, in[N-1:{i}]}}), ", end="")
print()
"""


# input for arithmetic right shifter
for i in range(32):
    print(f".in{i}({{{{{i} {{in[N-1]}}}}, in[N-1:{i}]}}), ", end="")
print()
