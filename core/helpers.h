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

#ifndef HELPERS_H
#define HELPERS_H

#include <QObject>
#include <QDate>

#include "core_global.h"

class CORESHARED_EXPORT Helpers : public QObject
{
    Q_OBJECT

public:
    explicit Helpers(QObject *parent = nullptr);
    Q_INVOKABLE static qreal coordinate(qint64 dayNumber);
    Q_INVOKABLE static qreal position(const QDate &seasonBegin, const QDate &date);
    Q_INVOKABLE static qreal widthBetween(qreal pos, const QDate &seasonBegin, const QDate &date);

private:
    const static int mGraphWidth { 60 * 12 };
};

#endif // HELPERS_H
