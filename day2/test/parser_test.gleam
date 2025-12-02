import gleam/result
import parser

pub fn parse_ids_test() {
  assert parser.parse_ids("11-22") == Ok([parser.IdRange(11, 22)])
  assert parser.parse_ids("93-1234,129-203")
    == Ok([parser.IdRange(93, 1234), parser.IdRange(129, 203)])

  assert parser.parse_ids("321-34-13") |> result.is_error()
}
