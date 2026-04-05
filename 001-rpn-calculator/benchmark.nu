#!/usr/bin/env nu

def main [] {
    # 1. Verify dependencies
    if (which cargo | is-empty) {
        print "[!] Error: 'cargo' is not installed."
        exit 1
    }
    if (which koka | is-empty) {
        print "[!] Error: 'koka' is not installed."
        exit 1
    }

    let ext: string = if ($nu.os-info.name == "windows") { ".exe" } else { "" }

    # 2. Compile Rust implementations via a temporary Cargo project
    print "[+] Setting up temporary Cargo project for Nix-compatible compilation..."

    # Clean up previous temp dir if it exists
    if ("rust_bench_tmp" | path exists) { rm -r rust_bench_tmp }

    # Create cargo project and setup bin directory
    cargo new --name rust_bench_tmp --vcs none rust_bench_tmp | ignore
    mkdir rust_bench_tmp/src/bin

    # Copy standalone files to be compiled as individual binaries
    cp main.rs      rust_bench_tmp/src/bin/main.rs
    cp allstring.rs rust_bench_tmp/src/bin/allstring.rs
    cp prod.rs      rust_bench_tmp/src/bin/prod.rs

    print "[+] Compiling Rust implementations (--release)..."
    # Use manifest-path to avoid needing to `cd` inside Nushell
    cargo build --release --manifest-path rust_bench_tmp/Cargo.toml

    # Extract compiled binaries to current folder
    cp $"rust_bench_tmp/target/release/main($ext)"      $"main_rs($ext)"
    cp $"rust_bench_tmp/target/release/allstring($ext)" $"allstring_rs($ext)"
    cp $"rust_bench_tmp/target/release/prod($ext)"      $"prod_rs($ext)"

    # Clean up temp cargo project
    rm -r rust_bench_tmp

    # 3. Compile Koka implementations
    print "[+] Compiling Koka implementations (--optimize)..."
    koka --optimize=3 -o $"main_kk($ext)" main.kk
    koka --optimize=3 -o $"allstring_kk($ext)" allstring.kk
    koka --optimize=3 -o $"prod_kk($ext)" prod.kk

    # 4. Define binaries to benchmark
    let bins = [
        $"./main_rs($ext)",
        $"./main_kk($ext)",
        $"./allstring_rs($ext)",
        $"./allstring_kk($ext)",
        $"./prod_rs($ext)",
        $"./prod_kk($ext)"
    ]

    print "\n[+] Starting benchmarks...\n"

    # 5. Run Benchmarks
    if (which hyperfine | is-empty) {
        print "=> 'hyperfine' utility not found. Falling back to Nushell 'timeit'...\n"

        for bin in $bins {
            print $"Benchmarking ($bin):"
            let duration = timeit {
                for i in 1..100 {
                    ^$bin | ignore
                }
            }
            print $"  Time: ($duration) \(per 100 executions)\n"
        }
    } else {
        print "=> Running hyperfine...\n"
        hyperfine --warmup 10 -N ...$bins
    }

    print "\n[+] Done!"
}
