#include "family.h"

int qrp::SeedCompany::sLastId = 0;
int qrp::Family::sLastId = 0;
int qrp::Crop::sLastId = 0;
int qrp::Variety::sLastId = 0;

const QHash<int, QByteArray> qrp::Variety::sRoleNames = {
    { Role::r_name, "variety" },
    { Role::r_id, "variety_id" },
    { Role::r_deleted, "deleted" },
    { Role::r_isDefault, "is_default" },
    { Role::r_seedCompanyId, "seed_company_id" },
    { Role::r_seedCompanyName, "seed_company_name" },
};

int qrp::Family::row(int crop_id) const
{
    int r = 0;
    for (Crop *crop : crops) {
        if (crop->id == crop_id)
            return r;
        ++r;
    }
    return -1;
}

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
