#include "location.h"

Location::Location(const QString& name) :
    mId(-1),
    mName(name),
    mLength(0),
    mWidth(0),
    mParentId(0)
{
}

int Location::id() const
{
    return mId;
}

void Location::setId(int id)
{
    mId = id;
}

QString Location::name() const
{
    return mName;
}

void Location::setName(const QString& name)
{
    mName = name;
}

int Location::length() const
{
    return mLength;
}

void Location::setLength(int length)
{
    mLength = length;
}

int Location::width() const
{
    return mWidth;
}

void Location::setWidth(int width)
{
    mWidth = width;
}
int Location::parentId() const
{
    return mParentId;
}

void Location::setParentId(int parentId)
{
    mParentId = parentId;
}
