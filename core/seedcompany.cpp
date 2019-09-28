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

#include "seedcompany.h"

SeedCompany::SeedCompany(QObject *parent)
    : DatabaseUtility(parent)
{
    m_table = "seed_company";
    m_viewTable = "seed_company";
}

QString SeedCompany::name(int seedCompanyId) const
{
    QVariantMap map = mapFromId("seed_company", seedCompanyId);
    return map["seed_company"].toString();
}

bool SeedCompany::isDefault(int seedCompanyId) const
{
    QVariantMap map = mapFromId("seed_company", seedCompanyId);
    return map["is_default"].toInt() == 1;
}

void SeedCompany::setDefault(int seedCompanyId, bool def)
{
    update(seedCompanyId, { { "is_default", def ? 1 : 0 } });
}

int SeedCompany::defaultSeedCompany() const
{
    QString queryString("SELECT seed_company_id "
                        "FROM seed_Company "
                        "WHERE is_default = 1");
    auto list = queryIds(queryString, "seed_company_id");
    if (list.length() < 1)
        return -1;
    return list.constFirst();
}
