#ifndef QRP_FAMILY_H
#define QRP_FAMILY_H
#include <QtGlobal>
#include <QString>
#include <QSet>

namespace qrp {

struct Crop;
struct Variety;

struct Family
{
    uint id;
    QString name;
    ushort interval;
    QString color;
    QSet<Crop*> crops;

    Family(uint id_, const QString &n, ushort i, const QString &c):
        id(id_), name(n), interval(i), color(c), crops() {}

    void addCrop(Crop *c) {crops.insert(c);}
};

struct Crop
{
    uint id;
    QString name;
    QString color;
    Family *family;
    QSet<Variety*> varieties;
    Crop(uint id_, const QString &n, const QString &c, Family *f) :
        id(id_), name(n), color(c), family(f), varieties(){}

    void addVariety(Variety *v) {varieties.insert(v);}
};

struct Variety {
    uint id;
    QString name;
    bool isDefault;
    Crop *crop;
    Variety(uint id_, const QString &n, bool d, Crop *c) :
        id(id_), name(n), isDefault(d), crop(c){}
};
}
#endif // FAMILY_H
