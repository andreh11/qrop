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
#include <QPainter>
#include <QPdfWriter>
#include <QPrinter>
#include <QSettings>
#include <QSqlQuery>
#include <QString>
#include <QTextDocument>
#include <QModelIndex>

#include "print.h"
#include "location.h"
#include "planting.h"
#include "task.h"
#include "mdate.h"
#include "locationmodel.h"

Print::Print(QObject *parent)
    : QObject(parent)
    , m_firstColumnWidth(1500)
    , m_rowHeight(500)
    , m_monthWidth(950)
    , m_textPadding(100)
    , m_locationRows(0)
    , m_pageNumber(0)
    , m_showFamilyColor(false)
    , location(new Location(this))
    , planting(new Planting(this))
    , m_locationModel(new LocationModel(this))
    , cropPlanQueryString(
              "SELECT *, "
              "strftime('%Y', sowing_date) AS sowing_year, "
              "CAST(strftime('%m', sowing_date) AS INTEGER) AS sowing_month, "
              "strftime('%Y', planting_date) AS planting_year, "
              "CAST(strftime('%m', planting_date) AS INTEGER) AS planting_month "
              //                        "strftime('%Y', beg_harvest_date) as beg_harvest_year, "
              //                        "strftime('%m', beg_harvest_date) as beg_harvest_month, "
              //                        "strftime('%Y', end_harvest_date) as end_harvest_year, "
              //                        "strftime('%m', end_harvest_date) as end_harvest_month "
              "FROM planting_view "
              "WHERE (sowing_year = '%1' OR planting_year = '%1') ")
    , calendarQueryString("SELECT *, "
                          "strftime('%Y', assigned_date) AS assigned_year, "
                          "strftime('%Y', completed_date) AS completed_year "
                          "FROM task_view "
                          "WHERE (assigned_year = '%1' OR completed_year = '%1') ")
{
    cropPlanMap["entire"] = {
        "",
        "AND (sowing_month = %1 OR planting_month = %1) ",
        "ORDER BY sowing_date, crop, variety",
        QString("<h2 align=center>%1%2</h2>").arg(tr("General crop plan")).arg("%1"),
        QString("<table width='100%'>"
                "<tr>"
                "<th class='tg' align=left width=20%>%1</th>"
                "<th class='tg' align=left width=20%>%2</th>"
                "<th class='tg' align=right width=5%>%3</th>"
                "<th class='tg' align=right width=5%>%4</th>"
                "<th class='tg' align=right width=5%>%5</th>"
                "<th class='tg' align=right width=5%>%6</th>"
                "<th class='tg' align=right width=5%>%7</th>"
                "<th class='tg' align=right width=5%>%8</th>"
                "<th class='tg' align=right width=5%>%9</th>"
                "<th class='tg' align=left width=10%>%10</th>"
                "</tr>")
                .arg(tr("Crop"))
                .arg(tr("Variety"))
                .arg(tr("S"))
                .arg(tr("TP"))
                .arg(tr("FH"))
                .arg(tr("LH"))
                .arg(tr("Length"))
                .arg(tr("Rows"))
                .arg(tr("Spac."))
                .arg(tr("Locations")),
        QString("<td class='tg'>%1</td>"
                "<td class='tg'>%2</td>"
                "<td class='tg' align=right>%3</td>"
                "<td class='tg' align=right>%4</td>"
                "<td class='tg' align=right>%5</td>"
                "<td class='tg' align=right>%6</td>"
                "<td class='tg' align=right>%7</td>"
                "<td class='tg' align=right>%8</td>"
                "<td class='tg' align=right>%9</td>"
                "<td class='tg' align=left>%10</td>"
                "</tr>")

    };

    cropPlanMap["greenhouse"] = {
        "AND planting_type = 2 ",
        "AND sowing_month = %1 ",
        "ORDER BY sowing_date, crop, variety",
        QString("<h2 align=center>%1%2</h2>").arg(tr("Greenhouse crop plan")).arg("%1"),
        QString("<table width='100%'>"
                "<tr>"
                "<th class='tg' align=right width=5%>%1</th>"
                "<th class='tg' align=left width=20%>%2</th>"
                "<th class='tg' align=left width=20%>%3</th>"
                "<th class='tg' align=right width=5%>%4</th>"
                "<th class='tg' align=right width=5%>%5</th>"
                "<th class='tg' align=right width=5%>%6</th>"
                "<th class='tg' align=right width=5%>%7</th>"
                "<th class='tg' align=right width=5%>%8</th>"
                "<th class='tg' align=right width=5%>%9</th>"
                "</tr>")
                .arg(tr("S"))
                .arg(tr("Crop"))
                .arg(tr("Variety"))
                .arg(tr("TP"))
                .arg(tr("# trays"))
                .arg(tr("Size"))
                .arg(tr("Seeds/hole"))
                .arg(tr("# seeds"))
                .arg(tr("Seed weight")),
        ("<td class='tg' align=right>%1</td>"
         "<td class='tg' align=left>%2</td>"
         "<td class='tg' align=left>%3</td>"
         "<td class='tg' align=right>%4</td>"
         "<td class='tg' align=right>%5</td>"
         "<td class='tg' align=right>%6</td>"
         "<td class='tg' align=right>%7</td>"
         "<td class='tg' align=right>%8</td>"
         "<td class='tg' align=right>%9 g</td>"
         "</tr>")
    };

    cropPlanMap["field_sowing"] = {
        "AND planting_type = 1 ",
        "AND (sowing_month = %1) ",
        "ORDER BY sowing_date, crop, variety ",
        QString("<h2 align=center>%1%2</h2>").arg(tr("Field sowing crop plan")).arg("%1"),
        QString("<table width='100%'>"
                "<tr>"
                "<th class='tg' align=right width=5%>%1</th>"
                "<th class='tg' align=left width=20%>%2</th>"
                "<th class='tg' align=left width=20%>%3</th>"
                "<th class='tg' align=right width=5%>%4</th>"
                "<th class='tg' align=right width=8%>%5</th>"
                "<th class='tg' align=right width=8%>%6</th>"
                "<th class='tg' align=right width=5%>%7</th>"
                "<th class='tg' align=right width=8%>%8</th>"
                "<th class='tg' align=left width=8%>%9</th>"
                "</tr>")
                .arg(tr("S"))
                .arg(tr("Crop"))
                .arg(tr("Variety"))
                .arg(tr("FH"))
                .arg(tr("Length"))
                .arg(tr("Spacing"))
                .arg(tr("Rows"))
                .arg(tr("Weight"))
                .arg(tr("Locations")),
        ("<td class='tg' align=right>%1</td>"
         "<td class='tg' align=left>%2</td>"
         "<td class='tg' align=left>%3</td>"
         "<td class='tg' align=right>%4</td>"
         "<td class='tg' align=right>%5 m</td>"
         "<td class='tg' align=right>%6 cm</td>"
         "<td class='tg' align=right>%7</td>"
         "<td class='tg' align=right>%8 g</td>"
         "<td class='tg' align=left>%9</td>"
         "</tr>")
    };

    cropPlanMap["field_transplanting"] = {
        "AND planting_type > 1 ",
        "AND (planting_month = %1) ",
        "ORDER BY planting_date, crop, variety",
        QString("<h2 align=center>%1%2</h2>").arg(tr("Field transplanting crop plan")).arg("%1"),
        QString("<table>"
                "<tr>"
                "<th class='tg' align=right width=5%>%1</th>"
                "<th class='tg' align=left width=20%>%2</th>"
                "<th class='tg' align=left width=20%>%3</th>"
                "<th class='tg' align=right width=5%>%4</th>"
                "<th class='tg' align=right width=8%>%5</th>"
                "<th class='tg' align=right width=8%>%6</th>"
                "<th class='tg' align=right width=5%>%7</th>"
                "<th class='tg' align=right width=5%>%8</th>"
                "<th class='tg' align=right width=5%>%9</th>"
                "<th class='tg' align=left width=8%>%10</th>"
                "</tr>")
                .arg(tr("TP"))
                .arg(tr("Crop"))
                .arg(tr("Variety"))
                .arg(tr("FH"))
                .arg(tr("Length"))
                .arg(tr("Spacing"))
                .arg(tr("Rows"))
                .arg(tr("# trays"))
                .arg(tr("Size"))
                .arg(tr("Locations")),
        ("<td class='tg' align=right>%1</th>"
         "<td class='tg' align=left>%2</th>"
         "<td class='tg' align=left>%3</th>"
         "<td class='tg' align=right>%4</th>"
         "<td class='tg' align=right>%5</th>"
         "<td class='tg' align=right>%6</th>"
         "<td class='tg' align=right>%7</th>"
         "<td class='tg' align=right>%8</th>"
         "<td class='tg' align=right>%9</th>"
         "<td class='tg' align=left>%10</th>"
         "</tr>")

    };

    calendarInfo = { "",
                     "",
                     "ORDER BY task_type_id, assigned_date ",
                     QString("<h2 align=center>%1%2</h2>").arg(tr("Task calendar")).arg("%1"),
                     QString("<table width='100%' style='page-break-after: always'>"
                             "<tr>"
                             "<th class='tg' align=left width=10%>%1</th>"
                             "<th class='tg' align=left width=20%>%2</th>"
                             "<th class='tg' align=left width=15%>%3</th>"
                             "<th class='tg' align=left width=25%>%4</th>"
                             "<th class='tg' align=left width=30%>%5</th>"
                             "</tr>")
                             .arg(tr("Date"))
                             .arg(tr("Planting"))
                             .arg(tr("Locations"))
                             .arg(tr("Description"))
                             .arg(tr("Notes")),
                     ("<td class='tg' align=right>%1</th>"
                      "<td class='tg' align=left>%2</th>"
                      "<td class='tg' align=left>%3</th>"
                      "<td class='tg' align=left>%4</th>"
                      "<td class='tg' align=left>%5</th>"
                      "</tr>")

    };
}

void Print::printCropPlan(int year, int month, int week, const QUrl &path, const QString &type)
{
    QString html = cropPlanHtml(year, month, week, type);
    exportPdf(html, path);
}

void Print::printCalendar(int year, int month, int week, const QUrl &path, bool showOverdue)
{
    int begWeek;
    int endWeek;
    QList<int> month31({ 1, 3, 5, 7, 8, 10, 12 });
    if (month > 0) {
        begWeek = QDate(year, month, 1).weekNumber();
        if (month == 2) {
            if (QDate::isLeapYear(year))
                endWeek = QDate(year, month, 29).weekNumber();
            else
                endWeek = QDate(year, month, 28).weekNumber();
        } else if (month31.contains(month)) {
            endWeek = QDate(year, month, 31).weekNumber();
        } else {
            endWeek = QDate(year, month, 30).weekNumber();
        }
    } else if (week > 0) {
        begWeek = endWeek = week;
    } else {
        begWeek = 1;
        endWeek = 52;
    }

    QString html;
    for (int w = begWeek; w <= endWeek; w++)
        html += calendarHtml(year, w, (week > 0 || month > 0) && showOverdue);
    exportPdf(html, path);
}

void Print::exportPdf(const QString &html, const QUrl &path)
{
    QPdfWriter writer(path.toLocalFile());
    writer.setPageSize(QPagedPaintDevice::A4);
    writer.setPageOrientation(QPageLayout::Landscape);
    qDebug() << writer.setPageMargins(QMargins(0, 0, 0, 0), QPageLayout::Millimeter);

    QString tableStyle = QString(".tg  { font-family: Roboto Regular; "
                                 "font-size: 10pt; "
                                 "padding: 10; "
                                 "padding-bottom: 10; "
                                 "border-style: none }"
                                 ".tovd  { font-family: Roboto Regular; "
                                 "font-size: 10pt; "
                                 "font-weight: bold;"
                                 "padding: 10; "
                                 "padding-bottom: 10; "
                                 "border-style: none }"
                                 ".type  { font-family: Roboto Regular; "
                                 "font-size: 10pt; "
                                 "padding: 10; "
                                 "padding-bottom: 10; "
                                 "border-style: none;"
                                 "background-color: #757575;"
                                 "color: white }");

    auto *doc = new QTextDocument(this);
    doc->setDocumentMargin(0);
    doc->setDefaultStyleSheet(tableStyle);
    doc->setHtml(html);
    doc->print(&writer);
}

QString Print::cropPlanHtml(int year, int month, int week, const QString &type) const
{
    QString titleMW;
    if (month >= 1 && month <= 12)
        titleMW.append(QString(" (%1)").arg(MDate::monthName(month)));
    else if (week >= 1 && week <= 53)
        titleMW.append(QString(" (%1)").arg(week));

    QString html = cropPlanMap[type].title.arg(titleMW);
    html.append(cropPlanMap[type].tableHeader);

    QString queryString = cropPlanQueryString.arg(year);
    if (month > 0)
        queryString.append(cropPlanMap[type].monthClause.arg(month));
    queryString.append(cropPlanMap[type].plantingTypeClause);
    queryString.append(cropPlanMap[type].orderClause);
    QSqlQuery query(queryString);

    int i = 0;
    Location location;
    while (query.next()) {
        QString crop = query.value("crop").toString();
        QString variety = query.value("variety").toString();
        int length = query.value("length").toInt();
        int rows = query.value("rows").toInt();
        int spacing = query.value("spacing_plants").toInt();
        double trayNumber = query.value("trays_to_start").toDouble();
        int traySize = query.value("tray_size").toInt();
        int seedsPerHole = query.value("seeds_per_hole").toInt();
        int seedsNumber = query.value("seeds_number").toInt();
        double seedsQuantity = query.value("seeds_quantity").toDouble();

        QString locations = query.value("locations").toString();
        QList<int> locationIdList;
        for (const auto &idString : locations.split(","))
            locationIdList.append(idString.toInt());
        QString locationsName = location.fullName(locationIdList);

        QDate sowingDate = QDate::fromString(query.value("sowing_date").toString(), Qt::ISODate);
        QDate plantingDate = QDate::fromString(query.value("planting_date").toString(), Qt::ISODate);
        QDate begHarvestDate =
                QDate::fromString(query.value("beg_harvest_date").toString(), Qt::ISODate);
        QDate endHarvestDate =
                QDate::fromString(query.value("end_harvest_date").toString(), Qt::ISODate);

        if (week > 0 && sowingDate.weekNumber() != week && plantingDate.weekNumber() != week)
            continue;

        if (i % 2 == 0)
            html.append("<tr style='background-color: #e0e0e0'>");
        else
            html.append("<tr>");

        if (type == "entire")
            html += cropPlanMap[type]
                            .tableRow.arg(crop)
                            .arg(variety)
                            .arg(MDate::formatDate(sowingDate, year))
                            .arg(MDate::formatDate(plantingDate, year))
                            .arg(MDate::formatDate(begHarvestDate, year))
                            .arg(MDate::formatDate(endHarvestDate, year))
                            .arg(length)
                            .arg(rows)
                            .arg(spacing)
                            .arg(locationsName);
        else if (type == "greenhouse")
            html += cropPlanMap[type]
                            .tableRow.arg(MDate::formatDate(sowingDate, year))
                            .arg(crop)
                            .arg(variety)
                            .arg(MDate::formatDate(plantingDate, year))
                            .arg(trayNumber)
                            .arg(traySize)
                            .arg(seedsPerHole)
                            .arg(seedsNumber)
                            .arg(seedsQuantity);
        else if (type == "field_sowing")
            html += cropPlanMap[type]
                            .tableRow.arg(MDate::formatDate(sowingDate, year))
                            .arg(crop)
                            .arg(variety)
                            .arg(MDate::formatDate(begHarvestDate, year))
                            .arg(length)
                            .arg(spacing)
                            .arg(rows)
                            .arg(seedsQuantity)
                            .arg(locationsName);
        else if (type == "field_transplanting")
            html += cropPlanMap[type]
                            .tableRow.arg(MDate::formatDate(plantingDate, year))
                            .arg(crop)
                            .arg(variety)
                            .arg(MDate::formatDate(begHarvestDate, year))
                            .arg(length)
                            .arg(spacing)
                            .arg(rows)
                            .arg(trayNumber)
                            .arg(traySize)
                            .arg(locationsName);
        i++;
    }

    html += "</table>";
    return html;
}

QString Print::calendarHtml(int year, int week, bool showOverdue) const
{
    QSettings settings;
    bool useStandardBedLength = settings.value("useStandardBedLength").toBool();
    int standardBedLength = settings.value("standardBedLength").toInt();

    QString titleMW;
    if (week >= 1 && week <= 53) {
        QDate monday = MDate::mondayOfWeek(week, year);
        QDate sunday = monday.addDays(6);
        titleMW.append(
                tr(" W%1, %2 − %3").arg(week).arg(monday.toString("dd/MM")).arg(sunday.toString("dd/MM")));
    }

    QString html = calendarInfo.title.arg(titleMW);
    html.append(calendarInfo.tableHeader);

    QString queryString = calendarQueryString.arg(year);
    queryString.append(calendarInfo.plantingTypeClause);
    queryString.append(calendarInfo.orderClause);
    QSqlQuery query(queryString);

    Location location;
    Planting planting;
    Task task;
    int lastTaskTypeId = -1;
    int i = 0;
    while (query.next()) {
        QDate assignedDate = QDate::fromString(query.value("assigned_date").toString(), Qt::ISODate);
        QDate completedDate = QDate::fromString(query.value("completed_date").toString(), Qt::ISODate);

        bool overdue = assignedDate.weekNumber() < week && !completedDate.isValid();

        if (assignedDate.weekNumber() != week && (!showOverdue || !overdue))
            continue;

        int taskId = query.value("task_id").toInt();
        int taskTypeId = query.value("task_type_id").toInt();
        QString taskType = query.value("type").toString();
        QList<int> plantingIdList = task.taskPlantings(taskId);
        QList<int> locationIdList = task.taskLocations(taskId);

        QString taskMethod = query.value("method").toString();
        QString taskImplement = query.value("implement").toString();

        if (taskTypeId != lastTaskTypeId) {
            i = 0;
            lastTaskTypeId = taskTypeId;
            html += QString("<tr><td class='type' colspan=6>%1</td></tr>").arg(taskType);
        }

        int j = 0;

        // Plantings
        for (auto plantingId : plantingIdList) {
            QList<int> locationList = location.locations(plantingId);
            QString locationsName = location.fullName(locationList);
            QVariantMap map = planting.mapFromId("planting_view", plantingId);
            int rows = map.value("rows").toInt();
            int spacing = map.value("spacing_plants").toInt();
            int trays = map.value("trays_to_start").toInt();
            int traySize = map.value("tray_size").toInt();
            int seedsPerHole = map.value("seeds_per_hole").toInt();

            int length = map.value("length").toInt();
            QString lengthString;
            if (useStandardBedLength)
                lengthString = tr("%1 beds").arg(length * 1.0 / standardBedLength);
            else
                lengthString = tr("%1 bed m.").arg(length);

            QString description;
            switch (taskTypeId) {
            case 1: // DS
                description =
                        QString(tr("%1, %2 rows x %3 cm")).arg(lengthString).arg(rows).arg(spacing);
                break;
            case 2: // GH sow
                if (seedsPerHole > 1)
                    description =
                            QString(tr("%1 x %2, %3 seeds per hole")).arg(trays).arg(traySize).arg(seedsPerHole);
                else
                    description = QString(tr("%1 x %2")).arg(trays).arg(traySize);
                break;
            case 3:
                description =
                        QString(tr("%1, %2 rows x %3 cm")).arg(lengthString).arg(rows).arg(spacing);
                break;
            default:
                description = QString("%1, %2").arg(taskMethod).arg(taskImplement);
            }

            QString plantingString =
                    QString("%1, %2").arg(planting.cropName(plantingId)).arg(planting.varietyName(plantingId));
            if (i % 2 == 1) {
                html += QString("<tr style='font-weight: %1; background-color: #e0e0e0'>")
                                .arg(overdue ? "bold" : "normal");
            } else {
                html += QString("<tr style='font-weight: %1'>").arg(overdue ? "bold" : "normal");
            }

            if (j == 0)
                html += calendarInfo.tableRow
                                .arg(overdue ? "(" + MDate::formatDate(assignedDate, year) + ")" : "")
                                .arg(plantingString)
                                .arg(locationsName)
                                .arg(description)
                                .arg("");
            else
                html += calendarInfo.tableRow.arg("")
                                .arg(plantingString)
                                .arg(locationsName)
                                .arg("\"")
                                .arg("");

            j++;
        }

        if (!locationIdList.empty()) {
            QString description = QString("%1, %2").arg(taskMethod).arg(taskImplement);
            QString locationsName = location.fullName(locationIdList);

            if (i % 2 == 1)
                html.append("<tr style='background-color: #e0e0e0'>");
            else
                html.append("<tr>");
            html += calendarInfo.tableRow
                            .arg(overdue ? "(" + MDate::formatDate(assignedDate, year) + ")" : "")
                            .arg("")
                            .arg(locationsName)
                            .arg(description)
                            .arg("");
        }

        i++;
    }
    html += "</table>";
    return html;
}

void Print::printCropMap(int year, int season, const QUrl &path, bool showFamilyColor,
                         bool showOnlyGreenhouse)

{
    QPdfWriter writer(path.toLocalFile());
    writer.setPageSize(QPagedPaintDevice::A4);
    writer.setPageOrientation(QPageLayout::Landscape);
    writer.setPageMargins(QMargins(10, 10, 10, 10), QPageLayout::Millimeter);

    QPainter painter;
    painter.begin(&writer);

    QPen pen;
    pen.setWidth(10);
    pen.setStyle(Qt::SolidLine);
    pen.setBrush(QColor("grey"));
    painter.setPen(pen);

    m_locationModel->refresh();
    m_locationModel->setFilterYear(year);
    m_locationModel->setFilterSeason(season);
    m_locationModel->setShowOnlyGreenhouseLocations(showOnlyGreenhouse);
    m_locationRows = 0;
    m_showFamilyColor = showFamilyColor;
    m_pageNumber = 1;
    paintHeader(painter, season, year);
    paintTree(writer, painter, QModelIndex(), season, year);

    painter.end();
}

void Print::paintHeader(QPainter &painter, int season, int year)
{
    QRectF headerRect(0, 0, m_firstColumnWidth + 12 * m_monthWidth, m_rowHeight);

    painter.save();
    QFont font("Roboto Regular", 14, 10);
    painter.setFont(font);
    painter.drawText(headerRect, Qt::AlignLeft,
                     QString("%1 %2").arg(MDate::seasonName(season)).arg(year));
    painter.drawText(headerRect, Qt::AlignRight, QString::number(m_pageNumber));
    painter.restore();

    QRectF locationRect(0, m_rowHeight, m_firstColumnWidth, m_rowHeight);

    painter.drawRect(locationRect);
    painter.drawText(locationRect.adjusted(m_textPadding, 0, 0, 0), Qt::AlignVCenter, tr("Location"));

    for (int m = 0; m < 12; m++) {
        QRectF rect(m_firstColumnWidth + m * m_monthWidth, m_rowHeight, m_monthWidth, m_rowHeight);
        painter.drawRect(rect);
        painter.drawText(rect, Qt::AlignCenter,
                         MDate::shortMonthName(1 + MDate::monthsOrder[season][m]));
    }
}

void Print::paintRowGrid(QPainter &painter, int row)
{
    painter.drawRect(0, (row + 2) * m_rowHeight, m_firstColumnWidth, m_rowHeight);
    for (int m = 0; m < 12; m++) {
        QRectF rect(m_firstColumnWidth + m * m_monthWidth, (2 + row) * m_rowHeight, m_monthWidth,
                    m_rowHeight);
        painter.drawRect(rect);
    }
}

int Print::datePosition(const QDate &date)
{
    int x = 0;
    QPair<QDate, QDate> seasonDates = m_locationModel->seasonDates();
    QDate seasonBeg = seasonDates.first;
    QDate seasonEnd = seasonDates.second;

    if ((seasonBeg <= date) && (date <= seasonEnd))
        x = static_cast<int>((1.0 * seasonBeg.daysTo(date) / date.daysInYear()) * m_monthWidth * 12);
    else if (date < seasonBeg)
        x = 0;
    else
        x = 12 * m_monthWidth;

    return m_firstColumnWidth + x;
}

void Print::paintTimegraph(QPainter &painter, int row, int plantingId, int year)
{
    QDate plantingDate = planting->plantingDate(plantingId);
    QDate begHarvestDate = planting->begHarvestDate(plantingId);
    QDate endHarvestDate = planting->endHarvestDate(plantingId);

    QString colorString;

    if (m_showFamilyColor)
        colorString = planting->familyColor(plantingId);
    else
        colorString = planting->cropColor(plantingId);

    QColor cropColor(colorString);
    QString cropName = planting->cropName(plantingId);
    QString varietyName = planting->varietyName(plantingId);

    int y = (2 + row) * m_rowHeight;
    int p = static_cast<int>(m_rowHeight * 0.1);

    QPoint point1(datePosition(plantingDate), y + p);
    QPoint point2(datePosition(begHarvestDate), y + m_rowHeight - p);
    QPoint point3(datePosition(begHarvestDate), y + p);
    QPoint point4(datePosition(endHarvestDate), y + m_rowHeight - p);

    painter.fillRect(QRectF(point1, point2), cropColor);
    painter.fillRect(QRectF(point3, point4), cropColor.darker(120));

    painter.save();
    QPen pen(QColor("white"));
    painter.setPen(pen);
    painter.drawText(QRectF(point1, point4).adjusted(m_textPadding, 0, 0, 0), Qt::AlignVCenter,
                     QString("%1 %2, %3")
                             .arg(MDate::formatDate(plantingDate, year, "", false))
                             .arg(cropName)
                             .arg(varietyName));
    painter.restore();
}

void Print::paintTimeline(QPainter &painter, int row, const QModelIndex &parent, int year)
{
    int locationId = m_locationModel->locationId(parent);

    QPair<QDate, QDate> seasonDates = m_locationModel->seasonDates();
    QDate seasonBeg = seasonDates.first;
    QDate seasonEnd = seasonDates.second;

    for (int plantingId : location->plantings(locationId, seasonBeg, seasonEnd))
        paintTimegraph(painter, row, plantingId, year);
}

void Print::paintTree(QPagedPaintDevice &printer, QPainter &painter, const QModelIndex &parent,
                      int season, int year)
{
    for (int row = 0; row < m_locationModel->rowCount(parent); row++) {
        QModelIndex index = m_locationModel->index(row, 0, parent);
        int locationId = m_locationModel->locationId(index);

        if (m_locationModel->hasChildren(index)) {
            paintTree(printer, painter, index, season, year);
        } else {
            paintRowGrid(painter, m_locationRows);

            QRectF locationRect(0, (m_locationRows + 2) * m_rowHeight, m_firstColumnWidth, m_rowHeight);
            painter.drawText(locationRect.adjusted(m_textPadding, 0, 0, 0), Qt::AlignVCenter,
                             location->fullName(locationId));

            paintTimeline(painter, m_locationRows, index, year);

            m_locationRows++;
            if (m_locationRows > 15) {
                printer.newPage();
                m_pageNumber++;
                paintHeader(painter, season, year);
                m_locationRows = 0;
            }
        }
    }
}
