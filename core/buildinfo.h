#ifndef BUILDINFO_H
#define BUILDINFO_H

#include <QObject>
#include "core_global.h"

class CORESHARED_EXPORT BuildInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString version READ version CONSTANT FINAL)

public:
    explicit BuildInfo(QObject *parent = nullptr);
    QString version() const;

private:
    QString mVersion;
};

#endif // BUILDINFO_H
