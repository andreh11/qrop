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
#include <QFile>
#include <QSettings>

#include "transplantlistmodel.h"

TransplantListModel::TransplantListModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
{
    setSortColumn("crop_id");
}

void TransplantListModel::csvExport(const QUrl &path)
{
    QFile f(path.toLocalFile());

    if (f.exists())
        f.remove();

    if (!f.open(QIODevice::ReadWrite)) {
        qDebug() << "Cannot open file";
        return;
    }

    QTextStream ts(&f);

    QList<QString> keyList = {
        "planting_date", "crop", "variety", "seed_company", "plants_needed",
    };

    // Write headers
    for (auto const &field : keyList)
        ts << field << ";";
    ts << "\n";

    QSettings settings;
    QString dateType = settings.value("dateType").toString();

    for (int row = 0; row < rowCount(); ++row) {
        for (auto const &field : keyList) {
            if (dateType == "week" & field == "planting_date") {
                int y;
                int w = QDate::fromString(rowValue(row, field).toString(), Qt::ISODate).weekNumber(&y);
                ts << w << ";";
            } else {
                ts << rowValue(row, field).toString() << ";";
            }
        }
        ts << "\n";
    }
}

bool TransplantListModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    int year = sourceRowValue(sourceRow, sourceParent, "year").toInt();
    return (year == m_year) && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}

bool TransplantListModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    if (m_sortColumn == QStringLiteral("planting_date")) {
        auto lhs = sourceFieldDate(left.row(), left.parent(), "planting_date");
        auto rhs = sourceFieldDate(right.row(), right.parent(), "planting_date");
        return lhs < rhs;
    }
    if (m_sortColumn == QStringLiteral("crop")) {
        auto leftCrop = sourceRowValue(left.row(), left.parent(), "crop").toString();
        auto rightCrop = sourceRowValue(right.row(), right.parent(), "crop").toString();
        int cmp = leftCrop.localeAwareCompare(rightCrop);
        if (cmp < 0)
            return true;
        if (cmp == 0) {
            auto leftVariety = sourceRowValue(left.row(), left.parent(), "variety").toString();
            auto rightVariety = sourceRowValue(right.row(), right.parent(), "variety").toString();
            return leftVariety.localeAwareCompare(rightVariety) < 0;
        }
    }
    if (m_sortColumn == QStringLiteral("variety") || m_sortColumn == QStringLiteral("seed_company")) {
        auto leftVariety = sourceRowValue(left.row(), left.parent(), m_sortColumn).toString();
        auto rightVariety = sourceRowValue(right.row(), right.parent(), m_sortColumn).toString();
        return leftVariety.localeAwareCompare(rightVariety) < 0;
    }
    if (m_sortColumn == QStringLiteral("seeds_number")
        || m_sortColumn == QStringLiteral("seeds_quantity")) {
        auto lhs = sourceRowValue(left.row(), left.parent(), m_sortColumn).toInt();
        auto rhs = sourceRowValue(right.row(), right.parent(), m_sortColumn).toInt();
        return lhs < rhs;
    }
    return SortFilterProxyModel::lessThan(left, right);
}
