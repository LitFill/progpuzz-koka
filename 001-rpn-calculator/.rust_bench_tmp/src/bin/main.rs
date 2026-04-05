use std::fmt;

#[derive(Debug, Clone, Copy)]
enum Cmd {
    Num(i64),
    Add,
    Sub,
    Mul,
    Div,
}

impl fmt::Display for Cmd {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Cmd::Num(n) => write!(f, "{}", n),
            Cmd::Add => write!(f, "+"),
            Cmd::Sub => write!(f, "-"),
            Cmd::Mul => write!(f, "*"),
            Cmd::Div => write!(f, "/"),
        }
    }
}

fn to_stack(s: &str) -> Vec<Cmd> {
    s.split(' ')
        .map(|x| match x {
            "+" => Cmd::Add,
            "-" => Cmd::Sub,
            "*" => Cmd::Mul,
            "/" => Cmd::Div,
            // Equivalent to x.parse-int.default(0)
            _ => Cmd::Num(x.parse::<i64>().unwrap_or(0)), 
        })
        .collect()
}

fn eval(cs: &[Cmd]) -> i64 {
    let mut stack: Vec<i64> = Vec::new();
    for c in cs {
        match c {
            Cmd::Num(n) => stack.push(*n),
            Cmd::Add => {
                let b = stack.pop().unwrap();
                let a = stack.pop().unwrap();
                stack.push(a + b);
            }
            Cmd::Sub => {
                let b = stack.pop().unwrap();
                let a = stack.pop().unwrap();
                stack.push(a - b);
            }
            Cmd::Mul => {
                let b = stack.pop().unwrap();
                let a = stack.pop().unwrap();
                stack.push(a * b);
            }
            Cmd::Div => {
                let b = stack.pop().unwrap();
                let a = stack.pop().unwrap();
                stack.push(a / b);
            }
        }
    }
    *stack.last().unwrap() // Equivalent to stack.head.unjust
}

fn main() {
    // Equivalent to setting a general throw handler in Koka, though 
    // these specific tests will just succeed.
    std::panic::set_hook(Box::new(|info| {
        println!("There is an error: {}", info);
    }));

    println!("========== RPN Calculator ==========");
    println!();

    println!("{}", eval(&to_stack("4 2 /")));
    println!("{}", eval(&to_stack("7 2 3 * -")));
    println!("{}", eval(&to_stack("2 3 11 + 5 - *")));
    // println!("{}", eval(&to_stack("-")));
}
