# Walkthrough our code

- TODO: Add TOC with https://github.com/jonschlinkert/markdown-toc
- TODO: Search for all instances of "TODO" and eliminate them
- TODO: Rename `loop_over_roots` to `skip_cyclotomic_integers` or `filter_cyclotomic_integers`? Change this README accordingly

## Rust

### Run our code

[Rust](https://www.rust-lang.org/) is a programming language made by Mozilla
targeting safety and speed. We use it for the heavy computations of our
project.

Contrary to SageMath or Python, Rust is a _compiled language_. This means that
to run our code, one first needs to _compile_ the source code. Assuming Rust
[is already installed on your
machine](https://www.rust-lang.org/tools/install), instructions are as follows:

```bash
git clone TODO REPO_URL
cd TODO 
cargo build --release
cd target/release  # Go to the directory of the executable
./cassels          # Run our program
```

### Explanation of the `rust` folder

We have three main files:

- In `cyclotomic.rs` we create a _struct_ `CyclotomicInteger` to represent our
cyclotomic integers. Its only method of interest is `castle_strictly_less`,
which asserts whether or not the castle of the cyclotomic integer is strictly
less or not than an input cutoff. 
- In `cassels.rs` we use the public functions from `cyclotomic.rs` to create a
function `loop_over_roots`, responsible for filtering out cyclotomic integers
that are classified under item (1), (2) or (3) of Cassels' theorem (theorem 1.1
in our paper).
- In `main.rs`, we call `loop_over_roots` over an explicit list of cyclotomic
integers. Among those, we obtain candidates that are not covered under the
three aforementioned items.

The code generates two output files `tables.txt` and `output.txt` which provide 
some data to SageMath for exact computations; see below.

## SageMath

In the parent directory, we have two Jupyter notebooks running SageMath which refer to
the output of the Rust program. The proof of Lemma 3.11 in the paper is logically dependent
on the correctness of both the Rust and SageMath code.

In `floating-point.ipynb`, we verify that the floating-point sines and cosines used in 
the Rust code are each valid to within 10^-14. This data is read in from the file `tables.txt`, 
each line of which has the form `N j c s` where `c` and `s` are the Rust approximations of 
the cosine and sine of $2\pi j/N$.

In `check-table-ipynb`, we verify that each cyclotomic integer output by the Rust code
is consistent with Theorem 1.2; that is, either its castle is greater than 5.1, it belongs to
one of the infinite families (1), (2), (3) of Theorem 1.1, or it is equivalent to an entry of
Table 1. This data is read in from the file `output.txt`, each line of which has the form 
`N; [j_1, ..., j_n]` representing $\sum_{i=1}^n e^{2 \pi j_i/N}$.
