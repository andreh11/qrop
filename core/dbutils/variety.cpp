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

#include "variety.h"
#include "task.h"

dbutils::Variety::Variety(QObject *parent)
    : DatabaseUtility(parent)
{
    m_table = "variety";
    m_viewTable = "variety";
}

int dbutils::Variety::cropId(int varietyId) const
{
    QVariantMap map = mapFromId("variety", varietyId);
    return map["crop_id"].toInt();
}

QString dbutils::Variety::varietyName(int varietyId) const
{
    QVariantMap map = mapFromId("variety", varietyId);
    return map["variety"].toString();
}

bool dbutils::Variety::isDefault(int varietyId) const
{
    QVariantMap map = mapFromId("variety", varietyId);
    return map["is_default"].toInt() == 1;
}

void dbutils::Variety::setDefault(int varietyId, bool def)
{
    update(varietyId, { { "is_default", def ? 1 : 0 } });
}

int dbutils::Variety::defaultVariety(int cropId) const
{
    QString queryString("SELECT variety_id "
                        "FROM variety "
                        "WHERE crop_id = %1 "
                        "AND is_default = 1");
    auto list = queryIds(queryString.arg(cropId), "variety_id");
    if (list.length() < 1)
        return -1;
    return list.constFirst();
}

void dbutils::Variety::addDefault(int cropId) const
{
    add({ { "variety", tr("Unknown") }, { "crop_id", cropId }, { "is_default", 1 } });
}
