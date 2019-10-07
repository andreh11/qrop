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
class QSettings;

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
    bool hasSameFamily(int plantingId1, int plantingId2) const;
    Q_INVOKABLE QString familyInterval(int plantingId) const;
    Q_INVOKABLE QString familyColor(int plantingId) const;
    Q_INVOKABLE QString unit(int plantingId) const;
    Q_INVOKABLE int type(int plantingId) const;
    Q_INVOKABLE int rank(int plantingId) const;

    QVector<QDate> dates(int plantingId) const;
    Q_INVOKABLE QDate sowingDate(int plantingId) const;
    Q_INVOKABLE QDate plantingDate(int plantingId) const;
    Q_INVOKABLE QDate begHarvestDate(int plantingId) const;
    Q_INVOKABLE QDate endHarvestDate(int plantingId) const;

    Q_INVOKABLE QDate plannedSowingDate(int plantingId) const;
    Q_INVOKABLE QDate plannedPlantingDate(int plantingId) const;
    Q_INVOKABLE QDate plannedBegHarvestDate(int plantingId) const;
    Q_INVOKABLE QDate plannedEndHarvestDate(int plantingId) const;

    Q_INVOKABLE bool isActive(int plantingId) const;

    Q_INVOKABLE qreal assignedLength(int plantingId) const;
    Q_INVOKABLE qreal totalLength(int plantingId) const;
    Q_INVOKABLE qreal lengthToAssign(int plantingId) const;
    qreal totalLengthForWeek(int week, int year, int keywordId = -1, bool greenhouse = false) const;
    Q_INVOKABLE qreal totalLengthForYear(int year, bool greenhouse = false) const;
    Q_INVOKABLE int numberOfCrops(int year, bool greenhouse = false) const;
    Q_INVOKABLE int revenue(int year) const;
    Q_INVOKABLE QVariantList totalLengthByWeek(int season, int year, int keywordId = -1,
                                               bool greenhouse = false) const;

    Q_INVOKABLE QVariantList longestCropNames(int year, bool greenhouse = false) const;
    Q_INVOKABLE QVariantList longestCropLengths(int year, bool greenhouse = false) const;

    Q_INVOKABLE QVariantList highestRevenueCropNames(int year, bool greenhouse = false) const;
    Q_INVOKABLE QVariantList highestRevenueCropRevenues(int year, bool greenhouse = false) const;

    Q_INVOKABLE QList<int> addSuccessions(int successions, int weeksBetween, const QVariantMap &map) const;
    Q_INVOKABLE QVariantMap lastValues(int varietyId, int cropId, int plantingType,
                                       bool inGreenhouse) const;

    Q_INVOKABLE void csvImportPlan(int year, const QUrl &path) const;
    Q_INVOKABLE void csvExportPlan(int year, const QUrl &path) const;

    Q_INVOKABLE QString toolTip(int plantingId, int locationId) const;
    QString growBarDescription(const QSqlRecord &record, int year, bool showNames) const;
    QString growBarDescription(int plantingId, int year, bool showNames) const;

    Q_INVOKABLE QVariantMap drawInfoMap(int plantingId, int season, int year,
                                        bool showGreenhouseSow = true, bool showFamilyColor = false,
                                        bool showNames = false) const;

private:
    QVariant value(int plantingId, const QString &field) const;
    QVariant get(const QVariantMap &map, const QSqlRecord &record, const QString &key) const;
    void setGreenhouseValues(QVariantMap &map, const QSqlRecord &record);
    QList<int> yearPlantingList(int year) const;
    void updateTaskType(int plantingId, PlantingType oldType, PlantingType newType) const;
    int plantsNeeded(const QVariantMap &map, const QSqlRecord &record) const;
    void updateKeywords(int plantingId, const QVariantList &newList, const QVariantList &oldList) const;

    DatabaseUtility *m_crop;
    Family *m_family;
    DatabaseUtility *m_seedCompany;
    Keyword *m_keyword;
    Task *m_task;
    DatabaseUtility *m_unit;
    Variety *m_variety;
    QSettings *m_settings;
};

#endif // PLANTING_H
