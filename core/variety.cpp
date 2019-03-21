/*
 * Copyright (C) 2018 André Hoarau <ah@ouvaton.org>
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

Variety::Variety(QObject *parent)
    : DatabaseUtility(parent)
{
    m_table = "variety";
    m_viewTable = "variety";
}

int Variety::cropId(int varietyId) const
{
    QVariantMap map = mapFromId("variety", varietyId);
    return map["crop_id"].toInt();
}

QString Variety::varietyName(int varietyId) const
{
    QVariantMap map = mapFromId("variety", varietyId);
    return map["variety"].toString();
}
