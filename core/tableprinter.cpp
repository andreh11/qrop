/****************************************************************************
**
** Copyritgh (c) 2019, André Hoarau <ah@ouvaton.org>
** Copyright (c) 2016, Anton Onishchenko
** All rights reserved.
**
** Redistribution and use in source and binary forms, with or without modification,
** are permitted provided that the following conditions are met:
**
** 1. Redistributions of source code must retain the above copyright notice, this
** list of conditions and the following disclaimer.
**
** 2. Redistributions in binary form must reproduce the above copyright notice, this
** list of conditions and the following disclaimer in the documentation and/or other
** materials provided with the distribution.
**
** 3. Neither the name of the copyright holder nor the names of its contributors may
** be used to endorse or promote products derived from this software without
** specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
**  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
** ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************/

#include <cmath>

#include <QAbstractItemModel>
#include <QPainter>
#include <QPrinter>
#include <QPagedPaintDevice>

#include "tableprinter.h"
#include "sortfilterproxymodel.h"
#include "mdate.h"
#include "location.h"
#include "helpers.h"

TablePrinter::TablePrinter(QPainter *painter, QPagedPaintDevice *printer)
    : m_model(nullptr)
    , m_location(new Location())
    , m_painter(painter)
    , m_printer(printer)
{
    m_pen = painter->pen();

    m_pen.setWidth(10);
    m_pen.setStyle(Qt::SolidLine);
    m_pen.setBrush(QColor("black"));

    m_titleFont = painter->font();
    m_titleFont.setBold(true);
    m_titleFont.setPointSize(14);

    m_headersFont = painter->font();
    m_headersFont.setBold(true);

    m_contentFont = painter->font();

    m_headerColor = painter->pen().color();
    m_contentColor = painter->pen().color();

    setTableWidth();
}

void TablePrinter::setModel(SortFilterProxyModel *model)
{
    if (model == m_model)
        return;
    m_model = model;
}

void TablePrinter::setTitle(const QString &title)
{
    if (m_title == title)
        return;

    m_title = title;
}

QString TablePrinter::title() const
{
    return m_title;
}

void TablePrinter::setYear(int year)
{
    if (m_year == year)
        return;
    m_year = year;
}

int TablePrinter::year() const
{
    return m_year;
}

void TablePrinter::setTableInfo(const TableInfo &tableInfo)
{
    m_tableInfo = tableInfo;
    setTotalStretch();
}

void TablePrinter::setTableWidth()
{
    m_tableWidth = m_painter->viewport().width() - m_leftBlank - m_rightBlank;
}

void TablePrinter::setTotalStretch()
{
    m_totalStretch = 0;
    for (const auto &info : m_tableInfo)
        m_totalStretch += info.stretch;
}

QString TablePrinter::lastError()
{
    return m_error;
}

void TablePrinter::setCellMargin(int left, int right, int top, int bottom)
{
    m_topMargin = top;
    m_bottomMargin = bottom;
    m_leftMargin = left;
    m_rightMargin = right;
}

void TablePrinter::setPageMargin(int left, int right, int top, int bottom)
{
    m_headerHeight = top;
    m_bottomHeight = bottom;
    m_leftBlank = left;
    m_rightBlank = right;
    setTableWidth();
}

void TablePrinter::setPen(const QPen &pen)
{
    m_pen = pen;
}

void TablePrinter::setHeadersFont(const QFont &f)
{
    m_headersFont = f;
}

void TablePrinter::setContentFont(const QFont &f)
{
    m_contentFont = f;
}

void TablePrinter::setHeaderColor(const QColor &color)
{
    m_headerColor = color;
}

void TablePrinter::setContentColor(const QColor &color)
{
    m_contentColor = color;
}

void TablePrinter::setMaxRowHeight(int height)
{
    m_maxRowHeight = height;
}

void TablePrinter::drawTitle()
{
    m_painter->save();
    m_painter->setFont(m_titleFont);

    QRectF rect(0, 0, m_tableWidth, m_rowHeight);
    m_painter->drawText(rect.adjusted(m_leftMargin, m_topMargin, -m_rightMargin, -m_bottomMargin),
                        Qt::AlignLeft | Qt::AlignVCenter, m_title);
    m_painter->drawText(rect.adjusted(m_leftMargin, m_topMargin, -m_rightMargin, -m_bottomMargin),
                        Qt::AlignRight | Qt::AlignVCenter, QString::number(m_pageNumber + 1));

    m_painter->restore();
    m_painter->translate(0, m_rowHeight);
}

void TablePrinter::drawHeader()
{
    m_painter->save();
    m_painter->setFont(m_headersFont);

    QRectF rect(0, 0, 0, m_rowHeight);
    QString string;
    for (const auto &colInfo : m_tableInfo) {
        int flags = Qt::AlignVCenter | Qt::TextWordWrap;
        if (colInfo.type == TablePrinter::Weight || colInfo.type == TablePrinter::Number)
            flags |= Qt::AlignRight;

        string = colInfo.header;
        rect.adjust(rect.width(), 0, (colInfo.stretch * 1.0 / m_totalStretch) * m_tableWidth, 0);
        m_painter->drawText(rect.adjusted(m_leftMargin, m_topMargin, -m_rightMargin, -m_bottomMargin),
                            flags, string);
    }

    m_painter->restore();
    m_painter->translate(0, m_rowHeight);
}

void TablePrinter::drawSection(const QString &string)
{
    m_painter->save();

    m_pen.setBrush(QColor("white"));
    m_painter->setPen(m_pen);

    QRectF rect(0, 0, m_tableWidth, m_rowHeight);
    m_painter->fillRect(rect, QColor("#424242"));
    m_painter->drawText(rect.adjusted(m_leftMargin, m_topMargin, -m_rightMargin, -m_bottomMargin),
                        Qt::AlignVCenter | Qt::TextWordWrap, string);

    m_painter->restore();
    m_painter->translate(0, m_rowHeight);
}

void TablePrinter::drawRow(int row)
{
    QRectF rect(0, 0, 0, m_rowHeight);
    QVariant value;
    QString string;

    for (const auto &colInfo : m_tableInfo) {
        value = m_model->rowValue(row, colInfo.name);

        int flags = Qt::AlignVCenter | Qt::TextWordWrap;
        switch (colInfo.type) {
        case TablePrinter::Weight: {
            bool ok = true;
            double weight = value.toDouble(&ok);
            if (qIsInf(weight)) {
                string = "−";
            } else if (weight >= 1000) {
                weight = std::ceil(weight / 10) / 100;
                string = QString("%L1 kg").arg(weight);
            } else {
                string = QString("%L1 g").arg(std::ceil(weight * 10) / 10);
            }
            flags |= Qt::AlignRight;
            break;
        }
        case TablePrinter::Number:
            string = QString("%L1").arg(value.toDouble());
            flags |= Qt::AlignRight;
            break;
        case TablePrinter::Week: {
            QDate date = MDate::dateFromIsoString(value.toString());
            string = MDate::formatDate(date, m_year);
            break;
        }
        case TablePrinter::Locations: {
            string = m_location->fullNameList(Helpers::listOfInt(value.toString()));
            break;
        }
        default:
            string = value.toString();
        }

        rect.adjust(rect.width(), 0, (colInfo.stretch * 1.0 / m_totalStretch) * m_tableWidth, 0);
        if (row % 2 == 1)
            m_painter->fillRect(rect, QColor("#EEEEEE"));

        m_painter->drawText(rect.adjusted(m_leftMargin, m_topMargin, -m_rightMargin, -m_bottomMargin),
                            flags, string);
    }

    m_painter->translate(0, m_rowHeight);
}

void TablePrinter::breakPage()
{
    m_printer->newPage();
    m_pageNumber++;
    m_painter->translate(-m_painter->transform().dx() + m_leftBlank,
                         -m_painter->transform().dy() + m_headerHeight);
    drawTitle();
}

QVariant TablePrinter::sectionValue(int row, const QString &sectionName) const
{
    if (sectionName == "month")
        return MDate::monthName(m_model->rowValue(row, sectionName).toInt());
    return m_model->rowValue(row, sectionName);
}

bool TablePrinter::printTable(const QString &sectionName, bool pageBreak)
{
    if (!m_model)
        return false;

    if (m_model->rowCount() < 1)
        return true;

    bool useSection = !sectionName.isEmpty();
    m_pageNumber = 0;
    QVariant section;

    drawTitle();
    drawHeader();
    if (useSection) {
        section = sectionValue(0, sectionName);
        drawSection(section.toString());
    }
    drawRow(0);

    QVariant s;
    for (int row = 1; row < m_model->rowCount(); row++) {
        if (useSection) {
            s = sectionValue(row, sectionName);
            if (section != s) {
                section = s;
                if (pageBreak) {
                    breakPage();
                    drawHeader();
                }
                drawSection(s.toString());
            }
        }

        drawRow(row);
        if ((m_painter->transform().dy() + m_rowHeight + m_topMargin + m_bottomMargin)
            > (m_painter->viewport().height() - m_bottomHeight)) { // begin from new page
            breakPage();
            drawHeader();
        }
    }

    return true;
}
