/*
 * Copyright (C) 2018 André Hoarau <ah@ouvaton.org>
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

#include <QSqlTableModel>
#include <QMap>
#include <QDebug>
#include <QDate>

#include "treemodel.h"
#include "sqltablemodel.h"

TreeItem::TreeItem(const QSqlRecord &record, TreeItem *parent)
    : m_record(record)
    , m_parent(parent)
{
}

TreeItem::~TreeItem()
{
    qDeleteAll(m_children);
}

void TreeItem::appendChild(TreeItem *item)
{
    m_children.push_back(item);
    item->m_parent = static_cast<TreeItem *>(this);
}

void TreeItem::removeChild(TreeItem *item)
{
    m_children.removeAll(item);
    item->m_parent = nullptr;
}

TreeItem *TreeItem::child(int row) const
{
    return m_children.value(row);
}

TreeItem *TreeItem::parent() const
{
    return m_parent;
}

int TreeItem::row() const
{
    if (m_parent)
        return m_parent->m_children.indexOf(const_cast<TreeItem *>(this));

    return 0;
}

QVariant TreeItem::data(int column) const
{
    if (m_record.isEmpty())
        return {};
    if (column >= m_record.count())
        return {};

    return m_record.value(column);
}

bool TreeItem::setData(int column, const QVariant &value)
{
    if (m_record.isEmpty())
        return false;
    if (column >= m_record.count())
        return false;

    m_record.setValue(column, value);
    return true;
}

int TreeItem::rowCount() const
{
    return m_children.count();
}

int TreeItem::columnCount() const
{
    return m_record.count();
}

SqlTreeModel::SqlTreeModel(const QString &idFieldName, const QString &parentIdFieldName, QObject *parent)
    : QAbstractItemModel(parent)
    , m_root(nullptr)
    , m_idFieldName(idFieldName)
    , m_parentIdFieldName(parentIdFieldName)
{
    SqlTableModel *model = new SqlTableModel();
    model->setTable("location");
    model->select();
    setSourceModel(model);
}

SqlTreeModel::~SqlTreeModel()
{
    delete m_root;
}

QModelIndex SqlTreeModel::index(int row, int column, const QModelIndex &parent) const
{
    if (!hasIndex(row, column, parent))
        return {};

    TreeItem *parentItem;
    if (!parent.isValid())
        parentItem = m_root;
    else
        parentItem = static_cast<TreeItem *>(parent.internalPointer());

    TreeItem *childItem = parentItem->child(row);
    if (childItem)
        return createIndex(row, column, childItem);

    return {};
}

QModelIndex SqlTreeModel::parent(const QModelIndex &index) const
{
    if (!index.isValid())
        return {};

    auto childItem = static_cast<TreeItem *>(index.internalPointer());
    TreeItem *parentItem = childItem->parent();

    if (!parentItem || parentItem == m_root)
        return {};

    return createIndex(parentItem->row(), 0, parentItem);
}

int SqlTreeModel::rowCount(const QModelIndex &parent) const
{
    if (parent.column() > 0) // As a convention, only first column has children.
        return 0;

    TreeItem *parentItem;
    if (!parent.isValid())
        parentItem = m_root;
    else
        parentItem = static_cast<TreeItem *>(parent.internalPointer());

    return parentItem->rowCount();
}

int SqlTreeModel::columnCount(const QModelIndex &parent) const
{
    if (!parent.isValid()) // Root item
        return m_root->columnCount();

    return static_cast<TreeItem *>(parent.internalPointer())->columnCount();
}

QVariant SqlTreeModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return {};
    if (index.row() < 0 || index.row() > rowCount(index.parent()))
        return {};

    auto item = static_cast<TreeItem *>(index.internalPointer());
    if (role < Qt::UserRole)
        return item->data(index.column());

    QVariant value = item->data(role - Qt::UserRole);
    QDate date = QDate::fromString(value.toString(), Qt::ISODate);
    if (date.isValid()) // fromString(string) returns invalid date if string cannot be parsed
        return date;
    return value;
}

QVariant SqlTreeModel::data(const QModelIndex &index, const QString &role) const
{
    if (m_rolesIndexes.find(role) == m_rolesIndexes.end())
        return QVariant();

    return data(index, m_rolesIndexes[role]);
}

bool SqlTreeModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid())
        return false;

    if (index.row() < 0 || index.row() > rowCount(index.parent()))
        return false;

    auto item = static_cast<TreeItem *>(index.internalPointer());
    if (role < Qt::UserRole)
        item->setData(index.column(), value);
    else
        item->setData(role - Qt::UserRole, value);
    return true;
}

bool SqlTreeModel::setData(const QModelIndex &index, const QVariant &value, const QString &role)
{
    if (m_rolesIndexes.find(role) == m_rolesIndexes.end())
        return false;

    return setData(index, value, m_rolesIndexes[role]);
}

Qt::ItemFlags SqlTreeModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return QAbstractItemModel::flags(index);
}

QVariant SqlTreeModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    Q_UNUSED(section)
    Q_UNUSED(orientation)
    Q_UNUSED(role)

    return m_sourceModel->record().fieldName(section);
}

QHash<int, QByteArray> SqlTreeModel::roleNames() const
{
    if (!m_sourceModel)
        return QAbstractItemModel::roleNames();

    QHash<int, QByteArray> roles;
    for (int i = 0; i < m_sourceModel->record().count(); i++)
        roles.insert(Qt::UserRole + i, m_sourceModel->record().fieldName(i).toUtf8());

    return roles;
}

void SqlTreeModel::buildRolesIndexes()
{
    for (int i = 0; i < m_sourceModel->record().count(); i++)
        m_rolesIndexes[m_sourceModel->record().fieldName(i).toUtf8()] = Qt::UserRole + i;
}

bool SqlTreeModel::removeRows(int row, int count, const QModelIndex &parent)
{
    qDebug() << "removeRows" << row << count << parent;

    TreeItem *parentItem;
    if (!parent.isValid())
        parentItem = m_root;
    else
        parentItem = static_cast<TreeItem *>(parent.internalPointer());

    int rrows = count; // rows to remove
    if (row + count > parentItem->rowCount())
        rrows = parentItem->rowCount() < row;

    beginRemoveRows(parent, row, row + rrows - 1);
    for (int i = 0; i < rrows; i++) {
        TreeItem *childItem = parentItem->child(row);
        parentItem->removeChild(childItem);
    }
    endRemoveRows();

    return true;
}

bool SqlTreeModel::removeIndexes(const QList<QModelIndex> &indexList)
{
    QVector<TreeItem *> children(indexList.count());
    QVector<TreeItem *> parents(indexList.count());
    int row;
    QModelIndex parent;
    QModelIndex index;

    // Get all child and parent TreeItems.
    for (int i = 0; i < indexList.count(); i++) {
        index = indexList[i];
        row = index.row();
        parent = index.parent();
        if (!parent.isValid())
            parents[i] = m_root;
        else
            parents[i] = static_cast<TreeItem *>(parent.internalPointer());
        children[i] = parents[i]->child(row);
    }

    int newRow = -1;
    for (int i = 0; i < indexList.count(); i++) {
        newRow = children[i]->row();
        if (parents[i]) {
            beginRemoveRows(indexList[i].parent(), newRow, newRow);
            parents[i]->removeChild(children[i]);
            endRemoveRows();
        }
    }
    return true;
}

bool SqlTreeModel::addRecord(const QSqlRecord &record, const QModelIndex &parent)
{
    if (!m_sourceModel)
        return false;
    if (record.isEmpty() || !record.contains(m_idFieldName) || !record.contains(m_parentIdFieldName))
        return false;

    int id = record.value(m_idFieldName).toInt();
    int parentId;
    if (record.isNull(m_parentIdFieldName)) // root item
        parentId = -1;
    else
        parentId = record.value(m_parentIdFieldName).toInt();

    if (!m_idItemMap.contains(parentId)) {
        qDebug() << "Parent " << parentId << "not added yet, cannot add child" << id;
        return false;
    }

    if (m_idItemMap.contains(id))
        return false;

    int count = m_idItemMap[parentId]->rowCount();
    beginInsertRows(parent, count, count);
    m_idItemMap[id] = new TreeItem(record);
    m_idItemMap[parentId]->appendChild(m_idItemMap[id]);
    endInsertRows();

    return true;
}

/*! Insert a subtree below \a parent whose root is the first item of
 * \a recordList. We assume that parent nodes appear before children.
 */
bool SqlTreeModel::addRecordTree(QList<QSqlRecord> &recordList, const QModelIndex &parent)
{
    if (!m_sourceModel)
        return false;
    if (recordList.isEmpty())
        return true;

    auto rootRecord = recordList.takeFirst();
    int rootId = rootRecord.value(m_idFieldName).toInt();
    int rootParentId;
    if (rootRecord.isNull(m_parentIdFieldName)) // root item
        rootParentId = -1;
    else
        rootParentId = rootRecord.value(m_parentIdFieldName).toInt();

    int count = m_idItemMap[rootParentId]->rowCount();
    beginInsertRows(parent, count, count);
    m_idItemMap[rootId] = new TreeItem(rootRecord);
    m_idItemMap[rootParentId]->appendChild(m_idItemMap[rootId]);

    // Create tree items.
    for (auto record : recordList) {
        if (record.isEmpty() || !record.contains(m_idFieldName) || !record.contains(m_parentIdFieldName))
            continue;

        int id = record.value(m_idFieldName).toInt();
        int parentId;
        if (record.isNull(m_parentIdFieldName)) // root item
            parentId = -1;
        else
            parentId = record.value(m_parentIdFieldName).toInt();

        if (!m_idItemMap.contains(parentId)) {
            qDebug() << "Parent " << parentId << "not added yet, cannot add child" << id;
            continue;
        }

        if (m_idItemMap.contains(id))
            continue;

        m_idItemMap[id] = new TreeItem(record);
        m_idItemMap[parentId]->appendChild(m_idItemMap[id]);
    }
    endInsertRows();

    return true;
}

void SqlTreeModel::setSourceModel(SqlTableModel *model)
{
    if (!model)
        return;

    m_sourceModel = model;
    buildRolesIndexes();
    if (m_root)
        delete m_root;
    m_root = new TreeItem(m_sourceModel->record());

    int rows = model->rowCount();
    int id;
    QSqlRecord record;

    // Create tree items.
    m_idItemMap.clear();
    m_idItemMap[-1] = m_root; // We set root item id to -1
    for (int i = 0; i < rows; i++) {
        record = model->record(i);
        id = record.value(m_idFieldName).toInt();
        if (!m_idItemMap.contains(id))
            m_idItemMap[id] = new TreeItem(record);
        else
            qDebug() << id << " already in map!";
    }

    // Set parent/child relations.
    int parentId;
    TreeItem *childItem;
    TreeItem *parentItem;
    for (int i = 0; i < rows; i++) {
        childItem = nullptr;
        parentItem = nullptr;

        record = model->record(i);
        id = record.value(m_idFieldName).toInt();

        if (record.isNull(m_parentIdFieldName)) // root item
            parentId = -1;
        else
            parentId = record.value(m_parentIdFieldName).toInt();

        if (m_idItemMap.contains(id))
            childItem = m_idItemMap[id];
        else
            qDebug() << "ERROR id not in map";

        if (childItem && m_idItemMap.contains(parentId)) {
            parentItem = m_idItemMap[parentId];
            parentItem->appendChild(childItem);
        } else {
            qDebug() << "ERROR parentId not in map";
        }
    }
}
