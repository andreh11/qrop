#ifndef QRP_FAMILY_H
#define QRP_FAMILY_H
#include <QtGlobal>
#include <QString>
#include <QList>

namespace qrp {

struct Crop;
struct Variety;

struct SeedCompany {
    int id;
    QString name;
    bool isDefault;
    SeedCompany(int id_, const QString &n, bool d)
        : id(id_)
        , name(n)
        , isDefault(d)
    {
    }
};

struct Family {
    int id;
    QString name;
    uint interval;
    QString color;
    QList<Crop *> crops;

    Family(int id_, const QString &n, uint i, const QString &c)
        : id(id_)
        , name(n)
        , interval(i)
        , color(c)
        , crops()
    {
    }

    void addCrop(Crop *c) { crops << c; }

    Crop *crop(int row) const
    {
        if (row >= crops.size())
            return nullptr;
        return crops.at(row);
    }
};

struct Crop {
    int id;
    QString name;
    QString color;
    Family *family;
    QList<Variety *> varieties;
    Crop(int id_, const QString &n, const QString &c, Family *f)
        : id(id_)
        , name(n)
        , color(c)
        , family(f)
        , varieties()
    {
    }

    void addVariety(Variety *v) { varieties << v; }

    Variety *variety(int row) const
    {
        if (row >= varieties.size())
            return nullptr;
        return varieties.at(row);
    }
};

struct Variety {
    int id;
    QString name;
    bool isDefault;
    Crop *crop;
    QList<SeedCompany *> seedCompanies; //!< update from DB schema to allow several companies
    Variety(int id_, const QString &n, bool d, Crop *c)
        : id(id_)
        , name(n)
        , isDefault(d)
        , crop(c)
    {
    }

    void addSeedCompany(SeedCompany *c) { seedCompanies << c; }
};

} // namespace qrp
#endif // FAMILY_H
