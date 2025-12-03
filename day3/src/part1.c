#include "part1.h"

int max_voltage(struct Bank *bank) {
  // simple strategy is to find the highest number
  // that's not at the end, then find the highest number after that
  // concatenate them together and voila
  int first_index = 0;
  int first_value = -1;
  for (int i = 0; i < bank->digit_length - 1; i++) {
    if (bank->digits[i] > first_value) {
      first_index = i;
      first_value = bank->digits[i];
    }
  }

  int second_index = 0;
  int second_value = -1;

  for (int i = first_index + 1; i < bank->digit_length; i++) {
    if (bank->digits[i] > second_value) {
      second_index = i;
      second_value = bank->digits[i];
    }
  }

  return first_value * 10 + second_value;
}
