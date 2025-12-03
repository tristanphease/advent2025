#include "part1.h"
#include <stdio.h>
#include <string.h>

int main(int arg_length, char **args) {
  if (arg_length > 1) {
    FILE *file_pointer;
    errno_t error_number = fopen_s(&file_pointer, args[1], "r");
    if (error_number != 0) {
      char error_message[100];
      strerror_s(error_message, 100, error_number);
      fprintf(stderr, "Couldn't open file '%s': %s\n", args[1], error_message);
    } else {
      long total_output = 0;
      char file_contents[1000];
      while (fgets(file_contents, 1000, file_pointer)) {
        struct Bank bank;
        parse_line(file_contents, 1000, &bank);
        // print_bank(&bank);
        total_output += max_voltage(&bank);
        free_bank(&bank);
      }

      printf("total output is %lu", total_output);

      fclose(file_pointer);
    }

  } else {
    printf("No args provided");
  }
}
