// Practice file for nvim-dev drills (C++).
// Messy on purpose: navigate, rename, reformat, and refactor.
// See docs/10-practice-drills.md.

#include <iostream>
#include <string>
#include <vector>

// TODO: rename `add` to `sum_ints` with <leader>rn (Drill 16)
int add(int a, int b) { return a + b; }

int multiply(int a, int b) {
  return a * b;
} // badly formatted: <leader>cf (Drill 18)

struct Point {
  double x;
  double y;
};

// Put the cursor on `Point` above and press gd from its use below (Drill 15)
double distance(const Point &p1, const Point &p2) {
  double dx = p1.x - p2.x;
  double dy = p1.y - p2.y;
  return std::sqrt(dx * dx + dy * dy); // hover std::sqrt with K
}

int main() {
  std::vector<int> nums = {1, 2, 3, 4, 5};
  int total = 0;
  for (int n : nums) {
    total = add(total, n);
  }

  // Three similar lines: try multi-cursor (<C-n>) to rename `pt` -> `pos`
  Point pt1 = {0.0, 0.0};
  Point pt2 = {3.0, 4.0};
  Point pt3 = {6.0, 8.0};
  Point pt4 = {6.1, 2.3};

  std::cout << "total = " << total << std::endl;
  std::cout << "product = " << multiply(6, 7) << std::endl;
  std::cout << "dist = " << distance(pt1, pt2) << std::endl;
  std::cout << "dist = " << distance(pt2, pt3) << std::endl;
  return 0;
}
