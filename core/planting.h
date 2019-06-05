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
#include <QUrl>

#include "core_global.h"
#include "databaseutility.h"

class Crop;
class Family;
class Keyword;
class Location;
class Task;
class Variety;

class CORESHARED_EXPORT Planting : public DatabaseUtility
{
    Q_OBJECT
public:
    Planting(QObject *parent = nullptr);
    Q_INVOKABLE int add(const QVariantMap &map) const override;
    Q_INVOKABLE void update(int id, const QVariantMap &map) const override;
    Q_INVOKABLE void update(int id, const QVariantMap &map, const QVariantMap &locationLengthMap) const;
    Q_INVOKABLE int duplicate(int id) const override;
    Q_INVOKABLE int duplicateToYear(int id, int year) const;
    Q_INVOKABLE void duplicatePlan(int fromYear, int toYear) const;
    Q_INVOKABLE void duplicateListToYear(const QList<int> &idList, int year) const;
    Q_INVOKABLE QVariantMap commonValues(const QList<int> &idList) const override;
    Q_INVOKABLE bool sameCrop(const QList<int> &idList) const;

    Q_INVOKABLE QString cropName(int plantingId) const;
    Q_INVOKABLE int cropId(int plantingId) const;
    Q_INVOKABLE QString cropColor(int plantingId) const;
    Q_INVOKABLE QString varietyName(int plantingId) const;
    Q_INVOKABLE int familyId(int plantingId) const;
    Q_INVOKABLE QString familyInterval(int plantingId) const;
    Q_INVOKABLE QString familyColor(int plantingId) const;
    Q_INVOKABLE int type(int plantingId) const;
    Q_INVOKABLE int rank(int plantingId) const;

    Q_INVOKABLE QDate sowingDate(int plantingId) const;
    Q_INVOKABLE QDate plantingDate(int plantingId) const;
    Q_INVOKABLE QDate begHarvestDate(int plantingId) const;
    Q_INVOKABLE QDate endHarvestDate(int plantingId) const;

    Q_INVOKABLE QDate plannedSowingDate(int plantingId) const;
    Q_INVOKABLE QDate plannedPlantingDate(int plantingId) const;
    Q_INVOKABLE QDate plannedBegHarvestDate(int plantingId) const;
    Q_INVOKABLE QDate plannedEndHarvestDate(int plantingId) const;

    Q_INVOKABLE bool isActive(int plantingId) const;

    Q_INVOKABLE int assignedLength(int plantingId) const;
    Q_INVOKABLE int totalLength(int plantingId) const;
    Q_INVOKABLE int lengthToAssign(int plantingId) const;
    qreal totalLengthForWeek(int week, int year, bool greenhouse = false) const;
    Q_INVOKABLE QVariantList totalLengthByWeek(int season, int year, bool greenhouse = false) const;

    Q_INVOKABLE QVariantList longestCropNames(int year, bool greenhouse = false) const;
    Q_INVOKABLE QVariantList longestCropLengths(int year, bool greenhouse = false) const;

    Q_INVOKABLE QVariantList highestRevenueCropNames(int year, bool greenhouse = false) const;
    Q_INVOKABLE QVariantList highestRevenueCropRevenues(int year, bool greenhouse = false) const;

    Q_INVOKABLE QList<int> addSuccessions(int successions, int daysBetween, const QVariantMap &map) const;
    Q_INVOKABLE QVariantMap lastValues(const int varietyId, const int cropId,
                                       const int plantingType, const bool inGreenhouse) const;

    Q_INVOKABLE void csvImportPlan(int year, const QUrl &path) const;
    Q_INVOKABLE void csvExportPlan(int year, const QUrl &path) const;

private:
    DatabaseUtility *crop;
    Family *family;
    DatabaseUtility *seedCompany;
    Keyword *keyword;
    Task *task;
    DatabaseUtility *unit;
    Variety *variety;
    QVariant get(const QVariantMap &map, const QSqlRecord &record, const QString &key) const;
    void setGreenhouseValues(QVariantMap &map, const QSqlRecord &record);
    QList<int> yearPlantingList(int year) const;
    QDate dateFromString(const QString &string, const int targetYear) const;
    void updateTaskType(int plantingId, PlantingType oldType, PlantingType newType) const;

    int plantsNeeded(const QVariantMap &map, const QSqlRecord &record) const;
    void updateKeywords(int plantingId, const QVariantList newList, const QVariantList oldList) const;
};

#endif // PLANTING_H
