#ifndef TREEVIEWMODEL_H
#define TREEVIEWMODEL_H

#include <QAbstractProxyModel>
#include <QDebug>

#include "core_global.h"

class TreeItemViewModel;

/**
 * @brief Proxy model that flattens any source TreeModel to make it suitable to display in a qml ListView (see TreeView.qml).
 *
 * It adds the following roles that can be used by the tree item delegate (see TreeItemView.qml):
 *  - indentation
 *  - hasChildren
 *  - isExpanded
 *  - hidden
 *
 * Use the setSourceModel method to set the source TreeModel (e.g. QFileSystemModel)
 */
class CORESHARED_EXPORT TreeViewModel : public QAbstractProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QList<int> selectedIdList READ selectedIdList NOTIFY selectedIdListChanged)

public:
    enum TreeRoles {
        Indentation = Qt::UserRole + 100,
        HasChildren,
        IsExpanded,
        Hidden,
        Selected,
        TreeSelected
    };

    explicit TreeViewModel(QObject *parent = nullptr);
    void setSourceModel(QAbstractItemModel *sourceModel) override;

    Q_INVOKABLE void refresh(int row);
    QModelIndex mapToSource(const QModelIndex &proxyIndex) const override;
    QModelIndex mapFromSource(const QModelIndex &sourceIndex) const override;
    int columnCount(const QModelIndex &parent) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex index(int row, int column = 0, const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &child) const override;
    QVariant data(const QModelIndex &proxyIndex, int role) const override;
    bool setData(const QModelIndex &proxyIndex, const QVariant &value, int role) override;
    QHash<int, QByteArray> roleNames() const override;

    QList<int> selectedIdList() const;

    Q_INVOKABLE void toggleIsExpanded(int row, bool isExpanded);
    Q_INVOKABLE void toggleIsSelected(int row, bool isSelected);
    Q_INVOKABLE void toggleIsTreeSelected(int row, bool isSelected);

    Q_INVOKABLE void selectAll();
    Q_INVOKABLE void unselectAll();

    Q_INVOKABLE void expandAll();
    Q_INVOKABLE void collapseAll();

signals:
    void selectedIdListChanged();

private slots:
    void onLayoutChanged();
    void onSourceDataChanged(QModelIndex topLeft, QModelIndex bottomRight);
    void onRowsInserted(const QModelIndex &parent, int first, int last);
    void onRowsMoved(const QModelIndex &parent, int start, int end,
                     const QModelIndex &destinationParent, int destinationRow);
    void onRowsRemoved(const QModelIndex &parent, int first, int last);

private:
    void flatten(QAbstractItemModel *model, QModelIndex parent = QModelIndex(),
                 TreeItemViewModel *parentNode = nullptr);

    void doResetModel(QAbstractItemModel *sourceModel);
    TreeItemViewModel *findItemByIndex(const QModelIndex &sourceIndex) const;

    TreeItemViewModel *m_root { nullptr };
    QList<TreeItemViewModel *> m_flattenedTree;
    QMap<QModelIndex, bool> m_expandedMap;
    QMap<QModelIndex, bool> m_hiddenMap;
    QMap<QModelIndex, bool> m_selectedMap;
};

#endif // TREEVIEWMODEL_H
