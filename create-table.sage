## Build a data structure that reflects Table 1.

load('utils.sage')

P.<x> = QQ[]

TABLE_RAW_FACTORED = [
    (11, (1+x+x^2+x^4-x^5+x^7,)),
    (19, (1+x+x^4+x^7+x^8+x^9+x^10+x^12+x^14,)),
    (20, (1+x+x^3-x^4,)),
    (24, (1+x+x^5-x^6,)),
    (31, (1+x+x^3+x^8+x^12+x^18,)),
    (51, (1+x^3-x^10+x^15+x^21+x^24+x^30+x^33+x^39,)),
    (84, (1-x^4-x^13-x^16+x^19+x^21+x^22+x^31,)),
    (91, (1+x^7+x^14-x^17+x^21+x^42-x^69+x^70-x^82,)),
    (33, (1+x^6-x^8+x^21,)),
    (28, (1+x-x^3-x^11,)),
    (33, (1+x^6-x^7-x^10,)),
    (21, (1-x-x^5+x^18,)),
    (28, (1+x-x^3+x^4,)),
    (21, (1-x+x^6+x^18,)),
    (60, (1-x^3-x^6-x^8,)),
    (11, (1+x+x^2+x^5,)),
    (35, (1-x^6+x^7+x^10+x^15+x^17+x^22,)),
    (40, (1-x^3+x^7+x^10,)),
    (60, (1-x^3-x^5-x^8,)),
    (24, (1+x+x^7,)),
    (13, (1+x+x^4,)),
    (21, (1-x-x^4+x^12,)),
    (7,  (1+x+x^3, 1+x+x^3)),
    (28, (1+x^7, 1+x^4+x^12)),
    (39, (1-x^2-x^5-x^8-x^11-x^20-x^32,)),
    (55, (1-x-x^16+x^22-x^26-x^31-x^36,)),
    (60, (1+x^15, 1-x^4+x^48)),
    (105, (1+x^15+x^45, 1-x^7+x^84)),
    (21, (1-x-x^13,)),
    (11, (1+x+x^2+x^4+x^7,)),
    (13, (1+x+x^3+x^9,)),
    (35, (1-x+x^7-x^11-x^16,)),
    (7, (1+x+x^3,))
]

TABLE_RAW = [(N, prod(i)) for N, i in TABLE_RAW_FACTORED]

def table_hashes(table):
    cyc_integers = []
    for N, pol in table:
        K.<z> = CyclotomicField(N)
        c = pol(z)
        cyc_integers.append(c)
        assert minimal_level(c) == N
        c = c/c.conjugate()
        if N != 28 and N != 60:
            assert c.multiplicative_order() < Infinity or minimal_level(c) == N
    return map(cyclotomic_hash, cyc_integers)