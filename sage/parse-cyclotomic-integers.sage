def parse_cyclotomic_integers(path):
    """
    Read from a file (e.g. `output.txt`) and return a list of SageMath
    objects representing cyclotomic integers. Each line in the file is
    of the form:
        level; [n1, n2, ..., nx]
    """
    with open(path, 'r') as f:
        data = f.readlines()
        data_parsed = set()
        for line in data:
            level_split = line.split(";")

            level = Integer(level_split[0].strip())

            # Clean up the exponent list string
            exponents_str = level_split[1].strip()
            exponents_str = exponents_str.replace("[", "").replace("]", "")
            exponent_list = [Integer(e.strip()) for e in exponents_str.split(",") if e.strip()]

            # Remove common factors, then record the result if it is new
            d = gcd(exponent_list + [level])
            level = level // d
            exponent_list = [i // d for i in exponent_list]
            data_parsed.add((level, tuple(exponent_list)))

    cyc_integers = []
    for (level, exponent_tuple) in data_parsed:
        K = CyclotomicField(level)
        z = K.gen()

        # Build the cyclotomic integer (excluding exponents == level)
        summands = [z**e for e in exponent_tuple if e != level]
        expression = sum(summands)
        cyc_integers.append(expression)
    return cyc_integers
