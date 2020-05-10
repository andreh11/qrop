#ifndef BUILDINFO_H
#define BUILDINFO_H

#include <QObject>
#include "core_global.h"

class CORESHARED_EXPORT BuildInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString version READ version CONSTANT FINAL)
    Q_PROPERTY(QString commit READ commit CONSTANT FINAL)
    Q_PROPERTY(QString branch READ branch CONSTANT FINAL)

public:
    explicit BuildInfo(QObject *parent = nullptr);
    QString version() const;
    QString commit() const;
    QString branch() const;

private:
    QString m_version;
    QString m_commit;
    QString m_branch;
};

#endif // BUILDINFO_H
