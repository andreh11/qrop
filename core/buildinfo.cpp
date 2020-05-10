#include "buildinfo.h"
#include <QDebug>
#include "version.h"

BuildInfo::BuildInfo(QObject *parent)
    : QObject(parent)
    ,
#ifdef QROP_VERSION
    m_version(QROP_VERSION)
#else
    m_version(tr("Unknown build version"))
#endif
    ,
#ifdef GIT_COMMIT_HASH
    m_commit(GIT_COMMIT_HASH)
#else
    m_commit(tr("Unknown commit hash"))
#endif
    ,
#ifdef GIT_BRANCH
    m_branch(GIT_BRANCH)
#else
    m_branch(tr("Unknown commit branch"))
#endif
{
}

QString BuildInfo::version() const
{
    qDebug() << "VERSION" << m_version;
    return m_version;
}

QString BuildInfo::commit() const
{
    qDebug() << "COMMIT" << m_commit;
    return m_commit;
}

QString BuildInfo::branch() const
{
    qDebug() << "BRANCH" << m_branch;
    return m_branch;
}
