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

#ifndef LOCATION_H
#define LOCATION_H

#include <memory>

#include <QDate>

#include "core_global.h"
#include "databaseutility.h"

class Planting;

class CORESHARED_EXPORT Location : public DatabaseUtility
{
    Q_OBJECT

public:
    Location(QObject *parent = nullptr);
    Q_INVOKABLE int duplicate(int id) const override;
    Q_INVOKABLE void remove(int id) const override;
    Q_INVOKABLE QList<int> children(int locationId) const;
    QList<int> childrenTree(int locationId) const;

    Q_INVOKABLE qreal length(int locationId) const;
    Q_INVOKABLE bool isGreenhouse(int locationId) const;
    Q_INVOKABLE QString fullName(int locationId) const;

    QList<QString> pathName(int locationId) const;
    Q_INVOKABLE QString fullName(const QList<int> &locationIdList) const;
    Q_INVOKABLE QList<int> locations(int plantingId) const;
    Q_INVOKABLE qreal plantingLength(int plantingId, int locationId) const;
    Q_INVOKABLE QList<int> plantings(int locationId) const;
    std::unique_ptr<QSqlQuery> plantingsQuery(int locationId, const QDate &seasonBeg,
                                              const QDate &seasonEnd) const;
    std::unique_ptr<QSqlQuery> plantingsQuery(int locationId, int season, int year) const;
    std::unique_ptr<QSqlQuery> allLocationsPlantingsQuery(const QDate &seasonBeg,
                                                          const QDate &seasonEnd) const;
    Q_INVOKABLE QList<int> plantings(int locationId, const QDate &last) const;
    Q_INVOKABLE QList<int> plantings(int locationId, const QDate &seasonBeg, const QDate &seasonEnd) const;

    Q_INVOKABLE QList<int> tasks(int locationId, const QDate &seasonBeg, const QDate &seasonEnd) const;

    bool overlap(int plantingId1, int plantingId2) const;
    bool overlap(int plantingId1, const QDate &plantingDate, const QDate &endHarvestDate) const;
    bool overlap(const QDate &plantingDate1, const QDate &endHarvestDate1,
                 const QDate &plantingDate2, const QDate &endHarvestDate2) const;

    Q_INVOKABLE QVariantList nonOverlappingPlantingList(int locationId, const QDate &seasonBeg,
                                                        const QDate &seasonEnd);

    QMap<int, QVariantList> allNonOverlappingPlantingList(int season, int year) const;

    std::unique_ptr<QSqlQuery> allPlantingTasksQuery(const QDate &seasonBeg, const QDate &seasonEnd) const;
    std::unique_ptr<QSqlQuery> allLocationTasksQuery(const QDate &seasonBeg, const QDate &seasonEnd) const;

    QMap<int, QVariantList> nonOverlappingTaskList(int locationId,
                                                   const QMap<int, QVariantList> &plantingMap,
                                                   const QDate &seasonBeg, const QDate &seasonEnd) const;
    QMap<int, QVariantList> allNonOverlappingTaskList(const QMap<int, QVariantList> &plantingMap,
                                                      const QDate &seasonBeg,
                                                      const QDate &seasonEnd) const;

    Q_INVOKABLE QList<int> rotationConflictingPlantings(int locationId, int plantingId) const;
    Q_INVOKABLE QVariantMap spaceConflictingPlantings(int locationId, const QDate &seasonBeg,
                                                      const QDate &seasonEnd) const;
    Q_INVOKABLE qreal availableSpace(int locationId, const QDate &plantingDate,
                                     const QDate &endHarvestDate, const QDate &seasonBeg,
                                     const QDate &seasonEnd) const;
    qreal availableSpace(int locationId, int plantingId, const QDate &seasonBeg,
                         const QDate &seasonEnd) const;

    Q_INVOKABLE bool acceptPlanting(int locationId, int plantingId, const QDate &seasonBeg,
                                    const QDate &seasonEnd) const;
    Q_INVOKABLE void splitPlanting(int plantingId, int otherPlantingId, int locationId);

    Q_INVOKABLE qreal addPlanting(int plantingId, int locationId, qreal length) const;
    Q_INVOKABLE qreal addPlanting(int plantingId, int locationId, qreal length,
                                  const QDate &seasonBeg, const QDate &seasonEnd) const;
    Q_INVOKABLE void removePlanting(int plantingId, int locationId) const;
    Q_INVOKABLE void removePlantingLocations(int plantingId) const;

    Q_INVOKABLE qreal totalBedLength(bool greenhouse = false) const;

    std::unique_ptr<QSqlQuery> allHistoryQuery(int season, int year) const;
    QMap<int, QString> allHistoryDescription(int season, int year) const;
    Q_INVOKABLE QString historyDescription(int locationId, int season, int year) const;

    QMap<int, QVariantList> allRotationConflictingPlantings(int season, int year) const;
    QMap<int, QVariantMap> allSpaceConflictingPlantings(int season, int year) const;

private:
    int duplicateTree(int id, int parentId) const;

    using CropRotationInfo = struct {
        int id;
        QString crop;
        int familyId;
        int familyInterval;
        QDate plantingDate;
        QDate endHarvestDate;
    };
    using CropRotationInfoList = QList<CropRotationInfo>;

    using CropSpaceInfo = struct {
        int id;
        QString crop;
        qreal assignedLength;
        QDate plantingDate;
        QDate endHarvestDate;
    };
    using CropSpaceInfoList = QList<CropSpaceInfo>;

    Planting *m_planting;
};

#endif // LOCATION_H
