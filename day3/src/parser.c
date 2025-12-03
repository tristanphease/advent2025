#include "parser.h"
#include <stdio.h>
#include <stdlib.h>

int convert_char_int(char value) { return value - '0'; }

int parse_line(char *line, int line_length, struct Bank *bank) {
  // allocate digits on the heap
  bank->digits = malloc(300 * sizeof(int));
  int i;
  for (i = 0; i < 300 && line[i] != '\0'; i++) {
    bank->digits[i] = convert_char_int(line[i]);
  }

  bank->digit_length = i - 1;

  return 0;
}

void free_bank(struct Bank *bank) { free(bank->digits); }

void print_bank(struct Bank *bank) {
  printf("[");
  for (int i = 0; i < bank->digit_length; i++) {
    if (i == bank->digit_length - 1) {
      printf("%d", bank->digits[i]);
    } else {
      printf("%d, ", bank->digits[i]);
    }
  }
  printf("]\n");
}
