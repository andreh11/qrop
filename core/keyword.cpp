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

#include "keyword.h"

Keyword::Keyword(QObject *parent)
    : DatabaseUtility(parent)
{
    m_table = "keyword";
    m_viewTable = "keyword";
}

QList<int> Keyword::keywordIdList(int plantingId) const
{
    QString queryString("SELECT * FROM planting_keyword WHERE planting_id = %1");
    return queryIds(queryString.arg(plantingId), "keyword_id");
}

/*!
 * Return a list of the names of the keywords attached to \a plantingId.
 *
 * The return type is QVariantList for easier interaction with QML.
 */
QVariantList Keyword::keywordStringList(int plantingId) const
{
    auto idList = keywordIdList(plantingId);
    QVariantList vList;
    for (const int id : idList) {
        auto record = recordFromId("keyword", id);
        vList.push_back(QVariant(record.value("keyword")));
    }

    return vList;
}

QList<int> Keyword::keywordListFromString(const QString &keywords) const
{
    QList<int> list;
    for (const auto &keyword : keywords.split(",")) {
        QString queryString("SELECT keyword_id FROM keyword WHERE keyword='%1'");
        QSqlQuery query(queryString.arg(keyword.trimmed()));
        debugQuery(query);
        if (query.first()) {
            list.push_back(query.record().value("keyword_id").toInt());
        } else {
            QVariantMap map;
            map["keyword"] = keyword.trimmed();
            list.push_back(add(map));
        }
    }
    return list;
}

void Keyword::duplicateKeywords(int id, int newId) const
{
    if (id < 0 || newId < 0)
        return;

    for (const int keywordId : keywordIdList(id))
        addPlanting(newId, keywordId);
}

/*!
 * Attach a keyword to a planting.
 *
 * \param plantingId the id of the planting
 * \param keywordId the id of the keyword
 */
void Keyword::addPlanting(int plantingId, int keywordId) const
{
    addLink("planting_keyword", "planting_id", plantingId, "keyword_id", keywordId);
}

void Keyword::removePlanting(int plantingId, int keywordId) const
{
    removeLink("planting_keyword", "planting_id", plantingId, "keyword_id", keywordId);
}

void Keyword::removePlantingKeywords(int plantingId) const
{
    QString queryString = "DELETE FROM planting_keyword WHERY planting_id = %1)";
    QSqlQuery query(queryString.arg(plantingId));
    debugQuery(query);
}
