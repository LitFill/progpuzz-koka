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

fn to_stack(s: &str) -> Result<Vec<Cmd>, String> {
    s.split(' ')
        .map(|x| match x {
            "+" => Ok(Cmd::Add),
            "-" => Ok(Cmd::Sub),
            "*" => Ok(Cmd::Mul),
            "/" => Ok(Cmd::Div),
            _ => x.parse::<i64>()
                .map(Cmd::Num)
                .map_err(|_| format!("Invalid token: {}", x)),
        })
        .collect() // Automatically short-circuits on the first Err
}

fn eval(cs: &[Cmd]) -> Result<i64, String> {
    let mut stack: Vec<i64> = Vec::new();
    for c in cs {
        match c {
            Cmd::Num(n) => stack.push(*n),
            Cmd::Add => {
                let b = stack.pop().ok_or("Not enough arguments for '+'")?;
                let a = stack.pop().ok_or("Not enough arguments for '+'")?;
                stack.push(a + b);
            }
            Cmd::Sub => {
                let b = stack.pop().ok_or("Not enough arguments for '-'")?;
                let a = stack.pop().ok_or("Not enough arguments for '-'")?;
                stack.push(a - b);
            }
            Cmd::Mul => {
                let b = stack.pop().ok_or("Not enough arguments for '*'")?;
                let a = stack.pop().ok_or("Not enough arguments for '*'")?;
                stack.push(a * b);
            }
            Cmd::Div => {
                let b = stack.pop().ok_or("Not enough arguments for '/'")?;
                if b == 0 {
                    return Err("Division by zero".to_string());
                }
                let a = stack.pop().ok_or("Not enough arguments for '/'")?;
                stack.push(a / b);
            }
        }
    }

    if stack.len() == 1 {
        Ok(stack[0])
    } else if stack.is_empty() {
        Err("Empty expression".to_string())
    } else {
        Err("Too many arguments left on stack".to_string())
    }
}

// Scopes error handling natively through Result pattern matching
fn eval_print(expr: &str) {
    let result = to_stack(expr).and_then(|cs| eval(&cs));
    
    match result {
        Ok(val) => println!("{} = {}", expr, val),
        Err(e) => println!("[ ERROR ] Evaluating '{}': {}", expr, e),
    }
}

fn main() {
    println!("========== RPN Calculator ==========");
    println!();

    eval_print("4 2 /");
    eval_print("7 2 3 * -");
    eval_print("2 3 11 + 5 - *");

    println!();
    println!("=== Testing Error Handling ===");
    eval_print("-");       // Not enough arguments
    eval_print("5 0 /");   // Division by zero
    eval_print("3 4");     // Too many arguments left
    eval_print("2 foo +"); // Invalid token
}
