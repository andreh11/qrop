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

#ifndef PLANTING_H
#define PLANTING_H

#include <QDate>
#include <QVariantMap>

#include "core_global.h"
#include "databaseutility.h"

class Task;
class Keyword;

class CORESHARED_EXPORT Planting : public DatabaseUtility
{
    Q_OBJECT
public:
    Planting(QObject *parent = nullptr);
    Q_INVOKABLE int add(const QVariantMap &map) const override;
    Q_INVOKABLE void update(int id, const QVariantMap &map) const override;
    Q_INVOKABLE int duplicate(int id) const override;

    Q_INVOKABLE QString cropName(int plantingId) const;
    Q_INVOKABLE QString cropId(int plantingId) const;
    Q_INVOKABLE QString cropColor(int plantingId) const;
    Q_INVOKABLE QString varietyName(int plantingId) const;
    Q_INVOKABLE QString familyId(int plantingId) const;
    Q_INVOKABLE QString familyInterval(int plantingId) const;
    Q_INVOKABLE int type(int plantingId) const;

    Q_INVOKABLE QDate sowingDate(int plantingId) const;
    Q_INVOKABLE QDate plantingDate(int plantingId) const;
    Q_INVOKABLE QDate begHarvestDate(int plantingId) const;
    Q_INVOKABLE QDate endHarvestDate(int plantingId) const;

    Q_INVOKABLE int assignedLength(int plantingId) const;
    Q_INVOKABLE int totalLength(int plantingId) const;
    Q_INVOKABLE int lengthToAssign(int plantingId) const;

    Q_INVOKABLE QList<int> addSuccessions(int successions, int daysBetween, const QVariantMap &map) const;
    Q_INVOKABLE QVariantMap lastValues(const int varietyId, const int cropId,
                                       const int plantingType, const bool inGreenhouse) const;

private:
    Task *task;
    Keyword *keyword;
    //    QList<int> keywordListFromString(const QString &idString) const;
};

#endif // PLANTING_H
