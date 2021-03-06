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

#include "qrpdate.h"
#include "helpers.h"
#include "dbutils/location.h"

#include <QDate>
#include <QDebug>
#include <QSettings>
#include <QFileInfo>

#include <cmath>

Helpers::Helpers(QObject *parent)
    : QObject(parent)
{
}

qreal Helpers::coordinate(qint64 dayNumber)
{
    if (dayNumber < 0)
        return 0;
    if (dayNumber > 365)
        return mGraphWidth;
    return (dayNumber / 365.0) * mGraphWidth;
}

qreal Helpers::position(const QDate &seasonBegin, const QDate &date)
{
    return coordinate(QrpDate::daysTo(seasonBegin, date));
}

qreal Helpers::widthBetween(qreal pos, const QDate &seasonBegin, const QDate &date)
{
    qreal width = position(seasonBegin, date) - pos;
    if (width < 0)
        return 0;
    return width;
}

QList<int> Helpers::listOfInt(const QString &s, const QString &sep)
{
    QList<int> list;
    for (const auto &elt : s.split(sep, QString::SkipEmptyParts))
        list.push_back(elt.toInt());
    return list;
}

QVariantList Helpers::listOfVariant(const QString &s, const QString &sep)
{
    QVariantList list;
    for (const auto &elt : s.split(sep, QString::SkipEmptyParts))
        list.push_back(elt.toInt());
    return list;
}

qreal Helpers::bedLength(qreal length)
{
    QSettings settings;

    if (settings.value("useStandardBedLength").toBool()) {
        return std::round((length / settings.value("standardBedLength").toDouble()) * 100) / 100;
    } else {
        return length;
    }
}

QVariantList Helpers::intToVariantList(const QList<int> &list)
{
    QVariantList variantList;
    for (const int elt : list)
        variantList.push_back(elt);
    return variantList;
}

QList<int> Helpers::variantToIntList(const QVariantList &list)
{
    QList<int> intList;
    for (const auto &elt : list)
        intList.push_back(elt.toInt());
    return intList;
}

QString Helpers::acronymize(const QString &string)
{
    if (string.isEmpty())
        return {};

    auto stringList = string.simplified().split(" ");
    if (stringList.length() > 1) {
        QString s;
        auto end = stringList.constEnd();
        for (auto it = stringList.constBegin(); it != end; ++it)
            s += (*it)[0].toUpper();
        return s;
    }

    auto &first = stringList.first();
    if (first.length() < 2)
        return first;
    return QString(first[0].toUpper()) + first[1].toUpper();
}

QString Helpers::urlBaseName(const QUrl &url)
{
    QString fileName = url.toLocalFile();
    QFileInfo fileInfo(fileName);
    return fileInfo.baseName();
}
