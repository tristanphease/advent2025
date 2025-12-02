import day2
import gleam/int
import gleam/list
import gleeunit
import parser

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn check_invalid_test() {
  assert day2.check_invalid(93) == False
  assert day2.check_invalid(55) == True
  assert day2.check_invalid(894_894) == True
  assert day2.check_invalid(324_894) == False
}

pub fn get_invalid_range_test() {
  assert day2.get_invalid_range(parser.IdRange(11, 15), day2.check_invalid)
    == [11]
  assert day2.get_invalid_range(parser.IdRange(1234, 1616), day2.check_invalid)
    == [1313, 1414, 1515, 1616]
  assert day2.get_invalid_range(
      parser.IdRange(38_593_856, 38_593_862),
      day2.check_invalid,
    )
    == [38_593_859]
}

pub fn get_sum_test() {
  assert day2.get_sum(
      [parser.IdRange(11, 15), parser.IdRange(1234, 1616)],
      day2.check_invalid,
    )
    == 11 + 1313 + 1414 + 1515 + 1616

  assert day2.get_sum(
      [
        parser.IdRange(11, 22),
        parser.IdRange(95, 115),
        parser.IdRange(998, 1012),
        parser.IdRange(1_188_511_880, 1_188_511_890),
        parser.IdRange(222_220, 222_224),
        parser.IdRange(1_698_522, 1_698_528),
        parser.IdRange(446_443, 446_449),
        parser.IdRange(38_593_856, 38_593_862),
      ],
      day2.check_invalid,
    )
    == 1_227_775_554
}

pub fn get_factors_test() {
  assert day2.get_factors(3) == [1]
  assert day2.get_factors(12) |> list.sort(int.compare) == [1, 2, 3, 4, 6]
  assert day2.get_factors(38) |> list.sort(int.compare) == [1, 2, 19]
}

pub fn check_invalid_part_2_test() {
  assert day2.check_invalid_part_2(111) == True
  assert day2.check_invalid_part_2(892) == False
}

pub fn get_invalid_range_part_2() {
  assert day2.get_invalid_range(
      parser.IdRange(11, 22),
      day2.check_invalid_part_2,
    )
    == [11, 22]

  assert day2.get_invalid_range(
      parser.IdRange(95, 115),
      day2.check_invalid_part_2,
    )
    == [99, 111]
  assert day2.get_invalid_range(
      parser.IdRange(998, 1012),
      day2.check_invalid_part_2,
    )
    == [999, 1010]
  assert day2.get_invalid_range(
      parser.IdRange(2_121_212_118, 2_121_212_124),
      day2.check_invalid_part_2,
    )
    == [2_121_212_121]
}

pub fn get_sum_part2_test() {
  assert day2.get_sum(
      [
        parser.IdRange(11, 22),
        parser.IdRange(95, 115),
        parser.IdRange(998, 1012),
        parser.IdRange(1_188_511_880, 1_188_511_890),
        parser.IdRange(222_220, 222_224),
        parser.IdRange(1_698_522, 1_698_528),
        parser.IdRange(446_443, 446_449),
        parser.IdRange(38_593_856, 38_593_862),
        parser.IdRange(565_653, 565_659),
        parser.IdRange(824_824_821, 824_824_827),
        parser.IdRange(2_121_212_118, 2_121_212_124),
      ],
      day2.check_invalid_part_2,
    )
    == 4_174_379_265
}
