use std::fs::File;
use std::io::Write;
use std::sync::mpsc;
use std::sync::Arc;
use std::thread;

use gcd::euclid_u32;
use itertools::Itertools;

use super::cyclotomic::{sin_cos_table, CyclotomicInteger};

/// Discard a cyclotomic integer, for Lemma 3.11 and function `get_candidates`.
///
/// The main goal of this function is to test whether the input cyclotomic
/// integer has castle > 5.1; if that happens, the function returns `true`.
/// However, it is possible to discard cyclotomic integers depending on other
/// criterion as well; we do it in the process. Doing so greatly improves the
/// total computation time (Rust + Sage).
///
/// Note that the cyclotomic integer is not the only input: we use some
/// `n_values` that merely depend on the corresponding couple (N, n) in the
/// function `get_candidates`. This is simply for convenience and efficiency.
/// 
/// This function is private and only used in `discard_candidates`
/// (plural).
fn discard_candidate(cyclotomic_integer: &CyclotomicInteger,
                     n_values: (u32, u32, u32, u32, u32)) -> bool {

    // Let's create some shorthand notations:
    let l = &cyclotomic_integer.exponents;
    let len = l.len();
    let (NN, N2, N3, N5, N7) = n_values;

    // Remove some cases made redundant by complex conjugation:
    if l[2] + l[len-1] > NN + l[1] {
        return true;
    }
    // Discard cases where two roots of unity differ by a factor of -1:
    for a in 0..len {
        for b in 0..a {
            if l[a] == l[b] + N2 {
                return true;
            }
        }
    }
    // Discard cases where two roots of unity differ by a factor of ζ_3:
    if N3 != 0 {
        for a in 0..len {
            for b in 0..a {
                if    l[a] == l[b] + N3
                   || l[a] == l[b] + 2*N3 {
                    return true;
                }
            }
        }
    }
    // Discard cases where three roots of unity differ by factors of ζ_5:
    if N5 != 0 {
        for a in 0..len {
            for b in 0..a {
                if     l[a] > l[b]
                    && (l[a] - l[b]).is_multiple_of(N5) {
                    for c in 0..b {
                        if    l[b] > l[c]
                           && (l[b] - l[c]).is_multiple_of(N5) {
                            return true;
                        }
                    }
                }
            }
        }
    }
    // Discard when castle >= 5.1:
    if !cyclotomic_integer.castle_strictly_less(5.1_f64) {
       return true;
    }
    // Discard cases visibly of form (2) of Cassels's theorem:
    if    len == 3 
       && (   l[2] == N2 - l[1]
           || l[2] == N2 + 2*l[1]
           || (2*l[2]) % NN == N2 + l[1]) {
       return true;
    }
    // Discard cases visibly of form (3) of Cassels's theorem:
    if     N5 != 0
        && len == 4 {
        for (i, i1, i2) in [(1,2,3), (2,1,3), (3,1,2)] {
            if    (l[i] - l[0]).is_multiple_of(N5)
               && (l[i2] - l[i1]).is_multiple_of(N5)
               && l[i] - l[0] != l[i2] - l[i1]
               && l[1] - l[0] + l[i2] - l[i1] != NN {
                return true;
            }
        }
    }
    // Discard cases where four roots of unity differ by factors of ζ_7:
    if N7 != 0 {
        for a in 0..len {
            for b in 0..a {
                if    l[a] > l[b]
                   && (l[a] - l[b]).is_multiple_of(N7) {
                    for c in 0..b {
                        if     l[b] > l[c]
                            && (l[b] - l[c]).is_multiple_of(N7) {
                            for d in 0..c {
                                if    l[c] > l[d]
                                   && (l[c] - l[d]).is_multiple_of(N7) {
                                    return true;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    // If the cyclotomic integer has not been discarded, then we keep it for
    // further inspection:
    false
}

/// Get candidates from Lemma 3.11.
///
/// The logical input of this function is the couple (N, n), as in Lemma 3.11.
/// The goal of this function is twofold:
///
/// 1. Generate all exponents/indices (and therefore, all cyclotomic integers)
///    that we have two check, according to the list conditions from the
///    beginning of the lemma;
///
/// 2. For each such generated cyclotomic integer, we discard it if its castle
///    is >= 5.1 using the `discard_cyclotomic_integer` function. If the
///    cyclotomic integer is not discarded by `discard_cyclotomic_integer`, then
///    we keep track of it by storing it in the output file (note that we also
///    store the computed sin-cos table).
///
/// To speed up computation, we use multi-threading: this is done with
/// `std::Thread`. We make sure that only one sin-cos table is stored in memory
/// (each thread would want its own copy); this is done using `std::Arc`.
///
/// This function is public and called on all eight values (N, n) given in the
/// statement of Lemma 3.11; this is done in the `main` function (`main.rs`
/// file).
pub fn get_candidates(N: u32, n: usize, mut file_tables: &File, mut file_output: &File) {

    let NN = if N.is_multiple_of(2) {N} else {2*N};
    let N2 = NN/2;
    let N3 = if NN%3 == 0 {NN/3} else {0};
    let N5 = if NN%5 == 0 {NN/5} else {0};
    let N7 = if NN%7 == 0 {NN/7} else {0};

    // Generate and output a table of cosines and signs.
    let sin_cos_table = sin_cos_table(NN);
    for j in 0..NN {
        let (sin, cos) = sin_cos_table[j as usize];
        // Would be better to output sin, cos, in that order...
        writeln!(file_tables, "{} {} {} {}", NN, j, cos, sin).expect("output failure");
    }
    let sin_cos_table_arc = Arc::new(sin_cos_table);

    let mut outputs: Vec<Output> = vec![];

    // Loop over proper divisors j_2 of NN.
    for j2 in (1..NN).filter(|x| NN % x == 0) {
        // Loop over tuples [j_3, ..., j_*] with 0 <= j_3 <= ... <= j_len < NN,
        // also requiring that gcd(j_i, NN) >= j_2.
        // The variable len is defined thereafter, and is less or equal to n.
        let (tx, rx) = mpsc::channel();
        for j3 in (0..NN).filter(|x| euclid_u32(*x, NN) >= j2) {
            let tx_clone = tx.clone();
            // Use Arc cloning to make a new reference to the tables.
            // The point is that this points to the *same* underlying memory.
            let sin_cos_table_local = Arc::clone(&sin_cos_table_arc);
            thread::spawn(move || {
                for len in 3..=n {
                    let mut exponents: Vec<u32> = vec![0; len];
                    exponents[0..3].copy_from_slice(&[0, j2, j3]);
                    for iter in (j3..NN).filter(|x| (j2 == 1) || euclid_u32(*x, NN) >= j2)
                                        .combinations_with_replacement(len-3) {
                        exponents[3..].copy_from_slice(&iter);
                        let cyclotomic_integer = CyclotomicInteger{ exponents: &exponents,
                                                                    level: NN,
                                                                    sin_cos_table: &sin_cos_table_local};
                        // Record this case in case it has not been discarded:
                        if !discard_candidate(&cyclotomic_integer, (NN, N2, N3, N5, N7)) {
                            tx_clone.send(exponents.clone()).unwrap();
                        }
                    }
                }
                println!("Checked cases with n = {}, j_2 = {}, j_3 = {}", NN, j2, j3);
              });
        }

        // Record the level and exponents from all spawned threads
        drop(tx);
        for exponents in rx {
            println!("{:?}", exponents);
            let output = Output { level: NN, exponents };      
            outputs.push(output);
        }
    }
    
    println!("All cyclotomic integers collected");
    println!("Sorting them now...");
    outputs.sort();
    println!("Sorted!");
    for output in outputs {
        let NN = output.level;
        let exponents = output.exponents;
        writeln!(file_output, "{}; {:?}", NN, exponents).expect("output failure");
    }

}

/// Order cyclotomic integers.
///
/// The goal of this struct is simply to create a data structure for the datum
/// of a level and a vector of exponents, which we use to derive a "canonical"
/// (in the sense of Rust trait derivation) ordering for the candidates found by
/// `get_candidates`. This allows to order the candidates in the output file,
/// despite the multiple threads returning candidates in no particular order.
#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]
struct Output {
    level: u32,
    exponents: Vec<u32>
}
