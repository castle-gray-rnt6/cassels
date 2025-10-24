# The exceptional set in Cassels's theorem on small cyclotomic integers

This repository is associated to the paper _The exceptional set in Cassels's
theorem on small cyclotomic integers_
([arXiv](https://arxiv.org/abs/2510.20435)) by Jitendra Bajpai, Srijan Das,
Kiran S. Kedlaya, Nam H. Le, Meghan Lee, Antoine Leudière, and Jorge Mello.

We solve a Number Theory conjecture related to the classification of "small"
_cyclotomic integers_. The conjecture was stated by Raphael M. Robinson in his
1965 paper [_Some conjectures about cyclotomic
integers_](https://doi.org/10.1090/S0025-5718-1965-0180545-X). Our approach
involves both theoretical work and efficient computation in the Rust
programming language.

## Overview of the code

### Rust

The folder [`rust`](rust/) contains a Rust program (`cassels` executable) to
perform an exhaustive search for cyclotomic integers with small castle, as
cited in Lemma 3.11. We use floating-point arithmetic (double precision).
Compile instructions as well as some basic explanations are given in the
[README](rust/README.md) of the folder.

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

- [`parse-cyclotomic-integers.sage`](sage/parse-cyclotomic-integers.sage):
Parse the output of the Rust code (see below) to generate cyclotomic integers
in SageMath.

- [`utils.sage`](sage/utils.sage): Implement various utility functions
described in section 3.

## Who we are

We are the team _Castle Gray_ team of the [Rethinking Number
Theory](https://sites.google.com/view/rethinkingnumbertheory/) workshop (sixth
edition). Our members are:
- [Jitandra Bajpai](https://user.math.uni-kiel.de/~jitendra/)
- [Srijan Das](https://sites.google.com/view/srijans-homepage/home?authuser=0)
- [Kiran S. Kedlaya](https://kskedlaya.org/) (project leader)
- [Nam H. Le](https://hoainam-le.github.io/)
- [Meghan Lee](https://meghanhlee.github.io/)
- [Antoine Leudière](https://cspages.ucalgary.ca/~antoine.leudiere1/)
- [Jorge Mello](https://www.jorgemello.org/)

This edition (Edition 6) of Rethinking Number Theory is organized by:

- [Jen Berg](https://sites.google.com/view/jenberg/home)
- [Heidi Goodson](https://sites.google.com/site/heidigoodson/)
- [Allechar Serrano López](https://www.allechar.org/)
