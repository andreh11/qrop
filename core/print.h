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

#ifndef PRINT_H
#define PRINT_H

#include <QObject>
#include <QMap>
#include <QPainter>
#include <QPagedPaintDevice>
#include <QPdfWriter>

#include "core_global.h"

class QModelIndex;
class LocationModel;
class Location;
class Planting;
class Keyword;
class QSettings;
class Task;

/**
 * \brief The Print classe handles PDF export for most views.
 */
class CORESHARED_EXPORT Print : public QObject
{
    Q_OBJECT

public:
    explicit Print(QObject *parent = nullptr);

    Q_INVOKABLE void printCropPlan(int year, int month, int week, const QUrl &path,
                                   const QString &type = "entire");
    Q_INVOKABLE void printCalendar(int year, int month, int week, const QUrl &path,
                                   bool showOverdue = false);
    Q_INVOKABLE void printCropMap(int year, int season, const QUrl &path,
                                  bool showFamilyColor = false, bool showOnlyGreenhouse = false);
    Q_INVOKABLE void printHarvests(int year, const QUrl &path);
    Q_INVOKABLE void printSeedList(int year, const QUrl &path, const QString &section = "");
    Q_INVOKABLE void printTransplantList(int year, const QUrl &path);

private:
    using TableInfo = struct {
        QString plantingTypeClause;
        QString monthClause;
        QString orderClause;
        QString title;
        QString tableHeader;
        QString tableRow;
    };

    void preparePdfWriter(QPdfWriter &writer);

    void exportPdf(const QString &html, const QUrl &path,
                   QPageLayout::Orientation orientation = QPageLayout::Landscape);

    // TODO: use TablePrinter
    QString cropPlanHtml(int year, int month, int week, const QString &type) const;
    QString calendarHtml(int year, int week, bool showOverdue) const;
    QString harvestHtml(int year) const;

    // Crop map
    void breakPage(QPagedPaintDevice &printer, QPainter &painter);
    void paintHeader(QPainter &painter, int season, int year);
    void paintRowGrid(QPainter &painter, int rows);
    void paintRow(QPagedPaintDevice &printer, QPainter &painter, const QModelIndex &index,
                  int season, int year);
    int datePosition(const QDate &date);
    void paintPlantingTimegraph(QPainter &painter, int plantingId, int year);
    void paintTaskTimeGraph(QPainter &painter, int taskId, int rows = 1);
    //    void paintTimeline(QPainter &painter, const QModelIndex &parent, int year);
    void paintTimeline(QPainter &painter, QVariantList plantingList, QVariantList taskList, int year);
    void paintTree(QPagedPaintDevice &printer, QPainter &painter, const QModelIndex &parent,
                   int season, int year);

    int m_firstColumnWidth { 2000 };
    int m_rowHeight { 400 };
    int m_monthWidth { 925 };
    int m_textPadding { 60 };
    int m_pageNumber { 0 };
    bool m_showFamilyColor { false };
    Location *m_location;
    Planting *m_planting;
    Keyword *m_keyword;
    Task *m_task;
    LocationModel *m_locationModel;
    QSettings *m_settings;

    QMap<QString, TableInfo> cropPlanMap;
    QString cropPlanQueryString;

    TableInfo calendarInfo;
    QString calendarQueryString;

    TableInfo harvestInfo;
    QString harvestQueryString;
};

#endif // PRINT_H
