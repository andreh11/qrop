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

qrp::ModelOject::ModelOject(int id_, const QString &n, bool del)
    : id(id_)
    , name(n)
    , deleted(del)
{
}

qrp::ModelOject::~ModelOject() {}

qrp::SeedCompany::SeedCompany(int id_, bool del, const QString &n, bool d)
    : ModelOject(id_, n, del)
    , isDefault(d)
{
}

qrp::Family::Family(int id_, bool del, const QString &n, uint i, const QString &c)
    : ModelOject(id_, n, del)
    , interval(i)
    , color(c)
    , crops()
{
}

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

qrp::Crop::Crop(int id_, bool del, const QString &n, const QString &c, qrp::Family *f)
    : ModelOject(id_, n, del)
    , color(c)
    , family(f)
    , varieties()
{
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

qrp::Variety::Variety(int id_, bool del, const QString &n, bool d, qrp::Crop *c, qrp::SeedCompany *s)
    : ModelOject(id_, n, del)
    , isDefault(d)
    , crop(c)
    , seedCompany(s)
{
}
