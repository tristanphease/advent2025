#include "../src/part1.h"
#include <assert.h>
#include <stdio.h>

void max_voltage_test() {
  struct Bank bank1;
  int test_numbers1[] = {2, 3, 4, 2, 3, 4, 2, 3, 4, 2, 3, 4, 2, 7, 8};
  bank1.digits = test_numbers1;
  bank1.digit_length = sizeof(test_numbers1) / sizeof(test_numbers1[0]);
  printf("max_voltage(&bank1): %d\n", max_voltage(&bank1));
  assert(max_voltage(&bank1) == 78);

  struct Bank bank2;
  int test_numbers2[] = {8, 1, 8, 1, 8, 1, 9, 1, 1, 1, 1, 2, 1, 1, 1};
  bank2.digits = test_numbers2;
  bank2.digit_length = sizeof(test_numbers2) / sizeof(test_numbers2[0]);
  printf("max_voltage(&bank2): %d\n", max_voltage(&bank2));
  assert(max_voltage(&bank2) == 92);
}

int main() { max_voltage_test(); }
