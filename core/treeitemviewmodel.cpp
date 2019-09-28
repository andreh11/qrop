#include "treeitemviewmodel.h"

TreeItemViewModel::TreeItemViewModel(QModelIndex sourceIndex, QList<TreeItemViewModel *> &flattenedTree,
                                     QMap<QModelIndex, bool> &expandedMap,
                                     QMap<QModelIndex, bool> &hiddenMap,
                                     QMap<QModelIndex, bool> &selectedMap)
    : TreeItemViewModel(nullptr, sourceIndex, flattenedTree, nullptr, expandedMap, hiddenMap, selectedMap)
{
}

TreeItemViewModel::TreeItemViewModel(TreeItemViewModel *parent, QModelIndex sourceIndex,
                                     QList<TreeItemViewModel *> &flattenedTree,
                                     QAbstractProxyModel *model, QMap<QModelIndex, bool> &expandedMap,
                                     QMap<QModelIndex, bool> &hiddenMap,
                                     QMap<QModelIndex, bool> &selectedMap)
    : m_sourceIndex(sourceIndex)
    , m_parent(parent)
    , m_proxyModel(model)
    , m_flattenedTree(flattenedTree)
    , m_expandedMap(expandedMap)
    , m_hiddenMap(hiddenMap)
    , m_selectedMap(selectedMap)
{
    if (parent) {
        m_isHidden = parent->isCollapsed() || parent->isHidden();
        //            ;
        m_indent = parent->indent() + 1;
    } else {
        m_isHidden = false;
        m_indent = 0;
        flattenedTree.append(this);
    }

    m_isExpanded = expandedMap.value(sourceIndexAcrossProxyChain(sourceIndex), m_isExpanded);
    m_isSelected = selectedMap.value(sourceIndexAcrossProxyChain(sourceIndex), m_isSelected);
}

QPersistentModelIndex TreeItemViewModel::sourceIndexAcrossProxyChain(const QModelIndex &proxyIndex) const
{
    QAbstractProxyModel *proxyModel = m_proxyModel;
    QAbstractProxyModel *nextSubProxyModel =
            qobject_cast<QAbstractProxyModel *>(proxyModel->sourceModel());
    QModelIndex sourceIndex = proxyIndex;
    while (nextSubProxyModel != nullptr) {
        proxyModel = nextSubProxyModel;
        sourceIndex = proxyModel->mapToSource(sourceIndex);
        nextSubProxyModel = qobject_cast<QAbstractProxyModel *>(proxyModel->sourceModel());
    }
    return QPersistentModelIndex(sourceIndex);
}

TreeItemViewModel *TreeItemViewModel::parent()
{
    return m_parent;
}

int TreeItemViewModel::indexOfChild(const TreeItemViewModel *child) const
{
    if (m_childItems.contains(const_cast<TreeItemViewModel *>(child)))
        return m_childItems.indexOf(const_cast<TreeItemViewModel *>(child));
    return -1;
}

QModelIndex TreeItemViewModel::sourceIndex() const
{
    return m_sourceIndex;
}

TreeItemViewModel *TreeItemViewModel::addChild(const QModelIndex &index)
{
    TreeItemViewModel *child = new TreeItemViewModel(this, index, m_flattenedTree, m_proxyModel,
                                                     m_expandedMap, m_hiddenMap, m_selectedMap);

    int insertPoint = getLastChildRow() + 1;
    m_flattenedTree.insert(insertPoint, child);
    m_childItems.append(child);

    return child;
}

TreeItemViewModel *TreeItemViewModel::insertChild(int row, const QModelIndex &index)
{
    if (m_childItems.count() <= row)
        return addChild(index);

    TreeItemViewModel *child = new TreeItemViewModel(this, index, m_flattenedTree, m_proxyModel,
                                                     m_expandedMap, m_hiddenMap, m_selectedMap);
    int insertPoint = m_childItems[row]->getLastChildRow();
    m_flattenedTree.insert(insertPoint, child);
    m_childItems.insert(row, child);
    return child;
}

void TreeItemViewModel::setExpanded(bool expanded, bool emitSignal)
{
    if (m_isExpanded == expanded)
        return;

    m_isExpanded = expanded;
    m_expandedMap[sourceIndexAcrossProxyChain(m_sourceIndex)] = expanded;

    if (emitSignal) {
        QModelIndex proxyIndex = m_proxyModel->mapFromSource(sourceIndex());
        emit m_proxyModel->dataChanged(proxyIndex, proxyIndex);
    }

    if (m_proxyModel->sourceModel()->canFetchMore(sourceIndex()))
        m_proxyModel->sourceModel()->fetchMore(sourceIndex());

    for (TreeItemViewModel *child : m_childItems)
        child->setHidden(!m_isExpanded, emitSignal);
}

void TreeItemViewModel::setSelected(bool selected, bool treeSelect, bool emitSignal)
{
    if (m_isSelected == selected)
        return;

    m_isSelected = selected;
    m_selectedMap[sourceIndexAcrossProxyChain(m_sourceIndex)] = selected;

    if (emitSignal) {
        QModelIndex proxyIndex = m_proxyModel->mapFromSource(sourceIndex());
        emit m_proxyModel->dataChanged(proxyIndex, proxyIndex);
    }

    if (treeSelect) {
        for (auto child : m_childItems)
            child->setSelected(selected, treeSelect, emitSignal);
    }
}

void TreeItemViewModel::setHidden(bool hidden, bool emitSignal)
{
    if (m_isHidden == hidden)
        return;

    m_isHidden = hidden;
    m_hiddenMap[m_sourceIndex] = hidden;

    if (emitSignal) {
        QModelIndex proxyIndex = m_proxyModel->mapFromSource(sourceIndex());
        emit m_proxyModel->dataChanged(proxyIndex, proxyIndex);
    }

    for (TreeItemViewModel *child : m_childItems)
        child->setHidden(m_isHidden || !m_isExpanded, emitSignal);
}

int TreeItemViewModel::row()
{
    return m_flattenedTree.indexOf(this);
}

int TreeItemViewModel::indent() const
{
    return m_indent;
}

bool TreeItemViewModel::isExpanded() const
{
    return m_isExpanded;
}

bool TreeItemViewModel::isCollapsed() const
{
    return !m_isExpanded;
}

bool TreeItemViewModel::isHidden() const
{
    return m_isHidden;
}

bool TreeItemViewModel::isSelected() const
{
    return m_isSelected;
}

bool TreeItemViewModel::hasChildren() const
{
    return m_proxyModel->sourceModel()->hasChildren(sourceIndex());
}

int TreeItemViewModel::getLastChildRow()
{
    if (m_childItems.count() > 0) {
        TreeItemViewModel *lastChild = m_childItems.last();
        return lastChild->getLastChildRow();
    } else
        return row();
}
