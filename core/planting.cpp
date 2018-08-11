#include "planting.h"

Planting::Planting(const QString& crop) :
    mId(-1),
    mCrop(crop),
    mVariety(""),
    mFamily(""),
    mUnit("")
{

}

int Planting::id() const
{
    return mId;
}

void Planting::setId(int id)
{
    mId = id;
}

QString Planting::crop() const
{
    return mCrop;
}

void Planting::setCrop(const QString& crop)
{
    mCrop = crop;
}

QString Planting::variety() const
{
    return mVariety;
}

void Planting::setVariety(const QString& variety)
{
    mVariety = variety;
}

QString Planting::unit() const
{
    return mUnit;
}

void Planting::setUnit(const QString& unit)
{
    mUnit = unit;
}
