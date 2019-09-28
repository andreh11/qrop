#include "listmodel.h"

IntListModel::IntListModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int IntListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

int IntListModel::columnCount(const QModelIndex &parent) const
{
    if (!parent.isValid())
        return 0;
    if (parent.row() < 0 || parent.row() >= m_list.count())
        return 0;

    return m_list[parent.row()].count();
}

QVariant IntListModel::data(const QModelIndex &index, int role) const
{
    Q_UNUSED(role)
    if (!index.isValid())
        return {};
    if (index.row() < 0 || (index.row() >= m_list.count()))
        return {};
    if (index.column() > m_list[index.row()].count())
        return {};

    return m_list[index.row()][index.column()];
}

void IntListModel::addList()
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    QList<int> list;
    m_list.push_back(list);
    endInsertRows();
}

void IntListModel::addItem(int row, int item)
{
    if (row < 0 || row >= m_list.count())
        return;

    const QModelIndex &idx = index(row, 0);
    m_list[row].push_back(item);
    emit dataChanged(idx, idx);
}
