def parse_cyclotomic_integer_exponents(path):
    """
    Read from a file (e.g. `output.txt`) and return a list of SageMath objects
    representing cyclotomic integers.
    
    Each line in the file is of the form:
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

def parse_cyclotomic_integer_exponents_V2(path):
    """
    Read from a file (e.g. `output.txt`) and return a list of SageMath objects
    representing cyclotomic integers.
    
    Each line in the file is of the form:
        level; [n1, n2, ..., nx]
    """
    cyc_integers = []

    cached_integers = dict()
    cached_fields = dict()
    P.<x> = QQ[]

    with open(path, 'r') as f:
        data = f.readlines()
        for line in data:
            level_split = line.split(";")

            # Get the cyclotomic field
            level = Integer(level_split[0].strip())
            if level in cached_fields:
                K = cached_fields[level]
            else:
                K = CyclotomicField(level)
                print(level)
                cached_fields[level] = K

            # Get zeta
            zeta = K.gen()

            # Clean up the exponent list string
            exponents_str = level_split[1].strip()
            exponents_str = exponents_str.replace("[", "").replace("]", "")
            exponents = [Integer(e.strip()) for e in exponents_str.split(",") if e.strip()]

            # Build the cyclotomic integer for this line
            # For each exponent, check if zeta^exponent has been
            # computed already. If yes, it is stored in cached_integers[level],
            # and we can use it directly; else, we compute it, store it, and
            # use it.
            cyc_integer = K(0)

            if not level in cached_integers:
                cached_integers[level] = dict()

            for exponent in filter(lambda e: e != level, exponents):
                if exponent not in cached_integers[level]:
                    cached_integers[level][exponent] = zeta^exponent
                cyc_integer += cached_integers[level][exponent] 
            
            cyc_integers.append(cyc_integer)

    return cyc_integers


# filter(lambda a:is_cassels_form(a) == False, parse_cyclotomic_integer_exponents())

## # OLD FUNCTIONS
## def parse_cyclotomic_integer_exponents_v1(text, level):
##     # Parses text of exponent vectors into sums
##     # of powers of zeta_n, where n is the level.
##     # Example line: [1, 2, 140, 281, 420, 420]
##     
##     K = CyclotomicField(level)
##     z = K.gen()
##     expressions = []
##     
##     for line in text.strip().splitlines():
##         exponents = eval(line.strip())
##         # Skip any exponent that is equal to n,
##         # since we use n as a proxy for a zero
##         # summand in main.rs
##         summands = [z^e for e in exponents if e != level]
##         # Summing all terms
##         expression = sum(summands)
##         expressions.append(expression)
##         
##     return expressions
## 
## def parse_cyclotomic_integer_exponents_v2(text):
## 
##     """
##     Parses text of exponent vectors into sums of powers of zeta_n, where n is the level.
##     Returns the list of cyclotomic integers.
##     """
##     cyc_integer_list = []
##     counter = 0  # Initialize counter
## 
##     for line in text.strip().splitlines():
##         line = line.strip()
##         if not line:
##             continue  # Skip empty lines
## 
##         # Split into level and exponent list
##         level_split = line.split(";")
## 
##         level = Integer(level_split[0].strip())
##         K = CyclotomicField(level)
##         z = K.gen()
## 
##         # Clean up the exponent list string
##         exponents_str = level_split[1].strip()
##         exponents_str = exponents_str.replace("[", "").replace("]", "")
##         exponent_list = [Integer(e.strip()) for e in exponents_str.split(",") if e.strip()]
## 
##         # Build the cyclotomic integer (excluding exponents == level)
##         summands = [z**e for e in exponent_list if e != level]
##         expression = sum(summands)
##         cyc_integer_list.append(expression)
## 
##     return cyc_integer_list