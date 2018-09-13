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

void TaskModel::createTasks(int plantingId, const QDate &plantingDate)
{
    qDebug() << "[TaskModel] Creating tasks for planting: " << plantingId << plantingDate;
    // TODO
    // Compute dates
    // Link 'em all to GH/field sowing date
}

void TaskModel::updateTaskDates(int plantingId, const QDate &plantingDate)
{
    qDebug() << "[TaskModel] Creating tasks for planting: " << plantingId << plantingDate;
    // TODO
}

int TaskModel::duplicateTasks(int sourcePlantingId, int newPlantingId)
{
    // TODO
    qDebug() << "[TaskModel] Duplicate tasks of planting" << sourcePlantingId
             << "for" << newPlantingId;
    return -1;
}

void TaskModel::removeTasks(int plantingId)
{
    qDebug() << "[TaskModel] Removing tasks for planting: " << plantingId;
    QString queryString("DELETE FROM planting_task WHERE planting_id = %1");
    QSqlQuery query(queryString.arg(plantingId));
    debugQuery(query);
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
