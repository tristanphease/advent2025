#ifndef BANK_
#define BANK_
struct Bank {
  int *digits;
  int digit_length;
};
#endif

int parse_line(char *line, int line_length, struct Bank *bank);

void free_bank(struct Bank *bank);

void print_bank(struct Bank *bank);
