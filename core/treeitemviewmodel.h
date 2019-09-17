#ifndef TREEITEMVIEWMODEL_H
#define TREEITEMVIEWMODEL_H

#include <QAbstractProxyModel>
#include <QList>
#include <QModelIndex>
#include <QDebug>

/**
 * @brief The class TreeItemViewModel is an internal representation of a tree item for use by the TreeViewModel.
 *
 * It contains the logic for adding and removing child nodes and updating the flat list representation of the tree
 * and holds the TreeItemView specific roles such as isExpanded, isHidden,...
 */
class TreeItemViewModel
{
public:
    /**
     * Creates a root item.
     *
     * @param sourceIndex sourceIndex of the model
     * @param flattenedTree Flat representation of the tree
     * @param proxyModel The proxy model that contains the items.
     */
    TreeItemViewModel(QModelIndex sourceIndex, QList<TreeItemViewModel *> &flattenedTree,
                      QMap<QModelIndex, bool> &expandedMap, QMap<QModelIndex, bool> &hiddenMap,
                      QMap<QModelIndex, bool> &selectedMap);
    TreeItemViewModel(TreeItemViewModel *parent, QModelIndex sourceIndex,
                      QList<TreeItemViewModel *> &flattenedTree, QAbstractProxyModel *model,
                      QMap<QModelIndex, bool> &expandedMap, QMap<QModelIndex, bool> &hiddenMap,
                      QMap<QModelIndex, bool> &selectedMap);

    QPersistentModelIndex sourceIndexAcrossProxyChain(const QModelIndex &proxyIndex) const;
    TreeItemViewModel *parent();
    int indexOfChild(const TreeItemViewModel *child) const;
    QModelIndex sourceIndex() const;
    TreeItemViewModel *addChild(QModelIndex index);
    TreeItemViewModel *insertChild(int row, QModelIndex index);

    void setExpanded(bool expanded);
    void setHidden(bool hidden);
    void setSelected(bool selected, bool treeSelect);

    int row();
    int indent() const;

    bool isExpanded() const;
    bool isCollapsed() const;
    bool isHidden() const;
    bool isSelected() const;
    bool hasChildren() const;

    int getLastChildRow();

private:
    QPersistentModelIndex m_sourceIndex;
    int m_indent;
    bool m_isExpanded { false };
    bool m_isHidden;
    bool m_isSelected { false };

    TreeItemViewModel *m_parent;
    QAbstractProxyModel *m_proxyModel;
    QList<TreeItemViewModel *> &m_flattenedTree;
    QList<TreeItemViewModel *> m_childItems;
    QMap<QModelIndex, bool> &m_expandedMap;
    QMap<QModelIndex, bool> &m_hiddenMap;
    QMap<QModelIndex, bool> &m_selectedMap;
};

#endif // TREEITEMVIEWMODEL_H
