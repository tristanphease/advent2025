import argv
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import parser
import simplifile

pub fn main() -> Nil {
  case argv.load().arguments {
    [file_name, "2"] -> {
      read_file_and_print(file_name, Part2)
    }
    [file_name, ..] -> {
      read_file_and_print(file_name, Part1)
    }
    _ -> io.println("Pass through input file")
  }
}

fn read_file_and_print(file_name: String, method: Method) {
  case simplifile.read(from: file_name) {
    Ok(input_file) -> {
      case parser.parse_ids(input_file) {
        Ok(id_ranges) -> {
          print_sum(id_ranges, method)
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

pub type Method {
  Part1
  Part2
}

pub fn print_sum(id_ranges: List(parser.IdRange), method: Method) -> Nil {
  let invalid_check_func = case method {
    Part1 -> check_invalid
    Part2 -> check_invalid_part_2
  }
  let sum_range = get_sum(id_ranges, invalid_check_func)
  io.print("Sum of id ranges is " <> int.to_string(sum_range))
}

pub fn get_sum(
  id_ranges: List(parser.IdRange),
  invalid_func: fn(Int) -> Bool,
) -> Int {
  id_ranges
  |> list.map(fn(x) { get_invalid_range(x, invalid_func) })
  |> list.flatten()
  |> list.fold(0, fn(a, b) { a + b })
}

pub fn get_invalid_range(
  id_range: parser.IdRange,
  invalid_func: fn(Int) -> Bool,
) -> List(Int) {
  list.range(id_range.id1, id_range.id2) |> list.filter(invalid_func)
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

pub fn check_invalid_part_2(num: Int) -> Bool {
  let num_string = int.to_string(num)

  let num_length = string.length(num_string)
  num_length
  |> get_factors()
  |> list.any(fn(factor) {
    // e.g. 10, 2 would give [1, 2, 3, 4, 5]
    // then we get slices [0, 1], [2, 3]
    let #(result, _) =
      list.range(0, num_length / factor - 1)
      |> list.map(fn(index) { string.slice(num_string, index * factor, factor) })
      |> list.fold(#(True, option.None), fn(accum, value) {
        case accum.1 {
          option.Some(old_val) -> #(
            accum.0 && value == old_val,
            option.Some(value),
          )
          option.None -> #(True, option.Some(value))
        }
      })
    // second condition here is to ensure that we have at least two entries in the list above
    result && num_length / factor - 1 > 0
  })
}

fn divides_exactly(num: Int, divisor: Int) -> Bool {
  int.remainder(num, divisor) == Ok(0)
}

fn floor_square_root(num: Int) -> Int {
  int.square_root(num) |> result.unwrap(0.0) |> float.floor() |> float.round()
}

pub fn get_factors(num: Int) -> List(Int) {
  // get all the factors of a number except the number itself
  list.range(1, floor_square_root(num))
  |> list.filter(fn(x) { divides_exactly(num, x) })
  |> list.map(fn(x) {
    case x == 1 {
      True -> [x]
      False -> [x, num / x]
    }
  })
  |> list.flatten()
}
