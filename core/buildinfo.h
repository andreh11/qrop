#pragma once

#include "core_global.h"

#include <QObject>

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

    inline Q_INVOKABLE bool isMobileDevice() const;

private:
    QString m_version;
    QString m_commit;
    QString m_branch;
};

bool BuildInfo::isMobileDevice() const
{
#if defined(Q_OS_ANDROID) || defined (Q_OS_IOS)
    return true;
#else
//    return true;
    return false;
#endif
}

