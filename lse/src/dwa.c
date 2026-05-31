#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

typedef enum {
    APLNCHAR = 0,
    APLBOOL = 1,
    APLSINT = 2,
    APLINTG = 3,
    APLLONG = 4,
    APLDOUB = 5,
    APLPNTR = 6,
    APLWCHAR8 = 7,
    APLWCHAR16 = 8,
    APLWCHAR32 = 9,
    APLCMPX = 10,
    APLRATS = 11,
    APLDECF_DPD = 12,
    APLQUAD = 13,
    APLDECF_BID = 14,
    NELTYPES = 15
} apl_eltype_t;

#define DATA(pp) ((void*)&(pp)->shape[(pp)->rank])

typedef struct pocket {
    long long length;
    long long refcount;
    unsigned int type : 4;
    unsigned int rank : 4;
    unsigned int eltype : 4;
    unsigned int _0 : 13;
    unsigned int _1 : 16;
    unsigned int _2 : 16;
    long long shape[1];
} pocket_t;

typedef struct localp {
    struct pocket* pocket;
    void* i;
} localp_t;

int DyalogGetInterpreterFunctions(void* p) { return 0; }

void LSE_CopyAsBytesOnto(uint8_t* dst, localp_t* lp, int32_t type) {
    pocket_t* p = lp->pocket;
    if (type != 163) {
        printf("Passed too big big ");
        assert(1 == 0);
    }
    if (p->rank != 1) {
        printf("Flat of rank 1 plz");
        assert(1 == 0);
    }
    size_t len = p->shape[0];
    int16_t* buf = DATA(lp->pocket);

    for (size_t i = 0; i < len; i++) {
        dst[i] = buf[i];
    }
}