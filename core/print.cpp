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

#include <cmath>

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
#include <QSettings>
#include <QElapsedTimer>

#include "helpers.h"
#include "keyword.h"
#include "location.h"
#include "locationmodel.h"
#include "harvestmodel.h"
#include "mdate.h"
#include "planting.h"
#include "print.h"
#include "task.h"

#include "tableprinter.h"

#include "seedlistmodel.h"
#include "seedlistmonthmodel.h"
#include "seedlistquartermodel.h"
#include "transplantlistmodel.h"

Print::Print(QObject *parent)
    : QObject(parent)
    , m_location(new Location(this))
    , m_planting(new Planting(this))
    , m_keyword(new Keyword(this))
    , m_task(new Task(this))
    , m_locationModel(nullptr)
    , m_settings(new QSettings(this))
    , cropPlanQueryString("SELECT *, "
                          "strftime('%Y', sowing_date) AS sowing_year, "
                          "CAST(strftime('%m', sowing_date) AS INTEGER) AS sowing_month, "
                          "strftime('%Y', planting_date) AS planting_year, "
                          "CAST(strftime('%m', planting_date) AS INTEGER) AS planting_month "
                          "FROM planting_view "
                          "WHERE (sowing_year = '%1' OR planting_year = '%1') ")
    , calendarQueryString("SELECT *, "
                          "strftime('%Y', assigned_date) AS assigned_year, "
                          "strftime('%Y', completed_date) AS completed_year "
                          "FROM task_view "
                          "WHERE (assigned_year = '%1' OR completed_year = '%1') ")
    , harvestQueryString("SELECT *, "
                         "strftime('%Y', date) as harvest_year "
                         "FROM harvest_view "
                         "WHERE harvest_year = '%1' ")
{
    cropPlanMap["entire"] = { "",
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
                                      "</tr>") };

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
                "<th class='tg' align=right width=4%>%7</th>"
                "<th class='tg' align=right width=5%>%8</th>"
                "<th class='tg' align=right width=10%>%9</th>"
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
         "<td class='tg' align=right>%L5</td>"
         "<td class='tg' align=right>%6</td>"
         "<td class='tg' align=right>%7</td>"
         "<td class='tg' align=right>%8</td>"
         "<td class='tg' align=right>%L9 g</td>"
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
                             "<th class='tg' align=left width=10%>%5</th>"
                             "<th class='tg' align=left width=30%>%6</th>"
                             "</tr>")
                             .arg(tr("Date"))
                             .arg(tr("Planting"))
                             .arg(tr("Locations"))
                             .arg(tr("Description"))
                             .arg(tr("Tags"))
                             .arg(tr("Notes")),
                     ("<td class='tg' align=right>%1</th>"
                      "<td class='tg' align=left>%2</th>"
                      "<td class='tg' align=left>%3</th>"
                      "<td class='tg' align=left>%4</th>"
                      "<td class='tg' align=left>%5</th>"
                      "<td class='tg' align=left>%6</th>"
                      "</tr>") };

    harvestInfo = { "",
                    "",
                    "ORDER BY date ",
                    QString("<h2 align=center>%1 %2</h2>").arg(tr("Harvests")).arg("%1"),
                    QString("<table width='100%' style='page-break-after: always'>"
                            "<tr>"
                            "<th class='tg' align=left width=10%>%1</th>"
                            "<th class='tg' align=left width=30%>%2</th>"
                            "<th class='tg' align=left width=30%>%3</th>"
                            "<th class='tg' align=left width=15%>%4</th>"
                            "<th class='tg' align=left width=15%>%5</th>"
                            "</tr>")
                            .arg(tr("Date"))
                            .arg(tr("Planting"))
                            .arg(tr("Locations"))
                            .arg(tr("Quantity"))
                            .arg(tr("Labor time")),
                    ("<td class='tg' align=left>%1</th>"
                     "<td class='tg' align=left>%2</th>"
                     "<td class='tg' align=left>%3</th>"
                     "<td class='tg' align=left>%4</th>"
                     "<td class='tg' align=left>%5</th>"
                     "</tr>") };
}

void Print::printCropPlan(int year, int month, int week, const QUrl &path, const QString &type)
{
    QString html = cropPlanHtml(year, month, week, type);
    exportPdf(html, path);
}

void Print::printCalendar(int year, int month, int week, const QUrl &path, bool showDone,
                          bool showDue, bool showOverdue)
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
    QElapsedTimer t;
    t.start();
    for (int w = begWeek; w <= endWeek; w++)
        html += calendarHtml(year, w, showDone, showDue, (week > 0 || month > 0) && showOverdue);
    qDebug() << "Total time" << t.elapsed();
    exportPdf(html, path);
}

void Print::printHarvests(int year, const QUrl &path)
{
    QString html = harvestHtml(year);
    exportPdf(html, path, QPageLayout::Portrait);
    //    QPdfWriter writer(path.toLocalFile());
    //    preparePdfWriter(writer);

    //    QPainter painter;
    //    painter.begin(&writer);

    //    TablePrinter tablePrinter(&painter, &writer);
    //    tablePrinter.setTableInfo({ { "date", tr("Date"), 10, TablePrinter::Week },
    //                                { "crop", tr("Crop"), 10, TablePrinter::String },
    //                                { "variety", tr("Variety"), 10, TablePrinter::String },
    //                                { "unit", tr("Unit"), 5, TablePrinter::String },
    //                                { "quantity", tr("Quantity"), 5, TablePrinter::Number },
    //                                { "locations", tr("Locations"), 10, TablePrinter::Locations } });

    //    auto model = new HarvestModel(this);

    //    //    model->setSortColumn("crop");
    //    model->setWeek(40);
    //    model->setFilterYear(year);
    //    tablePrinter.setModel(model);

    //    tablePrinter.printTable();

    //    painter.end();
    //    delete model;
}

void Print::preparePdfWriter(QPdfWriter &writer)
{
    writer.setPageSize(QPagedPaintDevice::A4);
    writer.setPageOrientation(QPageLayout::Portrait);
    writer.setPageMargins(QMargins(10, 10, 10, 10), QPageLayout::Millimeter);
}

void Print::printSeedList(int year, const QUrl &path, const QString &section)
{
    QPdfWriter writer(path.toLocalFile());
    preparePdfWriter(writer);

    QPainter painter;
    painter.begin(&writer);

    TablePrinter tablePrinter(&painter, &writer);
    tablePrinter.setTableInfo({ { "crop", tr("Crop"), 10, TablePrinter::String },
                                { "variety", tr("Variety"), 10, TablePrinter::String },
                                { "seed_company", tr("Company"), 10, TablePrinter::String },
                                { "seeds_number", tr("Number"), 5, TablePrinter::Number },
                                { "seeds_quantity", tr("Quantity"), 5, TablePrinter::Weight } });

    SeedListModel *model;
    if (section == "month") {
        model = new SeedListMonthModel(this);
        tablePrinter.setTitle(tr("Monthly Seed List (%1)").arg(year));
    } else if (section == "quarter") {
        model = new SeedListQuarterModel(this);
        tablePrinter.setTitle(tr("Quarterly Seed List (%1)").arg(year));
    } else {
        model = new SeedListModel(this);
        tablePrinter.setTitle(tr("Yearly Seed List (%1)").arg(year));
    }

    model->setSortColumn("crop");
    model->setFilterYear(year);
    tablePrinter.setModel(model);

    if (section == "month")
        tablePrinter.printTable("month", true);
    else if (section == "quarter")
        tablePrinter.printTable("trimester", true);
    else
        tablePrinter.printTable();

    painter.end();
    delete model;
}

void Print::printTransplantList(int year, const QUrl &path)
{
    QPdfWriter writer(path.toLocalFile());
    preparePdfWriter(writer);

    QPainter painter;
    painter.begin(&writer);

    TransplantListModel model;
    model.setSortColumn("crop");
    model.setFilterYear(year);
    model.setSortColumn("planting_date");

    TablePrinter tablePrinter(&painter, &writer);
    tablePrinter.setTableInfo({ { "planting_date", tr("Transplanting date"), 8, TablePrinter::Week },
                                { "crop", tr("Crop"), 10, TablePrinter::String },
                                { "variety", tr("Variety"), 10, TablePrinter::String },
                                { "seed_company", tr("Company"), 10, TablePrinter::String },
                                { "plants_needed", tr("Number"), 5, TablePrinter::Number } });
    tablePrinter.setModel(&model);
    tablePrinter.setTitle(tr("Transplant List (%1)").arg(year));
    tablePrinter.setYear(year);

    tablePrinter.printTable();

    painter.end();
}

void Print::exportPdf(const QString &html, const QUrl &path, QPageLayout::Orientation orientation)
{
    QPdfWriter writer(path.toLocalFile());
    writer.setPageSize(QPagedPaintDevice::A4);
    writer.setPageOrientation(orientation);
    writer.setPageMargins(QMargins(0, 0, 0, 0), QPageLayout::Millimeter);

    QString tableStyle = QString(".tg  { font-family: Roboto Regular; "
                                 "font-size: 10pt; "
                                 "padding: 10; "
                                 "padding-bottom: 10; "
                                 "border-style: none }"

                                 "p.break {page-break-before: always}"

                                 ".header { font-family: Roboto Regular; "
                                 "font-size: 10pt; "
                                 "padding: 10; "
                                 "padding-bottom: 10; "
                                 "border-style: none;"
                                 "background-color: black;"
                                 "color: white }"

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
                                 "color: white }"

    );

    auto *doc = new QTextDocument(this);
    doc->setDocumentMargin(0);
    doc->setDefaultStyleSheet(tableStyle);
    doc->setHtml(html);
    doc->print(&writer);
}

QString Print::cropPlanHtml(int year, int month, int week, const QString &type) const
{
    auto showPlantingSuccessionNumber = m_settings->value("showPlantingSuccessionNumber").toBool();
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
        int successionNumber = query.value("planting_rank").toInt();
        QString variety = query.value("variety").toString();
        int length = query.value("length").toInt();
        int rows = query.value("rows").toInt();
        int spacing = query.value("spacing_plants").toInt();
        double trayNumber = std::round(query.value("trays_to_start").toDouble() * 10) / 10;
        int traySize = query.value("tray_size").toInt();
        int seedsPerHole = query.value("seeds_per_hole").toInt();
        int seedsNumber = query.value("seeds_number").toInt();
        double seedsQuantity = std::round(query.value("seeds_quantity").toDouble() * 10) / 10;

        QString locations = query.value("locations").toString();
        QList<int> locationIdList;
        for (const auto &idString : locations.split(","))
            locationIdList.append(idString.toInt());
        QString locationsName = location.fullNameList(locationIdList);

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
                            .tableRow
                            .arg(crop
                                 + (showPlantingSuccessionNumber ? QString(" %1").arg(successionNumber)
                                                                 : ""))
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

QString Print::calendarHtml(int year, int week, bool showDone, bool showDue, bool showOverdue) const
{
    auto showPlantingSuccessionNumber = m_settings->value("showPlantingSuccessionNumber").toBool();

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

    int lastTaskTypeId = -1;
    int i = 0;
    while (query.next()) {
        QDate assignedDate = QDate::fromString(query.value("assigned_date").toString(), Qt::ISODate);
        QDate completedDate = QDate::fromString(query.value("completed_date").toString(), Qt::ISODate);

        bool done = completedDate.isValid() && completedDate.weekNumber() == week;
        bool overdue = assignedDate.weekNumber() < week && !completedDate.isValid();
        bool due = assignedDate.weekNumber() == week && !completedDate.isValid();

        if ((!showDone || !done) && (!showDue || !due) && (!showOverdue || !overdue))
            continue;

        int taskId = query.value("task_id").toInt();
        int taskTypeId = query.value("task_type_id").toInt();
        const auto taskType = query.value("type").toString();
        const auto plantingIdList = m_task->taskPlantings(taskId);
        const auto locationIdList = m_task->taskLocations(taskId);

        const auto taskMethod = query.value("method").toString();
        const auto taskImplement = query.value("implement").toString();
        const auto description = query.value("description").toString();

        if (taskTypeId != lastTaskTypeId) {
            i = 0;
            lastTaskTypeId = taskTypeId;
            html += QString("<tr><td class='type' colspan=6>%1</td></tr>").arg(taskType);
        }

        int j = 0;

        bool useStandardBedLength = m_settings->value("useStandardBedLength").toBool();
        int standardBedLength = m_settings->value("standardBedLength").toInt();

        // Plantings
        for (const int plantingId : plantingIdList) {
            auto record = m_planting->recordFromId("planting_view", plantingId);
            auto locationList = Helpers::listOfInt(record.value("locations").toString());
            QString locationsName = m_location->fullNameList(locationList);

            int successionNumber = record.value("planting_rank").toInt();
            auto keywordStringList = m_keyword->keywordStringList(plantingId);

            QString keywordString;
            for (const auto &variant : keywordStringList) {
                keywordString.append(variant.toString());
                keywordString.append(", ");
            }
            if (!keywordString.isEmpty())
                keywordString.chop(2);

            int length = record.value("length").toInt();
            QString lengthString;
            if (useStandardBedLength)
                lengthString = tr("%1 beds").arg(length * 1.0 / standardBedLength);
            else
                lengthString = tr("%1 bed m.").arg(length);

            QString plantingString =
                    QString("%1%2, %3")
                            .arg(record.value("crop").toString())
                            .arg(showPlantingSuccessionNumber ? QString(" %1").arg(successionNumber) : "")
                            .arg(record.value("variety").toString());

            html += QString("<tr style='font-weight: %1; text-decoration: %2; "
                            "background-color: %3'>")
                            .arg(overdue ? "bold" : "normal")
                            .arg(done ? "line-through" : "none")
                            .arg(i % 2 == 1 ? "#e0e0e0" : "white");

            if (j == 0) {
                QString dateString("");
                if (done) {
                    dateString = MDate::formatDate(completedDate, year);
                    if (completedDate.weekNumber() != assignedDate.weekNumber())
                        dateString.append(" (" + MDate::formatDate(assignedDate, year) + ")");
                } else if (overdue) {
                    dateString = "(" + MDate::formatDate(assignedDate, year) + ")";
                }
                html += calendarInfo.tableRow.arg(dateString)
                                .arg(plantingString)
                                .arg(locationsName)
                                .arg(m_task->description(taskId, year))
                                .arg(keywordString)
                                .arg(description);
            } else {
                html += calendarInfo.tableRow.arg("")
                                .arg(plantingString)
                                .arg(locationsName)
                                .arg("\"")
                                .arg(keywordString)
                                .arg(description);
            }
            j++;
        }

        if (plantingIdList.empty()) {
            QString locationsName = m_location->fullNameList(locationIdList);

            html += QString("<tr style='font-weight: %1; text-decoration: %2; "
                            "background-color: %3'>")
                            .arg(overdue ? "bold" : "normal")
                            .arg(done ? "line-through" : "none")
                            .arg(i % 2 == 1 ? "#e0e0e0" : "white");

            QString dateString("");
            if (done) {
                dateString = MDate::formatDate(completedDate, year);
                if (completedDate.weekNumber() != assignedDate.weekNumber())
                    dateString.append(" (" + MDate::formatDate(assignedDate, year) + ")");
            } else if (overdue) {
                dateString = "(" + MDate::formatDate(assignedDate, year) + ")";
            }

            html += calendarInfo.tableRow.arg(dateString)
                            .arg("")
                            .arg(locationsName)
                            .arg(m_task->description(taskId, year))
                            .arg("")
                            .arg(description);
        }

        i++;
    }
    html += "</table>";
    return html;
}

QString Print::harvestHtml(int year) const
{
    auto showPlantingSuccessionNumber = m_settings->value("showPlantingSuccessionNumber").toBool();
    QString html = harvestInfo.title.arg(year);
    html.append(harvestInfo.tableHeader);

    QString queryString = harvestQueryString.arg(year);
    queryString.append(harvestInfo.plantingTypeClause);
    queryString.append(harvestInfo.orderClause);
    QSqlQuery query(queryString);

    int i = 0;
    while (query.next()) {
        QString dateString = query.value("date").toString();
        QDate date = QDate::fromString(dateString, Qt::ISODate);
        QString crop = query.value("crop").toString();
        QString variety = query.value("variety").toString();
        QString unit = query.value("unit").toString();
        double quantity = query.value("quantity").toDouble();
        QString laborTime = query.value("time").toString();
        QString locationString = query.value("locations").toString();
        int plantingId = query.value("planting_id").toInt();
        int successionNumber = m_planting->rank(plantingId);

        QList<int> locationIdList;
        for (const auto &idString : locationString.splitRef(","))
            locationIdList.append(idString.toInt());

        if (i % 2 == 0)
            html.append("<tr style='background-color: #e0e0e0'>");
        else
            html.append("<tr>");

        html += harvestInfo.tableRow
                        .arg(QString("%1 %2")
                                     .arg(MDate::formatDate(date, year, "", false))
                                     .arg(date.toString("ddd")))
                        .arg(QString("%1%2, %3")
                                     .arg(crop)
                                     .arg(showPlantingSuccessionNumber
                                                  ? QString(" %1").arg(successionNumber)
                                                  : "")
                                     .arg(variety))
                        .arg(m_location->fullNameList(locationIdList))
                        .arg(QString("%1 %2").arg(quantity).arg(unit))
                        .arg(laborTime);
        i++;
    }

    return html;
}

void Print::printCropMap(int year, int season, const QUrl &path, bool showFamilyColor,
                         bool showOnlyGreenhouse)
{
    QElapsedTimer timer;
    timer.start();

    QPdfWriter writer(path.toLocalFile());
    writer.setPageSize(QPagedPaintDevice::A4);
    writer.setPageOrientation(QPageLayout::Landscape);
    writer.setPageMargins(QMargins(10, 10, 10, 10), QPageLayout::Millimeter);

    QPainter painter;
    painter.begin(&writer);

    QFont font("Roboto Condensed", 11);
    painter.setFont(font);

    QPen pen;
    pen.setWidth(10);
    pen.setStyle(Qt::SolidLine);
    pen.setBrush(QColor("grey"));
    painter.setPen(pen);

    if (!m_locationModel)
        m_locationModel = new LocationModel(this);

    m_locationModel->refresh();
    m_locationModel->setFilterYear(year);
    m_locationModel->setFilterSeason(season);
    m_locationModel->setShowOnlyGreenhouseLocations(showOnlyGreenhouse);

    m_showFamilyColor = showFamilyColor;
    m_pageNumber = 1;
    paintHeader(painter, season, year);
    paintTree(writer, painter, QModelIndex(), season, year);

    painter.end();
    qDebug() << "[Crop map]" << timer.elapsed() << "ms";
}

void Print::paintHeader(QPainter &painter, int season, int year)
{
    QRectF headerRect(0, 0, m_firstColumnWidth + 12 * m_monthWidth, m_rowHeight);

    painter.save();
    painter.drawText(headerRect, Qt::AlignLeft,
                     QString("%1 %2").arg(MDate::seasonName(season)).arg(year));
    painter.drawText(headerRect, Qt::AlignRight, QString::number(m_pageNumber));
    painter.restore();

    painter.translate(0, m_rowHeight);

    QRectF locationRect(0, 0, m_firstColumnWidth, m_rowHeight);
    painter.drawRect(locationRect);
    painter.drawText(locationRect.adjusted(m_textPadding, 0, 0, 0), Qt::AlignVCenter, tr("Location"));
    for (int m = 0; m < 12; m++) {
        QRectF rect(m_firstColumnWidth + m * m_monthWidth, 0, m_monthWidth, m_rowHeight);
        painter.drawRect(rect);
        painter.drawText(rect, Qt::AlignCenter,
                         MDate::shortMonthName(1 + MDate::monthsOrder[season][m]));
    }
    painter.translate(0, m_rowHeight);
}

void Print::paintRowGrid(QPainter &painter, int rows)
{
    const int height = rows * m_rowHeight;
    painter.drawRect(0, 0, m_firstColumnWidth, height);
    for (int m = 0; m < 12; m++) {
        QRectF rect(m_firstColumnWidth + m * m_monthWidth, 0, m_monthWidth, height);
        painter.drawRect(rect);
    }
    painter.translate(0, height);
}

int Print::datePosition(const QDate &date)
{
    int x = 0;
    std::pair<QDate, QDate> seasonDates = m_locationModel->seasonDates();
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

void Print::paintPlantingTimegraph(QPainter &painter, int plantingId, int year)
{
    const auto record = m_planting->recordFromId("planting_view", plantingId);
    const auto plantingDate = MDate::dateFromIsoString(record.value("planting_date").toString());
    QDate begHarvestDate = MDate::dateFromIsoString(record.value("beg_harvest_date").toString());
    QDate endHarvestDate = MDate::dateFromIsoString(record.value("end_harvest_date").toString());
    auto showPlantingSuccessionNumber = m_settings->value("showPlantingSuccessionNumber").toBool();

    QString colorString;

    if (m_showFamilyColor)
        colorString = record.value("family_color").toString();
    else
        colorString = record.value("crop_color").toString();

    const QColor cropColor(colorString);
    const auto cropName = record.value("crop").toString().left(2);
    const auto varietyName = record.value("variety").toString();
    const int successionNumber = record.value("planting_rank").toInt();

    //    const int y = (2 + row) * m_rowHeight;
    const int y = 0;
    const int p = static_cast<int>(m_rowHeight * 0.1);

    const QPoint point1(datePosition(plantingDate), y + p);
    const QPoint point2(datePosition(begHarvestDate), y + m_rowHeight - p);
    const QPoint point3(datePosition(begHarvestDate), y + p);
    const QPoint point4(datePosition(endHarvestDate), y + m_rowHeight - p);

    const auto growRect(QRectF(point1, point2));
    const auto harvestRect(QRectF(point3, point4));

    painter.fillRect(growRect, cropColor);
    painter.fillRect(harvestRect, cropColor.darker(120));

    painter.save();

    QPen pen(QColor("white"));
    painter.setPen(pen);

    if (growRect.width() > m_monthWidth * 0.3) {
        QFontMetrics fm(painter.font());
        auto description =
                QString("%1 %2%3, %4")
                        .arg(MDate::formatDate(plantingDate, year, "", false))
                        .arg(cropName)
                        .arg(showPlantingSuccessionNumber ? QString(" %1").arg(successionNumber) : "")
                        .arg(varietyName);
        auto descriptionRect = growRect.adjusted(m_textPadding, 0, -m_textPadding, 0);

        painter.drawText(descriptionRect, Qt::AlignVCenter,
                         fm.elidedText(description, Qt::ElideRight,
                                       static_cast<int>(descriptionRect.width())));
    }

    if (harvestRect.width() > m_monthWidth * 0.2) {
        painter.drawText(harvestRect.adjusted(m_textPadding, 0, 0, 0), Qt::AlignVCenter,
                         MDate::formatDate(begHarvestDate, year, "", false));
        // Print end harvest date if there is enough space and the date is in the current season.
        if ((harvestRect.width() > m_monthWidth * 0.5)
            && (endHarvestDate <= m_locationModel->seasonDates().second)) {
            painter.drawText(QRectF(point3, point4).adjusted(0, 0, -m_textPadding, 0),
                             Qt::AlignVCenter | Qt::AlignRight,
                             MDate::formatDate(endHarvestDate, year, "", false));
        }
    }

    painter.restore();
}

void Print::paintTaskTimeGraph(QPainter &painter, int taskId, int rows)
{
    const auto record = m_task->recordFromId("task_view", taskId);

    const int duration = record.value("duration").toInt();
    if (duration < 1)
        return;

    const QDate assignedDate = MDate::dateFromIsoString(record.value("assigned_date").toString());
    const QDate taskEndDate = assignedDate.addDays(duration);
    const QString type = record.value("type").toString();
    const QString color = record.value("color").toString();

    const int t = static_cast<int>(m_rowHeight * 0.1);
    const int b = t;

    const int pos1 = datePosition(assignedDate);
    const int pos2 = datePosition(taskEndDate);
    const QPoint point1(pos1, t);
    const QPoint point2(pos2, (rows * m_rowHeight) - b);
    const QRectF rect(point1, point2);

    if (rect.width() == 0.0)
        return;

    QFontMetrics fm(painter.font());
    bool wideEnough = rect.width() > (0.3 * m_monthWidth);
    bool simpleLine = rect.width() < (0.1 * m_monthWidth);

    QPainterPath path;
    path.addRoundRect(rect, 10.0, 0.0);
    auto rectColor = QColor(color);
    rectColor.setAlphaF(0.8);
    painter.fillPath(path, rectColor);

    painter.save();
    const QPen pen(simpleLine ? QColor("black") : QColor("white"));

    painter.setPen(pen);
    if (simpleLine) {
        auto center = rect.translated(0.1 * m_monthWidth, 0).center();
        painter.translate(center);
        painter.rotate(-90);
        painter.drawText(QRect(-1000, -1000, 2000, 2000), Qt::AlignCenter, Helpers::acronymize(type));
        painter.rotate(90);
    } else if (wideEnough) {
        painter.drawText(rect.adjusted(m_textPadding, 0, -m_textPadding, 0), Qt::AlignVCenter,
                         Helpers::acronymize(type));
    } else {
        painter.translate(rect.center());
        painter.rotate(-90);
        painter.drawText(QRect(-1000, -1000, 2000, 2000), Qt::AlignCenter, Helpers::acronymize(type));
        painter.rotate(90);
    }

    painter.restore();
}

void Print::paintTimeline(QPainter &painter, QVariantList plantingList, QVariantList taskList, int year)
{
    int plantingLength = plantingList.count();
    for (const auto &list : plantingList) {
        for (int plantingId : Helpers::variantToIntList(list.toList()))
            paintPlantingTimegraph(painter, plantingId, year);
        painter.translate(0, m_rowHeight);
    }

    int taskLength = 0;
    if (m_settings->value("LocationView/showTasks", false).toBool()) {
        taskLength = taskList.length();
        painter.translate(0, -plantingLength * m_rowHeight);

        int i = 0;
        for (; i < plantingLength; ++i) {
            const auto &list = taskList[i];
            for (int taskId : Helpers::variantToIntList(list.toList()))
                paintTaskTimeGraph(painter, taskId);
            painter.translate(0, m_rowHeight);
        }

        // draw location tasks
        if (taskLength > plantingLength) {
            int rows = std::max(1, plantingLength);
            painter.translate(0, -plantingLength * m_rowHeight);
            const auto &list = taskList[i];
            for (int taskId : Helpers::variantToIntList(list.toList()))
                paintTaskTimeGraph(painter, taskId, rows);
            painter.translate(0, rows * m_rowHeight);
        }
    }

    if (!plantingLength && !taskLength)
        painter.translate(0, m_rowHeight);
}

void Print::breakPage(QPagedPaintDevice &printer, QPainter &painter)
{
    printer.newPage();
    m_pageNumber++;
    painter.translate(-painter.transform().dx(), -painter.transform().dy());
    //    drawTitle();
}

void Print::paintRow(QPagedPaintDevice &printer, QPainter &painter, const QModelIndex &index,
                     int season, int year)
{
    int locationId = m_locationModel->locationId(index);
    auto plantingList = m_locationModel->nonOverlappingPlantingList(index);
    auto taskList = m_locationModel->nonOverlappingTaskList(index);
    int rows = std::max({ 1, plantingList.count(), taskList.count() });

    // Begin from new page if there is not enough space left on the current page.
    if ((painter.transform().dy() + rows * m_rowHeight) > painter.viewport().height()) {
        breakPage(printer, painter);
        paintHeader(painter, season, year);
    }

    // Paint grid and go backward.
    paintRowGrid(painter, rows);
    painter.translate(0, -rows * m_rowHeight);

    // Paint location's name.
    QRectF locationRect(0, 0, m_firstColumnWidth, m_rowHeight);
    painter.drawText(locationRect.adjusted(m_textPadding, 0, 0, 0), Qt::TextWordWrap,
                     m_location->fullName(locationId));

    paintTimeline(painter, plantingList, taskList, year);
}

void Print::paintTree(QPagedPaintDevice &printer, QPainter &painter, const QModelIndex &parent,
                      int season, int year)
{
    for (int row = 0; row < m_locationModel->rowCount(parent); row++) {
        QModelIndex index = m_locationModel->index(row, 0, parent);
        if (m_locationModel->hasChildren(index))
            paintTree(printer, painter, index, season, year);
        else
            paintRow(printer, painter, index, season, year);
    }
}
