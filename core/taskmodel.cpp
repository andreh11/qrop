#include "taskmodel.h"

#include <QSqlRecord>
#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>

static const char *taskTableName = "tasks_view";

TaskModel::TaskModel(QObject *parent)
    : QSqlTableModel(parent)
{
    m_date = QDate();

    setTable(taskTableName);
    setSort(2, Qt::AscendingOrder);
    setEditStrategy(QSqlTableModel::OnManualSubmit);
//    setDate(QDate::currentDate());
    select();
    qInfo("%d", rowCount());
}

QDate TaskModel::date() const
{
    return m_date;
}

void TaskModel::setDate(const QDate &date)
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

QVariant TaskModel::data(const QModelIndex &index, int role) const
{
    if (role < Qt::UserRole)
        return QSqlTableModel::data(index, role);

    const QSqlRecord sqlRecord = record(index.row());
    return sqlRecord.value(role - Qt::UserRole);
}

QHash<int, QByteArray> TaskModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    for (int i = 0; i < this->record().count(); i ++)
        roles.insert(Qt::UserRole + i, record().fieldName(i).toUtf8());

    return roles;
}
