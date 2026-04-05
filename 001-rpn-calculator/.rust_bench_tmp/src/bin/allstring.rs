fn rpn(s: &str) -> i64 {
    let mut stack: Vec<i64> = Vec::new();

    for tok in s.split(' ') {
        let is_op = ["+", "-", "*", "/"].contains(&tok);
        if is_op {
            let b = stack.pop().unwrap();
            let a = stack.pop().unwrap();
            
            let res = match tok {
                "+" => a + b,
                "-" => a - b,
                "*" => a * b,
                "/" => a / b,
                _ => unreachable!(),
            };
            stack.push(res);
        } else {
            stack.push(tok.parse().unwrap());
        }
    }
    
    *stack.last().unwrap()
}

fn main() {
    println!("{}", rpn("1 2 3 + -"));
    println!("{}", rpn("4 2 /"));
    println!("{}", rpn("7 2 3 * -"));
    println!("{}", rpn("2 3 11 + 5 - *"));
}
