import day2
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
  assert day2.get_invalid_range(parser.IdRange(11, 15)) == [11]
  assert day2.get_invalid_range(parser.IdRange(1234, 1616))
    == [1313, 1414, 1515, 1616]
  assert day2.get_invalid_range(parser.IdRange(38_593_856, 38_593_862))
    == [38_593_859]
}

pub fn get_sum_test() {
  assert day2.get_sum([parser.IdRange(11, 15), parser.IdRange(1234, 1616)])
    == 11 + 1313 + 1414 + 1515 + 1616

  assert day2.get_sum([
      parser.IdRange(11, 22),
      parser.IdRange(95, 115),
      parser.IdRange(998, 1012),
      parser.IdRange(1_188_511_880, 1_188_511_890),
      parser.IdRange(222_220, 222_224),
      parser.IdRange(1_698_522, 1_698_528),
      parser.IdRange(446_443, 446_449),
      parser.IdRange(38_593_856, 38_593_862),
    ])
    == 1_227_775_554
}
