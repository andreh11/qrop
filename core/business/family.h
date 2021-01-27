#ifndef QRP_FAMILY_H
#define QRP_FAMILY_H
#include <QtGlobal>
#include <QString>
#include <QList>

namespace qrp {

struct Crop;
struct Variety;

struct SeedCompany {
    uint id;
    QString name;
    bool isDefault;
    SeedCompany(uint id_, const QString &n, bool d) :
        id(id_), name(n), isDefault(d){}
};

struct Family
{
    uint id;
    QString name;
    ushort interval;
    QString color;
    QList<Crop*> crops;

    Family(uint id_, const QString &n, ushort i, const QString &c):
        id(id_), name(n), interval(i), color(c), crops() {}

    void addCrop(Crop *c) {crops << c;}

    Crop *crop(int row) const {
        if (row >= crops.size())
            return nullptr;
        return crops.at(row);
    }
};

struct Crop
{
    uint id;
    QString name;
    QString color;
    Family *family;
    QList<Variety*> varieties;
    Crop(uint id_, const QString &n, const QString &c, Family *f) :
        id(id_), name(n), color(c), family(f), varieties(){}

    void addVariety(Variety *v) {varieties << v;}

    Variety *variety(int row) const {
        if (row >= varieties.size())
            return nullptr;
        return varieties.at(row);
    }
};

struct Variety {
    uint id;
    QString name;
    bool isDefault;
    Crop *crop;
    QList<SeedCompany*> seedCompanies; //!< update from DB schema to allow several companies
    Variety(uint id_, const QString &n, bool d, Crop *c) :
        id(id_), name(n), isDefault(d), crop(c){}

    void addSeedCompany(SeedCompany *c) {seedCompanies << c;}
};

}  // namespace qrp
#endif // FAMILY_H
