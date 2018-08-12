#ifndef LOCATION_H
#define LOCATION_H

#include <QString>

#include "core_global.h"

class CORESHARED_EXPORT Location
{
public:
    explicit Location(const QString& name = "");

    int id () const;
    void setId(int id);

    QString name() const;
    void setName(const QString& name);

    int length() const;
    void setLength(int length);

    int width() const;
    void setWidth(int width);

    int parentId () const;
    void setParentId(int parentId);


private:
    int mId;
    QString mName;
    int mLength;
    int mWidth;
    int mParentId;
};

#endif // LOCATION_H
