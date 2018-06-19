#include "sqltaskmodel.h"

#include <QSqlRecord>
#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>

static const char *taskTableName = "tasks_view";

SqlTaskModel::SqlTaskModel(QObject *parent)
    : QSqlTableModel(parent)
{
    m_date = QDate();

    setTable(taskTableName);
    setSort(2, Qt::AscendingOrder);
    setEditStrategy(QSqlTableModel::OnManualSubmit);
    setDate(QDate::currentDate());
    select();
    qInfo("%d", rowCount());
}

QDate SqlTaskModel::date() const
{
    return m_date;
}

void SqlTaskModel::setDate(const QDate &date)
{
    if (date == m_date)
        return;

    m_date = date;

    const QString filterString = QString::fromLatin1(
                "date_assigned = %1").arg("2018-06-16");
//                "date_assigned = %1").arg(date.toString(Qt.ISODate));
    setFilter(filterString);
    select();

    emit dateChanged();
}

QVariant SqlTaskModel::data(const QModelIndex &index, int role) const
{
    if (role < Qt::UserRole)
        return QSqlTableModel::data(index, role);

    const QSqlRecord sqlRecord = record(index.row());
    return sqlRecord.value(role - Qt::UserRole);
}

QHash<int, QByteArray> SqlTaskModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[Qt::UserRole] = "task_id";
    names[Qt::UserRole + 1] = "task";
    names[Qt::UserRole + 2] = "date_assigned";
    names[Qt::UserRole + 3] = "date_completed";
    names[Qt::UserRole + 4] = "duration";
    names[Qt::UserRole + 5] = "on_ground";
    names[Qt::UserRole + 6] = "labor_time";
    names[Qt::UserRole + 7] = "descr";
    names[Qt::UserRole + 8] = "planting_ids";
    names[Qt::UserRole + 9] = "place_ids";

    return names;
}
