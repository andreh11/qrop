#include "taskmodel.h"

#include <QSqlRecord>
#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>

static const char *taskTableName = "tasks_view";

TaskModel::TaskModel(QObject *parent)
    : SqlTableModel(parent)
{
    m_filterDate = QDate();

    setTable(taskTableName);
    setSort(2, Qt::AscendingOrder);
    setEditStrategy(QSqlTableModel::OnManualSubmit);
    setFilterDate(QDate::currentDate());
    select();
}

QDate TaskModel::date() const
{
    return m_filterDate;
}

void TaskModel::setFilterDate(const QDate &date)
{
    if (date == m_filterDate)
        return;

    m_filterDate = date;

    const QString filterString = QString::fromLatin1(
                "date_assigned = %1").arg(date.toString(Qt::ISODate));
    setFilter(filterString);
    select();

    emit dateChanged();
}
