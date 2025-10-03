mod cyclotomic;
mod cassels;

use cassels::get_candidates;

use std::fs::File;
use std::io::Result;

/// Compute cyclotomic integers that have to be covered by the main theorem
/// (Theorem 1.2).
///
/// This function (entry point of our program) runs on all couples (N, n)
/// specified by Lemma 3.11 to obtain a list of cyclotomic integers (exported in
/// the `output.txt` file) that are then given to Sage to algebraically verify
/// that they are covered by the main theorem. More details on the transition
/// from Rust to Sage in the paper or in the READMEs of the repository.
fn main() -> Result<()> {
    let file_tables = File::create("tables.txt")?;
    let file_output = File::create("output.txt")?;
    let inputs = [(2*2*3*5*7,       7),  // Proposition 4.3
                  (31,              6),  // Remark 8.3
                  (3*5*7*13,        5),  // Section 8.3.1
                  (2*2*3*5*7*11,    5),  // Sections 4.2.1, 8.2.1
                  (5*19,            4),  // Section 4.2.4
                  (5*17,            4),  // Section 4.2.4
                  (2*2*3*5*7*11*13, 4),  // Section 4.2.2
                  (2*2*2*3*3*5*7,   4)]; // Proposition 4.1
    for (n0, len) in inputs {
        get_candidates(n0, len, &file_tables, &file_output);
    }

    println!("All cases checked!");
    Ok(())
}
