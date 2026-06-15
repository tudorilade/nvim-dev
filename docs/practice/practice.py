"""Practice file for nvim-dev drills.

Intentionally messy and repetitive so you have things to navigate, refactor,
rename, and reformat. See docs/10-practice-drills.md.
"""

import math


# TODO: rename this function to `area_of_circle` using <leader>rn (Drill 16)
def calc(r):
    return math.pi * r * r


def calc_volume(r, h):
    # FIXME: this uses calc() — jump to its definition with gd (Drill 15)
    return calc(r) * h


class shape:
    def __init__(self, name, sides):
        self.name = name
        self.sides = sides

    def describe(self):
        print("describe something w")
        return self.name + " has " + str(self.sides) + " sides"


# Three similar lines — great for multi-cursor / macros (Drill 19)
sq = shape("square", 4)
tri = shape("triangle", 3)
pent = shape("pentagon", 5)

# A list to turn into function calls with a macro (Drill 20)
# alpha
# beta
# gamma

values = [1, 2, 3, 4, 5]  # badly formatted: fix with <leader>cf (Drill 18)
total = 0
for v in values:
    total = total + v

print("total:", total)
print(calc(2))
print(calc_volume(2, 10))
print(sq.describe())
print(tri.describe())
print(pent.describe())
