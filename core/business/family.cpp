#include "family.h"

int qrp::Crop::row(int variety_id) const
{
    int r = 0;
    for (Variety *variety : varieties) {
        if (variety->id == variety_id)
            return r;
        ++r;
    }
    return -1;
}
