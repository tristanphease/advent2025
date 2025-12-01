use crate::parser::Direction;

mod parser;

fn main() {
    let mut args = std::env::args();

    let file_name = (&mut args)
        .skip(1)
        .next()
        .expect("Pass through arg for the file name");
    let method_arg = args.next();
    let method = match method_arg {
        Some(method_value) => match method_value.as_ref() {
            "2" => Method::Part2,
            _ => Method::Part1,
        },
        None => Method::Part1,
    };
    let file = std::fs::read_to_string(file_name).expect("Couldn't find file");
    let values = parser::parse_file(&file);
    let zero_num = count_zeroes(&values, method);

    println!("Found {zero_num} zeroes!");
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Method {
    Part1,
    Part2,
}

fn count_zeroes(movements: &[parser::Movement], method: Method) -> i32 {
    let mut value = DialValue::new(50, 100, method);
    for movement in movements.iter() {
        match movement.direction {
            Direction::Left => value.subtract(movement.amount),
            Direction::Right => value.add(movement.amount),
        }
    }

    value.get_zeroes()
}

// this represents the dial in the puzzle that wraps
struct DialValue {
    value: i32,
    modulus: i32,
    num_zeroes: i32,
    method: Method,
}

impl DialValue {
    fn new(initial_value: i32, modulus: i32, method: Method) -> Self {
        Self {
            value: initial_value,
            modulus,
            method,
            num_zeroes: 0,
        }
    }

    fn add(&mut self, amount: i32) {
        let mut new_value = self.value + amount;
        let diff = new_value / self.modulus;
        new_value -= diff * self.modulus;
        if self.method == Method::Part2 {
            self.num_zeroes += diff;

            // edge case where if we add up to a 0 then we don't want to double count
            if new_value == 0 {
                self.num_zeroes -= 1;
            }
        }
        self.value = new_value;
        if new_value == 0 {
            self.num_zeroes += 1;
        }
    }

    fn subtract(&mut self, amount: i32) {
        let mut new_value = self.value - amount;
        let diff = (-new_value + self.modulus - 1) / self.modulus;
        new_value += diff * self.modulus;
        if self.method == Method::Part2 {
            self.num_zeroes += diff;
            // edge case where if we subtract from 0 then we don't want to double count
            if self.value == 0 {
                self.num_zeroes -= 1;
            }
        }
        self.value = new_value;
        if new_value == 0 {
            self.num_zeroes += 1;
        }
    }

    fn get_zeroes(&self) -> i32 {
        self.num_zeroes
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_dial_1() {
        let mut dial_value = DialValue::new(50, 100, Method::Part1);
        dial_value.subtract(25);
        dial_value.subtract(25);
        assert_eq!(dial_value.get_zeroes(), 1)
    }

    #[test]
    fn test_dial_2() {
        let mut dial_value = DialValue::new(50, 100, Method::Part2);
        dial_value.subtract(200);
        assert_eq!(dial_value.get_zeroes(), 2);
    }

    #[test]
    fn test_dial_3() {
        let mut dial_value = DialValue::new(50, 100, Method::Part2);
        dial_value.subtract(50);
        dial_value.add(30);
        assert_eq!(dial_value.get_zeroes(), 1);

        let mut dial_value = DialValue::new(50, 100, Method::Part2);
        dial_value.add(50);
        dial_value.subtract(50);
        assert_eq!(dial_value.get_zeroes(), 1);
    }
}
