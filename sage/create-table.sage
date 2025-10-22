## Build a data structure that reflects Table 1.

load('utils.sage')

P.<x> = QQ[]

TABLE_RAW_FACTORED = [
    (11, (1+x+x^2+x^4-x^5+x^7,), 1),
    (19, (1+x+x^4+x^7+x^8+x^9+x^10+x^12+x^14,), 1),
    (20, (1+x+x^3-x^4,), 1),
    (24, (1+x+x^5-x^6,), 1),
    (31, (1+x+x^3+x^8+x^12+x^18,), 1),
    (51, (1+x^3-x^10+x^15+x^21+x^24+x^30+x^33+x^39,), 1),
    (84, (1-x^4-x^13-x^16+x^19+x^21+x^22+x^31,), 1),
    (91, (1+x^7+x^14-x^17+x^21+x^42-x^69+x^70-x^82,), 1),
    (33, (1+x^6-x^8+x^21,), 33),
    (28, (1+x-x^3-x^11,), 28),
    (33, (1+x^6-x^7-x^10,), 22),
    (21, (1-x-x^5+x^18,), 21),
    (28, (1+x-x^3+x^4,), 14),
    (21, (1-x+x^6+x^18,), 'a'),
    (60, (1-x^3-x^6-x^8,), 12),
    (11, (1+x+x^2+x^5,), 11),
    (35, (1-x^6+x^7+x^10+x^15+x^17+x^22,), 10),
    (40, (1-x^3+x^7+x^10,), 10),
    (60, (1-x^3-x^5-x^8,), 10),
    (24, (1+x+x^7,), 8),
    (13, (1+x+x^4,), 'a'),
    (21, (1-x-x^4+x^12,), 7),
    (7,  (1+x+x^3, 1+x+x^3), 6),
    (28, (1+x^7, 1+x^4+x^12), 6),
    (39, (1-x^2-x^5-x^8-x^11-x^20-x^32,), 6),
    (55, (1-x-x^16+x^22-x^26-x^31-x^36,), 6),
    (60, (1+x^15, 1-x^4+x^48), 6),
    (105, (1+x^15+x^45, 1-x^7+x^84), 6),
    (21, (1-x-x^13,), 'b'),
    (11, (1+x+x^2+x^4+x^7,), 4),
    (13, (1+x+x^3+x^9,), 4),
    (35, (1-x+x^7-x^11-x^16,), 4),
    (7, (1+x+x^3,), 3)
]

TABLE_RAW = [(N, prod(i), m) for N, i, m in TABLE_RAW_FACTORED]

def table_hashes(table):
    cyc_integers = []
    for N, pol, m in table:
        K.<z> = CyclotomicField(N)
        c = pol(z)
        cyc_integers.append(c)
        ## Verify that the castle is as claimed
        if m == 'a':
            K1.<s> = QuadraticField(N)
            t = (5+s)/2
        elif m == 'b':
            K1.<z1> = CyclotomicField(14)
            t = 2+z1+~z1
        else: 
            K1.<z1> = CyclotomicField(m)
            t = 3+z1+~z1
        assert (c*c.conjugate()).minpoly()(t) == 0
        ## Verify that the minimal level is as claimed
        assert minimal_level(c) == N
        ## Verify that this is an exceptional case in the Cassels classification
        assert not is_cassels_form(c)
    return map(cyclotomic_hash, cyc_integers)