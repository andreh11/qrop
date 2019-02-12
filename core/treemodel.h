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

#ifndef TREEMODEL_H
#define TREEMODEL_H

#include <QAbstractItemModel>
#include <QModelIndex>
#include <QObject>
#include <QSqlRecord>
#include <QList>

#include "core_global.h"
#include "sqltablemodel.h"

class QSqlTableModel;

class CORESHARED_EXPORT TreeItem
{
public:
    explicit TreeItem(const QSqlRecord &record, TreeItem *parent = nullptr);
    ~TreeItem();

    void appendChild(TreeItem *item);
    void removeChild(TreeItem *item);
    TreeItem *child(int row) const;
    QVariant data(int column) const;
    bool setData(int column, const QVariant &value);
    int rowCount() const;
    int columnCount() const;
    TreeItem *parent() const;
    int row() const;

    QSqlRecord m_record;

private:
    QList<TreeItem *> m_children;
    TreeItem *m_parent;
};

class CORESHARED_EXPORT SqlTreeModel : public QAbstractItemModel
{
    Q_OBJECT

public:
    explicit SqlTreeModel(QString idFieldName = "location_id",
                          QString parentIdFieldName = "parent_id", QObject *parent = nullptr);
    ~SqlTreeModel() override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QVariant data(const QModelIndex &index, const QString &role) const;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    bool setData(const QModelIndex &index, const QVariant &value, const QString &role);
    Qt::ItemFlags flags(const QModelIndex &index) const override;
    QVariant headerData(int section, Qt::Orientation orientation,
                        int role = Qt::DisplayRole) const override;
    QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &parent) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;
    bool removeRows(int row, int count, const QModelIndex &parent) override;
    bool removeIndexes(const QList<QModelIndex> &indexList);
    void setSourceModel(SqlTableModel *model);
    bool addRecord(const QSqlRecord &record, const QModelIndex &parent = QModelIndex());
    bool addRecordTree(QList<QSqlRecord> &recordList, const QModelIndex &parent = QModelIndex());

private:
    TreeItem *m_root;
    QMap<int, TreeItem *> m_idItemMap;
    QString m_idFieldName;
    QString m_parentIdFieldName;
    SqlTableModel *m_sourceModel{};
    QHash<QString, int> m_rolesIndexes;
    void buildRolesIndexes();
};

#endif // TREEMODEL_H
