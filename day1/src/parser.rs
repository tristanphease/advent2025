use nom::{
    IResult, Parser,
    branch::alt,
    bytes::tag,
    character::complete::{digit1, line_ending},
    combinator::{iterator, map_res, value},
    sequence::terminated,
};

#[derive(Clone, Debug, PartialEq)]
pub enum Direction {
    Left,
    Right,
}

#[derive(Clone, Debug, PartialEq)]
pub struct Movement {
    pub direction: Direction,
    pub amount: i32,
}

impl Movement {
    fn new(direction: Direction, amount: i32) -> Self {
        Self { direction, amount }
    }
}

fn direction(input: &str) -> IResult<&str, Direction> {
    alt((
        value(Direction::Left, tag("L")),
        value(Direction::Right, tag("R")),
    ))
    .parse(input)
}

fn amount(input: &str) -> IResult<&str, i32> {
    map_res(digit1, str::parse).parse(input)
}

fn movement(input: &str) -> IResult<&str, Movement> {
    let (input, (dir, amount)) = (direction, amount).parse(input)?;

    Ok((input, Movement::new(dir, amount)))
}

pub fn parse_file(input: &str) -> Vec<Movement> {
    // separated_list1(line_ending, movement).parse(input)
    let mut nom_iterator = iterator(input, terminated(movement, line_ending));

    let mut parsed = nom_iterator.by_ref().collect::<Vec<_>>();
    let result = nom_iterator.finish();

    match result {
        Ok((remaining_input, _)) => {
            if let Ok(final_value) = movement(remaining_input) {
                parsed.push(final_value.1);
            }
        }
        _ => {}
    };

    parsed
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_direction_parser() {
        assert_eq!(direction("L"), Ok(("", Direction::Left)));
        assert_eq!(direction("R21"), Ok(("21", Direction::Right)));
        assert!(direction("G16").is_err());
    }

    #[test]
    fn test_amount_parser() {
        assert_eq!(amount("21"), Ok(("", 21)));
    }

    #[test]
    fn test_movement_parser() {
        assert_eq!(
            movement("R45"),
            Ok(("", Movement::new(Direction::Right, 45)))
        );

        assert_eq!(
            movement("L83"),
            Ok((
                "",
                Movement {
                    direction: Direction::Left,
                    amount: 83
                }
            ))
        );
    }

    #[test]
    fn test_line_parser() {
        let input = "L21\nR32";
        assert_eq!(
            parse_file(input),
            vec![
                Movement::new(Direction::Left, 21),
                Movement::new(Direction::Right, 32)
            ]
        );

        let input_with_line_end = "R86\nR10\n";
        assert_eq!(
            parse_file(input_with_line_end),
            vec![
                Movement::new(Direction::Right, 86),
                Movement::new(Direction::Right, 10)
            ]
        );
    }
}
