#ifndef PLANTING_H
#define PLANTING_H

#include <QString>

#include "core_global.h"

class CORESHARED_EXPORT Planting
{
public:
    explicit Planting(const QString& crop = "");

    int id () const;
    void setId(int id);

    QString crop() const;
    void setCrop(const QString& crop);

    QString variety() const;
    void setVariety(const QString& variety);

    QString family() const;
    void setFamily(const QString& family);

    QString unit() const;
    void setUnit(const QString& unit);

private:
    int mId;
    QString mCrop;
    QString mVariety;
    QString mFamily;
    QString mUnit;
};

#endif // PLANTING_H
