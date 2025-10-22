use std::f64::consts::TAU;

use gcd::euclid_u32;

/// Return the vector (sin(j*2π/n), sin(j*2π/n)), for n input and 0 <= j < n.
pub fn sin_cos_table(n: u32) -> Vec<(f64, f64)> {
    let angle0 = TAU / (n as f64);
    // Iterate over j:
    (0..n)
        // Compute sin and cosine of 2*pi*j/n:
        .map(|j| (angle0 * (j as f64)).sin_cos())
        // Collect and return a vector:
        .collect::<Vec<(f64, f64)>>()
}

/// Represent cyclotomic integers.
///
/// The cyclotomic integer is defined by its `level` and its `exponents`. The
/// instance with level n and exponents (j1, ..., jk) this struct represents the
/// cyclotomic integer
///
///   z_n^{j_1} + ... + z_n^{j_k},
///
/// where z_n is the root of unity exp(iπ/n).
///
/// Note that we also attach our cyclotomic integers with a sin-cos table. This
/// table depends only of the level, and does not depend on the exponents.
/// However, having easy access to the table is very convenient for computations
/// related to the castle (method `castle_strictly_less`, which requires
/// `conjugates_abs_squared`, where the table is used to compute the castle of
/// algebraic conjugates). Furthermore, we only store an immutable reference to
/// the table.
pub struct CyclotomicInteger<'a> {

    // A note on "lifetimes": because our instances store references, we must
    // ensure that the references live at least as long as the instances
    // themselves. To do that, one simply declares a so-called "lifetime" for
    // the references. In our case, the lifetime is `a`, and it is used after
    // its declaration on the type annotation of the references we store. Note
    // that the code cannot be compiled without this. More information here:
    // https://doc.rust-lang.org/rust-by-example/scope/lifetime/fn.html.

    pub exponents: &'a Vec<u32>,
    pub level: u32,
    pub sin_cos_table: &'a Vec<(f64, f64)>,
}

impl CyclotomicInteger<'_> {

    /// Iterate through the squares of the modules of the conjugates of the
    /// cyclotomic integer.
    ///
    /// We use `abs` to stick the SageMath convention.
    fn conjugates_abs_squared(&self) -> impl Iterator<Item = f64> {
        // Iterate through the conjugates:
        (1..self.level)
            // First, get the right Galois group automorphisms:
            .filter(|k| euclid_u32(*k, self.level) == 1)
            // Second, compute the square of the modulus for this Galois
            // automorphism:
            .map(|k| {
                let mut sin_sum = 0_f64;
                let mut cos_sum = 0_f64;
                for j in self.exponents {
                    let i = (k*j % self.level) as usize;
                    // If only we could sum tuples directly...
                    let (sin, cos) = self.sin_cos_table[i];
                    sin_sum += sin;
                    cos_sum += cos;
                }
                // Yield the square of the modulus (the function returns an
                // iterator!):
                sin_sum.powi(2) + cos_sum.powi(2)
            })
    }

    /// Check whether castle is bounded above by the cutoff.
    ///
    /// This is more efficient than computing the house first. N.b.: this
    /// function could be merged with the previous one; we chose to keep it for
    /// users to freely experiment with our code!
    pub fn castle_strictly_less(&self, cutoff: f64) -> bool {
        !self.conjugates_abs_squared().any(|x| x >= cutoff)
    }
}

// For idiomatic doctesting, see
// https://doc.rust-lang.org/rust-by-example/testing/unit_testing.html
// Basically, add tests in the module below, prefix with #[test], and run `cargo
// test`.

#[cfg(test)]
mod tests {

    use super::*;

    fn float_equality(x: f64, y: f64) -> bool {
        (x - y).abs() < (0.000001_f64)
    }

    #[test]
    fn test_castle() {
        // Tests for CyclotomicInteger

        // This is necessary as otherwise there is a conflict between the variable sin_cos_table,
        // and the function. This is called shadowing, see `rustc --explain E0618`.
        let sin_cos_table_fn = sin_cos_table;

        // Test 1
        // Randomly taken from SageMath
        let sin_cos_table = sin_cos_table_fn(7);
        let l = vec![0, 1, 3, 5];
        let ex1 = CyclotomicInteger{ exponents: &l,
                                              level: 7,
                                              sin_cos_table: &sin_cos_table
        };
        let sage_res1 = 5.04891733952231_f64;
        // assert!(float_equality(ex1.house_squared(), sage_res1));
        assert!(ex1.castle_strictly_less(sage_res1+0.000001));
        assert!(!ex1.castle_strictly_less(5_f64));

        // Test 2
        // Taken from table 1 of Kiran's notes
        let sin_cos_table = sin_cos_table_fn(31);
        let l = vec![0, 1, 3, 8, 12, 18];
        let ex2 = CyclotomicInteger{ exponents: &l,
                                              level: 31,
                                              sin_cos_table: &sin_cos_table
        };
        // assert!(float_equality(ex2.house_squared(), 5_f64));
        assert!(ex2.castle_strictly_less(5.000001_f64));

        // Test 3
        // Taken from table 1 of Kiran's notes
        let sin_cos_table = sin_cos_table_fn(70);
        let l = vec![0, 1, 11, 42, 51];
        let ex3 = CyclotomicInteger{ exponents: &l,
                                              level: 70,
                                              sin_cos_table: &sin_cos_table
        };
        // assert!(float_equality(ex3.house_squared(), 3_f64));
        assert!(ex3.castle_strictly_less(3.000001_f64));
        assert!(!ex3.castle_strictly_less(2.999999_f64));

        // Test 4
        // i (imaginary unit)
        let sin_cos_table = sin_cos_table_fn(4);
        let l = vec![1];
        let ex4 = CyclotomicInteger{ exponents: &l,
                                              level: 4,
                                              sin_cos_table: &sin_cos_table
        };
        // assert_eq!(ex4.house_squared(), 1_f64);

        // Test 5
        // 1+i (imaginary unit)
        let sin_cos_table = sin_cos_table_fn(4);
        let l = vec![0, 1];
        let ex5 = CyclotomicInteger{ exponents: &l,
                                              level: 4,
                                              sin_cos_table: &sin_cos_table
        };
        // assert_eq!(ex5.house_squared(), 2_f64);
    }
}
