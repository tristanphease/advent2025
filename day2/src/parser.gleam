import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type IdRange {
  IdRange(id1: Int, id2: Int)
}

fn parse_id_string(id_string: String) -> Result(IdRange, String) {
  string.split_once(id_string, "-")
  |> result.map(fn(ids) {
    case int.parse(ids.0), int.parse(ids.1) {
      Ok(num1), Ok(num2) -> Ok(IdRange(num1, num2))
      _, _ ->
        Error("Couldn't parse nums from " <> ids.0 <> " or " <> ids.1 <> ".")
    }
  })
  |> result.map_error(fn(_) { "Couldn't split " <> id_string <> " on -" })
  |> result.flatten()
}

pub fn parse_ids(input_file: String) -> Result(List(IdRange), String) {
  input_file
  |> string.trim
  |> string.split(",")
  |> list.map(parse_id_string)
  |> result.all()
}
