import argv
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import parser
import simplifile

pub fn main() -> Nil {
  case argv.load().arguments {
    [file_name, ..] -> {
      case simplifile.read(from: file_name) {
        Ok(input_file) -> {
          case parser.parse_ids(input_file) {
            Ok(id_ranges) -> {
              print_sum(id_ranges)
            }
            Error(message) -> io.print_error(message)
          }
        }
        Error(error) ->
          io.print_error(
            "Couldn't load file - " <> error |> simplifile.describe_error(),
          )
      }
    }
    _ -> io.println("Pass through input file")
  }
}

pub fn print_sum(id_ranges: List(parser.IdRange)) -> Nil {
  let sum_range = get_sum(id_ranges)
  io.print("Sum of id ranges is " <> int.to_string(sum_range))
}

pub fn get_sum(id_ranges: List(parser.IdRange)) -> Int {
  id_ranges
  |> list.map(get_invalid_range)
  |> list.flatten()
  |> list.fold(0, fn(a, b) { a + b })
}

pub fn get_invalid_range(id_range: parser.IdRange) -> List(Int) {
  list.range(id_range.id1, id_range.id2) |> list.filter(check_invalid)
}

pub fn check_invalid(num: Int) -> Bool {
  let num_string = int.to_string(num)
  let length = string.length(num_string)
  case int.is_even(length) {
    True ->
      num_string |> string.slice(0, length / 2)
      == num_string |> string.slice(length / 2, length / 2)
    False -> False
  }
}
