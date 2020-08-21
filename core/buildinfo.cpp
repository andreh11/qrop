/*
 * Copyright (C) 2018-2020 André Hoarau <ah@ouvaton.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

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
