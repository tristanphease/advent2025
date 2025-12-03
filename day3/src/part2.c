#include "part2.h"
#include <math.h>

#define NUM 12

unsigned long long max_voltage_2(struct Bank *bank) {
  // just doing the same thing as part1, just using a loop
  // instead of manually doing it twice
  int digit_num;
  int digits[NUM];
  int last_index = -1;
  for (digit_num = NUM; digit_num >= 0; digit_num--) {
    int current_index = 0;
    int current_value = -1;
    for (int i = last_index + 1; i < bank->digit_length - digit_num + 1; i++) {
      if (bank->digits[i] > current_value) {
        current_index = i;
        current_value = bank->digits[i];
      }
    }
    last_index = current_index;
    digits[NUM - digit_num] = current_value;
  }

  unsigned long long result = 0;
  for (int i = 0; i < NUM; i++) {
    result += digits[i] * (unsigned long long)pow(10, NUM - i - 1);
  }
  return result;
}
