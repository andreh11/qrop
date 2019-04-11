#include "buildinfo.h"
#include <QDebug>
#include "version.h"

BuildInfo::BuildInfo(QObject *parent)
    : QObject(parent)
    ,
#ifdef GIT_REVISION
    mVersion(GIT_REVISION)
#else
    mVersion(tr("Unkown build version"))
#endif
{
}

QString BuildInfo::version() const
{
    qDebug() << "VERSION" << mVersion;
    return mVersion;
}
