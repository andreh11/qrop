#include "notemodel.h"

#include <QDebug>
#include <QSqlRecord>
#include <QSqlError>
#include <QSqlQuery>

NoteModel::NoteModel(QObject *parent, const QString &tableName)
    : SortFilterProxyModel(parent, tableName)
    , m_plantingId(-1)

{
}

int NoteModel::plantingId() const
{
    return m_plantingId;
}

void NoteModel::setPlantingId(int plantingId)
{
    if (m_plantingId == plantingId)
        return;

    m_plantingId = plantingId;
    qDebug() << "New plantingId:" << m_plantingId;
    invalidateFilter();
    emit plantingIdChanged();
}

bool NoteModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    if (m_plantingId < 0)
        return SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
    int plantingId = rowValue(sourceRow, sourceParent, "planting_id").toInt();
    qDebug() << plantingId;
    return plantingId == m_plantingId
            && SortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}
