use crate::parser::Direction;

mod parser;

fn main() {
    let args = std::env::args();

    let file_name = args
        .skip(1)
        .next()
        .expect("Pass through arg for the file name");
    let file = std::fs::read_to_string(file_name).expect("Couldn't find file");
    let values = parser::parse_file(&file);
    let zero_num = count_zeroes(&values);

    println!("Found {zero_num} zeroes!");
}

fn count_zeroes(movements: &[parser::Movement]) -> i32 {
    let mut zeroes = 0;
    let mut value = DialValue::new(50, 99);
    for movement in movements.iter() {
        match movement.direction {
            Direction::Left => value.subtract(movement.amount),
            Direction::Right => value.add(movement.amount),
        }
        if value.get_value() == 0 {
            zeroes += 1;
        }
    }

    zeroes
}

// this represents the dial in the puzzle that wraps
struct DialValue {
    value: i32,
    max_value: i32,
}

impl DialValue {
    fn new(initial_value: i32, max_value: i32) -> Self {
        Self {
            value: initial_value,
            max_value,
        }
    }

    fn add(&mut self, amount: i32) {
        let mut new_value = self.value + amount;
        while new_value > self.max_value {
            new_value -= self.max_value + 1;
        }
        self.value = new_value
    }

    fn subtract(&mut self, amount: i32) {
        let mut new_value = self.value - amount;
        while new_value < 0 {
            new_value += self.max_value + 1;
        }
        self.value = new_value
    }

    fn get_value(&self) -> i32 {
        self.value
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_dial_1() {
        let mut dial_value = DialValue::new(50, 99);
        assert_eq!(dial_value.get_value(), 50);
        dial_value.subtract(25);
        assert_eq!(dial_value.get_value(), 25);
        dial_value.subtract(36);
        assert_eq!(dial_value.get_value(), 89);
    }
}
