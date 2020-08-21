/*
 * Copyright (C) 2018-2019 André Hoarau <ah@ouvaton.org>
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

#include <QDate>
#include <QDebug>
#include <QSqlRecord>
#include <QVariantMap>

#include "family.h"
#include "task.h"

Family::Family(QObject *parent)
    : DatabaseUtility(parent)
{
    m_table = "family";
    m_viewTable = "family";
}

QString Family::name(int familyId) const
{
    QVariantMap map = mapFromId("family", familyId);
    return map["family"].toString();
}

QString Family::color(int familyId) const
{
    QVariantMap map = mapFromId("family", familyId);
    return map["color"].toString();
}

int Family::interval(int familyId) const
{
    QVariantMap map = mapFromId("family", familyId);
    return map["interval"].toInt();
}
