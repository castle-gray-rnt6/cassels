# The exceptional set in Cassels's theorem on small cyclotomic integers

This repository is associated to the paper _The exceptional set in Cassels's
theorem on small cyclotomic integers_ by Jitendra Bajpai, Srijan Das, Kiran S.
Kedlaya, Nam H. Le, Meghan Lee, Antoine Leudière, and Jorge Mello.

## Overview of the code

### Rust

The folder [`rust`](rust/) contains a Rust program (`cassels` executable) to
perform an exhaustive search for cyclotomic integers with small castle, as
cited in Lemma 3.11. All instructions are in the [README](rust/README.md) of
the folder.

### SageMath and Jupyter notebooks

We also rely on SageMath for exact computations (folder [`sage`](sage/)).
The following Jupyter notebooks use the SageMath kernel (tested using version
10.6):

- [`check-table-1.ipynb`](sage/check-table-1.ipynb): Verify that the output of
the Rust code is consistent with Table 1. Cited in Lemma 3.11.

- [`combinatorics.ipynb`](sage/combinatorics.ipynb): Check some assertions
about difference sets of some finite subsets of $\mathbb{Z}/n\mathbb{Z}$. Cited
in Lemma 5.1, Lemma 5.2, and Lemma 5.3.

- [`corollary-4.5.ipynb`](sage/corollary-4.5.ipynb): Use cyclotomic hashes to
compare values produced by Theorem 1 with Robinson's Conjecture 1. Cited in
Corollary 4.5.

- [`floating-point.ipynb`](sage/floating-point.ipynb): Verify the numerical
accuracy of the floating-point approximations of sines and cosines used in the
Rust code. Cited in Lemma 3.11.

These notebooks in turn depend on the following SageMath code files:

- [`create-table.sage`](sage/create-table.sage): Create a data structure
reflecting Table 1. This code also verifies a claim about minimal levels made
in Remark 3.3.

- [`parse_cyclotomic_integer_exponents.sage`](sage/parse_cyclotomic_integer_expoents.sage):
Parse the output of the Rust code (see below) to generate cyclotomic integers
in SageMath.

- [`utils.sage`](sage/utils.sage): Implement various utility functions
described in section 3.
