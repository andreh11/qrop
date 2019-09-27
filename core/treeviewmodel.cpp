#include "treeviewmodel.h"
#include "treeitemviewmodel.h"

TreeViewModel::TreeViewModel(QObject *parent)
    : QAbstractProxyModel(parent)
{
}

// QAbstactProxyModel implementation
void TreeViewModel::setSourceModel(QAbstractItemModel *sourceModel)
{
    QAbstractProxyModel::setSourceModel(sourceModel);

    doResetModel(sourceModel);

    if (sourceModel != nullptr) {
        connect(sourceModel, &QAbstractItemModel::dataChanged, this,
                &TreeViewModel::onSourceDataChanged);
        connect(sourceModel, &QAbstractItemModel::dataChanged, this,
                &TreeViewModel::selectedIdListChanged);
        connect(this, &TreeViewModel::dataChanged, this, &TreeViewModel::selectedIdListChanged);
        //        connect(sourceModel, &QAbstractItemModel::rowsInserted, this, &TreeViewModel::onRowsInserted);
        connect(sourceModel, SIGNAL(rowsInserted(const QModelIndex &, int, int)), this,
                SLOT(onRowsInserted(const QModelIndex &, int, int)));

        connect(sourceModel, &QAbstractItemModel::rowsRemoved, this, &TreeViewModel::onRowsRemoved);
        connect(sourceModel, &QAbstractItemModel::rowsMoved, this, &TreeViewModel::onRowsMoved);
        connect(sourceModel, &QAbstractItemModel::layoutChanged, this, &TreeViewModel::onLayoutChanged);
    }
}

QList<int> TreeViewModel::selectedIdList() const
{
    QList<int> list;
    for (int row = 0; row < rowCount(); ++row) {
        const QModelIndex idx = index(row);
        if (data(idx, Selected).toBool()) {
            int locationId = data(idx, Qt::UserRole).toInt();
            list.push_back(locationId);
        }
    }
    return list;
}

Q_INVOKABLE void TreeViewModel::refresh(int row)
{
    Q_ASSERT(row < rowCount());
    const QModelIndex idx = index(row);
    emit dataChanged(idx, idx);
}

QModelIndex TreeViewModel::mapToSource(const QModelIndex &proxyIndex) const
{
    if (!proxyIndex.isValid())
        return {};
    Q_ASSERT(proxyIndex.row() < m_flattenedTree.count());
    return m_flattenedTree[proxyIndex.row()]->sourceIndex();
}

QModelIndex TreeViewModel::mapFromSource(const QModelIndex &sourceIndex) const
{
    TreeItemViewModel *node = findItemByIndex(sourceIndex);
    if (node == nullptr)
        return {};
    return createIndex(node->row(), 0);
}

int TreeViewModel::columnCount(const QModelIndex &parent) const
{
    return sourceModel()->columnCount(mapToSource(parent));
}

int TreeViewModel::rowCount(const QModelIndex &parent) const
{
    if (!parent.isValid())
        return m_flattenedTree.count();
    return 0;
}

QModelIndex TreeViewModel::index(int row, int column, const QModelIndex &parent) const
{
    if (parent.isValid())
        return {};
    return createIndex(row, column);
}

QModelIndex TreeViewModel::parent(const QModelIndex &child) const
{
    Q_UNUSED(child)
    return {};
}

QVariant TreeViewModel::data(const QModelIndex &proxyIndex, int role) const
{
    switch (role) {
    case Indentation:
        return m_flattenedTree[proxyIndex.row()]->indent();
    case HasChildren:
        return m_flattenedTree[proxyIndex.row()]->hasChildren();
    case IsExpanded:
        return m_flattenedTree[proxyIndex.row()]->isExpanded();
    case Hidden:
        return m_flattenedTree[proxyIndex.row()]->isHidden();
    case Selected:
        return m_flattenedTree[proxyIndex.row()]->isSelected();
    case TreeSelected:
        return m_flattenedTree[proxyIndex.row()]->isSelected();
    default:
        return QAbstractProxyModel::data(proxyIndex, role);
    }
}

bool TreeViewModel::setData(const QModelIndex &proxyIndex, const QVariant &value, int role)
{
    switch (role) {
    case IsExpanded:
        toggleIsExpanded(proxyIndex.row(), value.toBool());
        return true;
    case Selected:
        toggleIsSelected(proxyIndex.row(), value.toBool());
        return true;
    case TreeSelected:
        toggleIsTreeSelected(proxyIndex.row(), value.toBool());
        return true;
    default:
        return QAbstractProxyModel::setData(proxyIndex, value, role);
    }
}

QHash<int, QByteArray> TreeViewModel::roleNames() const
{
    auto names = QAbstractItemModel::roleNames();
    names[Indentation] = "indentation";
    names[HasChildren] = "hasChildren";
    names[IsExpanded] = "isExpanded";
    names[Hidden] = "hidden";
    names[Selected] = "isSelected";
    names[TreeSelected] = "isTreeSelected";
    return names;
}

void TreeViewModel::toggleIsExpanded(int row, bool isExpanded)
{
    m_flattenedTree[row]->setExpanded(isExpanded);
}

void TreeViewModel::toggleIsSelected(int row, bool isSelected)
{
    m_flattenedTree[row]->setSelected(isSelected, false);
}

void TreeViewModel::toggleIsTreeSelected(int row, bool isSelected)
{
    m_flattenedTree[row]->setSelected(isSelected, true);
}

void TreeViewModel::selectAll()
{
    for (const auto row : m_flattenedTree)
        row->setSelected(true, false, false);
    emit dataChanged(index(0), index(rowCount() - 1));
}

void TreeViewModel::unselectAll()
{
    for (const auto row : m_flattenedTree)
        row->setSelected(false, false, false);
    emit dataChanged(index(0), index(rowCount() - 1));
}

void TreeViewModel::expandAll()
{
    for (const auto row : m_flattenedTree)
        row->setExpanded(true, false);
    emit dataChanged(index(0), index(rowCount() - 1));
}

void TreeViewModel::collapseAll()
{
    for (const auto row : m_flattenedTree)
        row->setSelected(false, false);
    emit dataChanged(index(0), index(rowCount() - 1));
}

void TreeViewModel::onLayoutChanged()
{
    qDebug() << "onLayoutChanged";
    doResetModel(sourceModel());
}

void TreeViewModel::onSourceDataChanged(QModelIndex topLeft, QModelIndex bottomRight)
{
    qDebug() << "onSourceDataChanged";
    emit dataChanged(mapFromSource(topLeft), mapFromSource(bottomRight));
}

void TreeViewModel::onRowsInserted(const QModelIndex &parent, int first, int last)
{
    TreeItemViewModel *parentNode = findItemByIndex(parent);
    qDebug() << "onRowsInserted" << parent.data() << first << last;

    int firstRow = 0;
    int lastRow = 0;

    for (int row = first; row < last + 1; ++row) {
        auto childIndex = index(row, 0, parent);
        TreeItemViewModel *node = nullptr;
        if (parentNode)
            node = parentNode->insertChild(row, childIndex);
        else
            node = new TreeItemViewModel(nullptr, childIndex, m_flattenedTree, this, m_expandedMap,
                                         m_hiddenMap, m_selectedMap);
        if (row == first)
            firstRow = node->row();
        if (row == last)
            lastRow = node->row();
    }
    beginInsertRows(QModelIndex(), firstRow, lastRow);
    endInsertRows();
}

void TreeViewModel::onRowsMoved(const QModelIndex &parent, int start, int end,
                                const QModelIndex &destinationParent, int destinationRow)
{
    Q_UNUSED(parent)
    Q_UNUSED(start)
    Q_UNUSED(end)
    Q_UNUSED(destinationParent)
    Q_UNUSED(destinationRow)
    qDebug() << "onRowsMoved";
}

void TreeViewModel::onRowsRemoved(const QModelIndex &parent, int first, int last)
{
    Q_UNUSED(parent)
    Q_UNUSED(first)
    Q_UNUSED(last)
    qDebug() << "onRowsRemoved";
}

void TreeViewModel::flatten(QAbstractItemModel *model, QModelIndex parent, TreeItemViewModel *parentNode)
{
    if (parentNode == nullptr) {
        qDeleteAll(m_flattenedTree);
        m_flattenedTree.clear();
    }

    if (model == nullptr)
        return;

    const int rows = model->rowCount(parent);

    for (int rowIndex = 0; rowIndex < rows; ++rowIndex) {
        QModelIndex index = model->index(rowIndex, 0, parent);
        TreeItemViewModel *node = nullptr;
        if (parentNode)
            node = parentNode->addChild(index);
        else
            node = new TreeItemViewModel(nullptr, index, m_flattenedTree, this, m_expandedMap,
                                         m_hiddenMap, m_selectedMap);

        if (node->hasChildren())
            flatten(model, index, node);

        if (node->isExpanded())
            node->setExpanded(node->isExpanded());
    }
}

void TreeViewModel::doResetModel(QAbstractItemModel *sourceModel)
{
    beginResetModel();
    flatten(sourceModel);
    endResetModel();
}

TreeItemViewModel *TreeViewModel::findItemByIndex(const QModelIndex &sourceIndex) const
{
    for (TreeItemViewModel *n : m_flattenedTree) {
        if (n->sourceIndex() == sourceIndex)
            return n;
    }
    return nullptr;
}
