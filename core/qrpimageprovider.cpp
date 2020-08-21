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

#include <QSqlQuery>
#include <QDebug>
#include <QByteArray>

#include "qrpimageprovider.h"

QrpImageProvider::QrpImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Pixmap)
{
}

QPixmap QrpImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(size)
    Q_UNUSED(requestedSize)

    QStringList lst = id.split("/");
    if (lst.empty())
        return {};

    int photoId = lst[0].toInt();
    QSqlQuery query;
    query.prepare("SELECT data FROM file WHERE file_id = :file_id");
    query.bindValue(":file_id", photoId);
    query.exec();
    if (!query.first())
        return {};

    QByteArray byteArray = query.value("data").toByteArray();
    QPixmap pixmap;
    pixmap.loadFromData(byteArray);
    return pixmap;
}
