/****************************************************************************
**
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

#ifndef TABLEPRINTER_H
#define TABLEPRINTER_H

#include <QPen>
#include <QFont>
#include <functional>

class QPagedPaintDevice;
class QPainter;
class SortFilterProxyModel;

class TablePrinter
{
public:
    enum ColumnType { String, Weight, Number, Week };

    using ColumnInfo = struct {
        QString name;
        QString header;
        int stretch;
        ColumnType type;
    };
    using TableInfo = QVector<ColumnInfo>;

    TablePrinter(QPainter *m_painter, QPagedPaintDevice *m_printer);

    bool printTable(const QString &sectionName = "", bool pageBreak = true);

    QString lastError();
    void setCellMargin(int left, int right, int top, int bottom);
    void setPageMargin(int left, int right, int top, int bottom);
    void setPen(const QPen &pen); // for table borders
    void setHeadersFont(const QFont &font);
    void setContentFont(const QFont &font);
    void setHeaderColor(const QColor &color);
    void setContentColor(const QColor &color);
    void setMaxRowHeight(int height);

    void setModel(SortFilterProxyModel *model);
    void setTableInfo(const TableInfo &tableInfo);

    void setTitle(const QString &title);
    QString title() const;

    void setYear(int year);
    int year() const;

private:
    SortFilterProxyModel *m_model;
    TableInfo m_tableInfo;

    QPainter *m_painter;
    QPagedPaintDevice *m_printer;
    QPen m_pen; // for table borders
    QFont m_titleFont;
    QFont m_headersFont;
    QFont m_contentFont;

    QColor m_headerColor;
    QColor m_contentColor;

    QString m_title;
    int m_year { 0 };

    // cell margins
    int m_topMargin { 50 };
    int m_bottomMargin { 50 };
    int m_leftMargin { 100 };
    int m_rightMargin { 100 };

    // margins for table
    int m_headerHeight { 0 };
    int m_bottomHeight { 0 };
    int m_leftBlank { 0 };
    int m_rightBlank { 0 };

    int m_rowHeight { 400 };
    int m_maxRowHeight { 1000 };

    int m_tableWidth { 0 };
    int m_totalStretch { 0 };

    int m_pageNumber { 0 };

    QString m_error { "No error" };

    void drawTitle();
    void drawHeader();
    void drawSection(const QString &string);
    void drawRow(int row);
    void breakPage();

    void setTableWidth();
    void setTotalStretch();
};

#endif // TABLEPRINTER_H
