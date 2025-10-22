import itertools

def minimal_level(a, with_zeta=False):
    """
    INPUT:
        - A cyclotomic integer.
        - TYPE: Same type as that of an element in
          `CyclotomicField(n).ring_of_integers()`.
    OUTPUT:
        - The minimal level of the input.
        - If `with_zeta` is set, also return a root of unity (in the
          parent of the input)
        - TYPE: Integer.
    """
    # Create some objects:
    K = a.parent().fraction_field()
    # TODO: What is the cost of the conductor computation?
    N = K.conductor()
    roots = K.roots_of_unity()

    # Captain obvious
    if a in QQ:
        return (1, K(1)) if with_zeta else 1

    # Outer loop: prime factors p of N:
    for p, _ in factor(N):
        d = N//4 if (p == 2 and N%8 == 4) else N//p
        Kd = CyclotomicField(d)
        # Inner loop: roots of unity
        for zeta in roots[:p]:
            # TODO: Check how Sage does this membership test
            if zeta * a in Kd:
                # Reduce the level and recurse
                ans = minimal_level(Kd(zeta * a), with_zeta)
                return (ans[0], K(ans[1])*zeta) if with_zeta else ans
    # If none of the above, then N
    return (N, K(1)) if with_zeta else N


def are_equivalent(a, b):
    """
    INPUT:
        - Two cyclotomic integers.
        - TYPE: Each input has the same type as that of an element in
          `CyclotomicField(n).ring_of_integers()`.
    OUTPUT:
        - TYPE: boolean.
    """

    # Test the respective levels of a and b:
    min_level1, z1 = minimal_level(a, with_zeta=True)
    min_level2, z2 = minimal_level(b, with_zeta=True)
    if min_level1 != min_level2:
        return False

    # If they have the same minimal level, build a representation with
    # respect to it:
    K_min = CyclotomicField(min_level1)
    a_min = K_min(a*z1)
    b_min = K_min(b*z2)

    # Compare the minimal polynomials:
    minpoly = a_min.minpoly()
    roots = K_min.roots_of_unity()
    # could also write: 
    # return any((zeta * b_min).minpoly() == minpoly for zeta in roots)
    for zeta in roots:
        if (zeta * b_min).minpoly() == minpoly:
            return True
    return False


def cassels_height(a):
    """
    INPUT:
        - A cyclotomic integer.
        - TYPE: Same type as that of an element in
          `CyclotomicField(n).ring_of_integers()`.
    OUTPUT:
        - The Cassels height of the input.
        - TYPE: Integer.
    """
    return (a*a.conjugate()).trace() / a.parent().degree()

def cyclotomic_hash(a):
    """
    INPUT:
        - A cyclotomic integer.
        - TYPE: Same type as that of an element in
          `CyclotomicField(n).ring_of_integers()`.
    OUTPUT:
        - The minimal level of the input, and the minimal polynomial of
          a "canonical" representative of the equivalence class.
        - TYPE: Integer; polynomial with integer coefficients.
    """
    # Force a into minimal level
    N, z0 = minimal_level(a, with_zeta=True)
    K.<z> = CyclotomicField(N)
    b = K(a*z0)
    # Minimize the degree of the minimal polynomial, breaking ties in
    # favor of the lexicographically earlier polynomial (with
    # coefficients read from highest order to lowest order).
    d = None
    roots = K.roots_of_unity()
    for zeta in roots:
        pol = (b*zeta).minpoly()
        if (
            (d is None)
            or (pol.degree() < d.degree())
            or (pol.degree() == d.degree() and list(pol.reverse()) < list(d.reverse()))
        ):
            d = pol
    return N, d

def is_cassels_form(a, hash0=None):
    """
    INPUT:
        - A cyclotomic integer.
        - TYPE: Same type as that of an element in
          `CyclotomicField(n).ring_of_integers()`.
    OUTPUT:
        - True if the input appears in one of Cassels's infinite families.
        - TYPE: Boolean.
    """
    # Test whether a is a sum of at most two roots of unity.
    K = a.parent()
    roots = K.roots_of_unity()
    if (
            a == 0
            or a.multiplicative_order() < Infinity
            or any((a - z).multiplicative_order() < Infinity for z in roots)
        ):
       return True

    # Test whether the castle of a has the right form for one of the
    # other Cassels families.
    u = a*a.conjugate()
    P.<z> = K[]
    l = (z^2 + (u-3)*z + 1).roots(K)
    if len(l) == 0:
        return False
    z1 = l[0][0]
    if z1.multiplicative_order() == Infinity:
        return False
    # Test whether a is equivalent to 1 + z2 - 1/z2 for z2 = sqrt(z1).
    hash1 = cyclotomic_hash(a) if hash0 is None else hash0
    _, z2 = z1.is_square(root=True)
    if _ and hash1 == cyclotomic_hash(1+z2-1/z2):
        return True
    # Test whether a is equivalent to (z5+z5^4) + (z5^2+z5^3)*z1.
    K5.<z5> = CyclotomicField(5)
    if hash1[0] % 5 == 0 and hash1 == cyclotomic_hash((z5+z5^4) + (z5^2+z5^3)*z1):
        return True
    return False

def cassels_form_filter(cyclotomic_integer_list):
    """
    INPUT: A list of cyclotomic integers.
    OUTPUT: A list of those elements which do not appear in one of
    Cassels's infinite families.
    """
    filtered = []
    
    for a in cyclotomic_integer_list:
        if not is_cassels_form(a):
            filtered.append(a)
    return filtered

def castle_below_cutoff(a, c):
    """
    INPUT: A cyclotomic integer and a rational number.
    OUTPUT: True if and only if the castle of a is at most c.
    """
    u = a*a.conjugate()
    pol = u.minpoly()
    return all(i <= c for i, _ in pol.roots(AlgebraicRealField()))

def minimal_weight(a):
    """
    INPUT: A cyclotomic integer a.
    OUTPUT: The minimum number of roots of unity that sum to a.
    """
    if a in QQ:
        return ZZ(a).abs()
    N, zeta = minimal_level(a, True)
    K.<z> = CyclotomicField(N)
    b = K(a*zeta)
    if b in QQ: # Don't sweat the easy stuff
        return ZZ(b).abs()
    pol = b.polynomial()
    # If the minimal level is not squarefree, split over the largest
    # prime with a repeated factor, then recurse.
    if not N.is_squarefree():
        tmp = [p for p, i in N.factor() if i > 1]
        p = tmp[-1]
        K1.<z1> = CyclotomicField(N//p)
        coeffs = [K1(0) for _ in range(p)]
        N1 = N//p^N.valuation(p)
        _, j, k = xgcd(N1, p)
        for i in range(pol.degree()+1):
            coeffs[(j*i)%p] += pol[i]*z1^(k*i+(j*i)//p*N1)
        return sum(minimal_weight(i) for i in coeffs)

    # If the minimal level is squarefree, try splitting over a prime p
    # to see if we get fewer than p/2 summands. If so, recurse.
    for p, _ in reversed(N.factor()):
        K1.<z1> = CyclotomicField(N//p)
        coeffs = [K1(0) for _ in range(p)]
        _, j, k = xgcd(N//p, p)
        for i in range(pol.degree()+1):
            coeffs[(j*i)%p] += pol[i]*z1^(k*i)
        for j in coeffs:
            if sum(1 for i in coeffs if i-j) < p/2:
                return sum(minimal_weight(i-j) for i in coeffs)
    roots = K.roots_of_unity()
    # First check the power basis representations of b times a root of
    # unity.
    nmin = Infinity
    for zeta in roots:
        nmin = min(nmin, sum(i.abs() for i in (b*zeta).polynomial().list()))
    n = 0
    while n < nmin:
        for i in itertools.combinations_with_replacement(roots, n):
            if a == sum(i):
                return n
        n += 1
    return n

#########
# TESTS #
#########

def test():

    # Some fields and rings
    K6.<z6> = CyclotomicField(6)
    R6 = K6.ring_of_integers() 
    K8.<z8> = CyclotomicField(8)
    R8 = K8.ring_of_integers() 
    K11.<z11> = CyclotomicField(11)
    R11 = K11.ring_of_integers() 

    # Minimal level
    assert minimal_level(K11(1)) == 1
    assert minimal_level(K11(-1)) == 1
    assert minimal_level(K8(i)) == 1  # And not 4!
    for root in K8.roots_of_unity():
        assert minimal_level(root) == 1
    # TODO: Hand compute the result for z6

    # Equivalence
    x = R11.random_element()
    assert are_equivalent(x, z11^2 * x)
    assert cyclotomic_hash(x) == cyclotomic_hash(z11^2 * x)

    # Minimal weight
    K84.<z84> = CyclotomicField(84)
    assert minimal_weight(1-z84^4-z84^13-z84^16+z84^19+z84^21+z84^22+z84^31) == 8
    
test()
