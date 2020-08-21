#include "recordmodel.h"

#include <QDebug>
#include <QSqlRecord>
#include <QSqlError>
#include <QSqlQuery>

RecordModel::RecordModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
{
    sort(0);
}

// bool RecordModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
//{
//    int leftCrop = sourceRowValue(left.row(), left.parent(), "planting_id").toInt();
//    int rightCrop = sourceRowValue(right.row(), right.parent(), "planting_id").toInt();

//    return leftCrop < rightCrop;
//}

bool RecordModel::inYear(int sourceRow, const QModelIndex &sourceParent) const
{
    QDate date = sourceFieldDate(sourceRow, sourceParent, "date");
    return QDate(m_year, 1, 1) <= date && date <= QDate(m_year, 12, 31);
}

bool RecordModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    return inYear(sourceRow, sourceParent)
            && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}
