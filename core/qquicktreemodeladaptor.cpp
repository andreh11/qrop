/****************************************************************************
**
** Copyright (C) 2015 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the Qt Quick Controls module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL3$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see http://www.qt.io/terms-conditions. For further
** information use the contact form at http://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPLv3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2.0 or later as published by the Free
** Software Foundation and appearing in the file LICENSE.GPL included in
** the packaging of this file. Please review the following information to
** ensure the GNU General Public License version 2.0 requirements will be
** met: http://www.gnu.org/licenses/gpl-2.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include <math.h>
#include "qquicktreemodeladaptor.h"
#include <QtCore/qstack.h>
#include <QtCore/qdebug.h>

QT_BEGIN_NAMESPACE

//#define QQUICKTREEMODELADAPTOR_DEBUG
#ifndef QQUICKTREEMODELADAPTOR_DEBUG
#undef qDebug
#define qDebug QT_NO_QDEBUG_MACRO
#elif !defined(QT_TESTLIB_LIB)
#define ASSERT_CONSISTENCY()                                                                       \
    Q_ASSERT_X(testConsistency(true /* dumpOnFail */), Q_FUNC_INFO, "Consistency test failed")
#endif
#ifndef ASSERT_CONSISTENCY
#define ASSERT_CONSISTENCY qt_noop
#endif

QQuickTreeModelAdaptor::QQuickTreeModelAdaptor(QObject *parent)
    : QAbstractListModel(parent)
    , m_model(nullptr)
    , m_lastItemIndex(0)
{
}

QAbstractItemModel *QQuickTreeModelAdaptor::model() const
{
    return m_model;
}

void QQuickTreeModelAdaptor::setModel(QAbstractItemModel *arg)
{
    struct Cx {
        const char *signal;
        const char *slot;
    };
    static const Cx connections[] = {
        { SIGNAL(modelReset()), SLOT(modelHasBeenReset()) },
        { SIGNAL(dataChanged(const QModelIndex &, const QModelIndex &, const QVector<int> &)),
          SLOT(modelDataChanged(const QModelIndex &, const QModelIndex &, const QVector<int> &)) },

        { SIGNAL(layoutAboutToBeChanged(const QList<QPersistentModelIndex> &,
                                        QAbstractItemModel::LayoutChangeHint)),
          SLOT(modelLayoutAboutToBeChanged(const QList<QPersistentModelIndex> &,
                                           QAbstractItemModel::LayoutChangeHint)) },
        { SIGNAL(layoutChanged(const QList<QPersistentModelIndex> &, QAbstractItemModel::LayoutChangeHint)),
          SLOT(modelLayoutChanged(const QList<QPersistentModelIndex> &,
                                  QAbstractItemModel::LayoutChangeHint)) },

        { SIGNAL(rowsAboutToBeInserted(const QModelIndex &, int, int)),
          SLOT(modelRowsAboutToBeInserted(const QModelIndex &, int, int)) },
        { SIGNAL(rowsInserted(const QModelIndex &, int, int)),
          SLOT(modelRowsInserted(const QModelIndex &, int, int)) },
        { SIGNAL(rowsAboutToBeRemoved(const QModelIndex &, int, int)),
          SLOT(modelRowsAboutToBeRemoved(const QModelIndex &, int, int)) },
        { SIGNAL(rowsRemoved(const QModelIndex &, int, int)),
          SLOT(modelRowsRemoved(const QModelIndex &, int, int)) },
        { SIGNAL(rowsAboutToBeMoved(const QModelIndex &, int, int, const QModelIndex &, int)),
          SLOT(modelRowsAboutToBeMoved(const QModelIndex &, int, int, const QModelIndex &, int)) },
        { SIGNAL(rowsMoved(const QModelIndex &, int, int, const QModelIndex &, int)),
          SLOT(modelRowsMoved(const QModelIndex &, int, int, const QModelIndex &, int)) },
        { nullptr, nullptr }
    };

    if (m_model != arg) {
        if (m_model) {
            for (const Cx *c = &connections[0]; c->signal; c++)
                disconnect(m_model, c->signal, this, c->slot);
        }

        clearModelData();
        m_model = arg;

        if (m_model) {
            for (const Cx *c = &connections[0]; c->signal; c++)
                connect(m_model, c->signal, this, c->slot);

            showModelTopLevelItems();
        }

        emit modelChanged(arg);
    }
}

void QQuickTreeModelAdaptor::clearModelData()
{
    beginResetModel();
    m_items.clear();
    m_expandedItems.clear();
    endResetModel();
}

QHash<int, QByteArray> QQuickTreeModelAdaptor::roleNames() const
{
    if (!m_model)
        return QHash<int, QByteArray>();

    QHash<int, QByteArray> modelRoleNames = m_model->roleNames();
    modelRoleNames.insert(DepthRole, "depth");
    modelRoleNames.insert(ExpandedRole, "expanded");
    modelRoleNames.insert(HasChildrenRole, "hasChildren");
    modelRoleNames.insert(HasSiblingRole, "hasSibling");
    return modelRoleNames;
}

int QQuickTreeModelAdaptor::rowCount(const QModelIndex &) const
{
    return m_items.count();
}

QVariant QQuickTreeModelAdaptor::data(const QModelIndex &index, int role) const
{
    if (!m_model)
        return QVariant();

    const QModelIndex &modelIndex = mapToModel(index);

    switch (role) {
    case DepthRole:
        return m_items.at(index.row()).depth;
    case ExpandedRole:
        return isExpanded(index.row());
    case HasChildrenRole:
        return !(modelIndex.flags() & Qt::ItemNeverHasChildren) && m_model->hasChildren(modelIndex);
    case HasSiblingRole:
        return modelIndex.row() != m_model->rowCount(modelIndex.parent()) - 1;
    default:
        return m_model->data(modelIndex, role);
    }
}

bool QQuickTreeModelAdaptor::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!m_model)
        return false;

    switch (role) {
    case ExpandedRole:
        if (value.toBool())
            expandRow(index.row());
        else
            collapseRow(index.row());
        break;
    case DepthRole:
    case HasChildrenRole:
    case HasSiblingRole:
        return false;
    default: {
        const QModelIndex &pmi = mapToModel(index);
        qDebug() << "setData" << pmi << role;
        return m_model->setData(pmi, value, role);
    }
    }
}

int QQuickTreeModelAdaptor::itemIndex(const QModelIndex &index)
{
    // This is basically a plagiarism of QTreeViewPrivate::viewIndex()
    if (!index.isValid() || m_items.isEmpty())
        return -1;

    const int totalCount = m_items.count();

    // We start nearest to the lastViewedItem
    int localCount = qMin(m_lastItemIndex - 1, totalCount - m_lastItemIndex);
    for (int i = 0; i < localCount; ++i) {
        const TreeItem &item1 = m_items.at(m_lastItemIndex + i);
        if (item1.index == index) {
            m_lastItemIndex = m_lastItemIndex + i;
            return m_lastItemIndex;
        }
        const TreeItem &item2 = m_items.at(m_lastItemIndex - i - 1);
        if (item2.index == index) {
            m_lastItemIndex = m_lastItemIndex - i - 1;
            return m_lastItemIndex;
        }
    }

    for (int j = qMax(0, m_lastItemIndex + localCount); j < totalCount; ++j) {
        const TreeItem &item = m_items.at(j);
        if (item.index == index) {
            m_lastItemIndex = j;
            return j;
        }
    }
    for (int j = qMin(totalCount, m_lastItemIndex - localCount) - 1; j >= 0; --j) {
        const TreeItem &item = m_items.at(j);
        if (item.index == index) {
            m_lastItemIndex = j;
            return j;
        }
    }

    // nothing found
    return -1;
}

bool QQuickTreeModelAdaptor::isVisible(const QModelIndex &index)
{
    return itemIndex(index) != -1;
}

bool QQuickTreeModelAdaptor::childrenVisible(const QModelIndex &index)
{
    return (!index.isValid() && !m_items.isEmpty())
            || (m_expandedItems.contains(index) && isVisible(index));
}

const QModelIndex &QQuickTreeModelAdaptor::mapToModel(const QModelIndex &index) const
{
    return m_items.at(index.row()).index;
}

QModelIndex QQuickTreeModelAdaptor::mapRowToModelIndex(int row) const
{
    if (row < 0 || row >= m_items.count())
        return QModelIndex();
    return m_items.at(row).index;
}

QItemSelection QQuickTreeModelAdaptor::selectionForRowRange(int from, int to) const
{
    Q_ASSERT(0 <= from && from < m_items.count());
    Q_ASSERT(0 <= to && to < m_items.count());

    if (from > to)
        qSwap(from, to);

    typedef QPair<QModelIndex, QModelIndex> MIPair;
    typedef QHash<QModelIndex, MIPair> MI2MIPairHash;
    MI2MIPairHash ranges;
    QModelIndex firstIndex = m_items.at(from).index;
    QModelIndex lastIndex = firstIndex;
    QModelIndex previousParent = firstIndex.parent();
    bool selectLastRow = false;
    for (int i = from + 1; i <= to || (selectLastRow = true); i++) {
        // We run an extra iteration to make sure the last row is
        // added to the selection. (And also to avoid duplicating
        // the insertion code.)
        QModelIndex index;
        QModelIndex parent;
        if (!selectLastRow) {
            index = m_items.at(i).index;
            parent = index.parent();
        }
        if (selectLastRow || previousParent != parent) {
            const MI2MIPairHash::iterator &it = ranges.find(previousParent);
            if (it == ranges.end())
                ranges.insert(previousParent, MIPair(firstIndex, lastIndex));
            else
                it->second = lastIndex;

            if (selectLastRow)
                break;

            firstIndex = index;
            previousParent = parent;
        }
        lastIndex = index;
    }

    QItemSelection sel;
    sel.reserve(ranges.count());
    foreach (const MIPair &pair, ranges)
        sel.append(QItemSelectionRange(pair.first, pair.second));

    return sel;
}

void QQuickTreeModelAdaptor::showModelTopLevelItems(bool doInsertRows)
{
    if (!m_model)
        return;

    if (m_model->hasChildren(QModelIndex()) && m_model->canFetchMore(QModelIndex()))
        m_model->fetchMore(QModelIndex());
    const long topLevelRowCount = m_model->rowCount();
    if (topLevelRowCount == 0) {
        qDebug() << "no toplevel items";
        return;
    }

    showModelChildItems(TreeItem(), 0, topLevelRowCount - 1, doInsertRows);
}

void QQuickTreeModelAdaptor::showModelChildItems(const TreeItem &parentItem, int start, int end,
                                                 bool doInsertRows, bool doExpandPendingRows)
{
    const QModelIndex &parentIndex = parentItem.index;
    int rowIdx = parentIndex.isValid() ? itemIndex(parentIndex) + 1 : 0;
    Q_ASSERT(rowIdx == 0 || parentItem.expanded);
    if (parentIndex.isValid() && (rowIdx == 0 || !parentItem.expanded)) {
        if (rowIdx == 0)
            qDebug() << "not found" << parentIndex;
        else
            qDebug() << "not expanded" << rowIdx - 1;
        return;
    }

    if (m_model->rowCount(parentIndex) == 0) {
        if (m_model->hasChildren(parentIndex) && m_model->canFetchMore(parentIndex))
            m_model->fetchMore(parentIndex);
        qDebug() << "no children" << parentIndex;
        return;
    }

    int insertCount = end - start + 1;
    int startIdx;
    if (start == 0) {
        startIdx = rowIdx;
    } else {
        const QModelIndex &prevSiblingIdx = m_model->index(start - 1, 0, parentIndex);
        startIdx = lastChildIndex(prevSiblingIdx) + 1;
    }

    int rowDepth = rowIdx == 0 ? 0 : parentItem.depth + 1;
    qDebug() << "inserting from" << startIdx << "to" << startIdx + insertCount - 1 << "depth"
             << rowDepth;
    if (doInsertRows)
        beginInsertRows(QModelIndex(), startIdx, startIdx + insertCount - 1);
    m_items.reserve(m_items.count() + insertCount);
    for (int i = 0; i < insertCount; i++) {
        const QModelIndex &cmi = m_model->index(start + i, 0, parentIndex);
        bool expanded = m_expandedItems.contains(cmi);
        m_items.insert(startIdx + i, TreeItem(cmi, rowDepth, expanded));
        if (expanded) {
            qDebug() << "will expand" << startIdx + i;
            m_itemsToExpand.append(&m_items[startIdx + i]);
        }
    }
    if (doInsertRows)
        endInsertRows();
    qDebug() << "insertion done";

    if (doExpandPendingRows)
        expandPendingRows(doInsertRows);
}

void QQuickTreeModelAdaptor::expand(QModelIndex idx)
{
    ASSERT_CONSISTENCY();
    if (!idx.isValid() || !m_model->hasChildren(idx))
        return;
    if (m_expandedItems.contains(idx))
        return;

    int row = itemIndex(idx);
    if (row != -1)
        expandRow(row);
    else
        m_expandedItems.insert(idx);
    ASSERT_CONSISTENCY();

    emit expanded(idx);
}

void QQuickTreeModelAdaptor::collapse(QModelIndex idx)
{
    ASSERT_CONSISTENCY();
    if (!idx.isValid() || !m_model->hasChildren(idx))
        return;
    if (!m_expandedItems.contains(idx))
        return;

    int row = itemIndex(idx);
    if (row != -1)
        collapseRow(row);
    else
        m_expandedItems.remove(idx);
    ASSERT_CONSISTENCY();

    emit collapsed(idx);
}

bool QQuickTreeModelAdaptor::isExpanded(QModelIndex index) const
{
    ASSERT_CONSISTENCY();
    return !index.isValid() || m_expandedItems.contains(index);
}

bool QQuickTreeModelAdaptor::isExpanded(int row) const
{
    return m_items.at(row).expanded;
}

void QQuickTreeModelAdaptor::expandRow(int n)
{
    if (!m_model || isExpanded(n)) {
        qDebug() << "already expanded" << n;
        return;
    }

    TreeItem &item = m_items[n];
    if ((item.index.flags() & Qt::ItemNeverHasChildren) || !m_model->hasChildren(item.index)) {
        qDebug() << "no children" << n;
        return;
    }
    item.expanded = true;
    m_expandedItems.insert(item.index);
    QVector<int> changedRole(1, ExpandedRole);
    emit dataChanged(index(n), index(n), changedRole);

    qDebug() << "expanding" << n << m_model->rowCount(item.index) << m_items[n].expanded;
    m_itemsToExpand.append(&item);
    expandPendingRows();
}

void QQuickTreeModelAdaptor::expandPendingRows(bool doInsertRows)
{
    while (!m_itemsToExpand.isEmpty()) {
        TreeItem *item = m_itemsToExpand.takeFirst();
        Q_ASSERT(item->expanded);
        const QModelIndex &index = item->index;
        int childrenCount = m_model->rowCount(index);
        if (childrenCount == 0) {
            if (m_model->hasChildren(index) && m_model->canFetchMore(index))
                m_model->fetchMore(index);
            qDebug() << "no children for row" << itemIndex(index);
            continue;
        }

        qDebug() << "expanding pending row" << itemIndex(index) << "children" << childrenCount;

        // TODO Pre-compute the total number of items made visible
        // so that we only call a single beginInsertRows()/endInsertRows()
        // pair per expansion (same as we do for collapsing).
        showModelChildItems(*item, 0, childrenCount - 1, doInsertRows, false);
    }
}

void QQuickTreeModelAdaptor::collapseRow(int n)
{
    if (!m_model || !isExpanded(n)) {
        qDebug() << "not expanded" << n;
        return;
    }

    TreeItem &item = m_items[n];
    item.expanded = false;
    m_expandedItems.remove(item.index);
    QVector<int> changedRole(1, ExpandedRole);
    emit dataChanged(index(n), index(n), changedRole);
    int childrenCount = m_model->rowCount(item.index);
    if ((item.index.flags() & Qt::ItemNeverHasChildren) || !m_model->hasChildren(item.index)
        || childrenCount == 0) {
        qDebug() << "no children" << n;
        return;
    }

    qDebug() << "collapsing" << n << childrenCount;
    const QModelIndex &emi = m_model->index(m_model->rowCount(item.index) - 1, 0, item.index);
    int lastIndex = lastChildIndex(emi);
    removeVisibleRows(n + 1, lastIndex);
}

int QQuickTreeModelAdaptor::lastChildIndex(const QModelIndex &index)
{
    //    qDebug() << "last child of" << itemIndex(index.parent());

    if (!m_expandedItems.contains(index)) {
        //        qDebug() << "not expanded" << itemIndex(index);
        return itemIndex(index);
    }

    QModelIndex parent = index.parent();
    QModelIndex nextSiblingIndex;
    while (parent.isValid()) {
        nextSiblingIndex = parent.sibling(parent.row() + 1, 0);
        if (nextSiblingIndex.isValid())
            break;
        parent = parent.parent();
    }

    int firstIndex = nextSiblingIndex.isValid() ? itemIndex(nextSiblingIndex) : m_items.count();
    qDebug() << "first index" << firstIndex - 1;
    return firstIndex - 1;
}

void QQuickTreeModelAdaptor::removeVisibleRows(int startIndex, int endIndex, bool doRemoveRows)
{
    if (startIndex < 0 || endIndex < 0 || startIndex > endIndex)
        return;

    qDebug() << "removing" << startIndex << endIndex;
    if (doRemoveRows)
        beginRemoveRows(QModelIndex(), startIndex, endIndex);
    m_items.erase(m_items.begin() + startIndex, m_items.begin() + endIndex + 1);
    if (doRemoveRows)
        endRemoveRows();
}

void QQuickTreeModelAdaptor::modelHasBeenReset()
{
    qDebug() << "modelHasBeenReset";
    clearModelData();

    showModelTopLevelItems();
    ASSERT_CONSISTENCY();
}

void QQuickTreeModelAdaptor::modelDataChanged(const QModelIndex &topLeft,
                                              const QModelIndex &bottomRigth, const QVector<int> &roles)
{
    qDebug() << "modelDataChanged" << topLeft << bottomRigth;
    Q_ASSERT(topLeft.parent() == bottomRigth.parent());
    const QModelIndex &parent = topLeft.parent();
    if (parent.isValid() && !childrenVisible(parent)) {
        qDebug() << "not visible" << parent;
        ASSERT_CONSISTENCY();
        return;
    }

    int topIndex = itemIndex(topLeft);
    if (topIndex == -1) // 'parent' is not visible anymore, though it's been expanded previously
        return;
    for (int i = topLeft.row(); i <= bottomRigth.row(); i++) {
        // Group items with same parent to minize the number of 'dataChanged()' emits
        int bottomIndex = topIndex;
        while (bottomIndex < m_items.count()) {
            const QModelIndex &idx = m_items.at(bottomIndex).index;
            if (idx.parent() != parent) {
                --bottomIndex;
                break;
            }
            if (idx.row() == bottomRigth.row())
                break;
            ++bottomIndex;
        }
        emit dataChanged(index(topIndex), index(bottomIndex), roles);

        i += bottomIndex - topIndex;
        if (i == bottomRigth.row())
            break;
        topIndex = bottomIndex + 1;
        while (topIndex < m_items.count() && m_items.at(topIndex).index.parent() != parent)
            topIndex++;
    }
    ASSERT_CONSISTENCY();
}

void QQuickTreeModelAdaptor::modelLayoutAboutToBeChanged(const QList<QPersistentModelIndex> &parents,
                                                         QAbstractItemModel::LayoutChangeHint hint)
{
    qDebug() << "modelLayoutAboutToBeChanged" << parents << hint << m_items.count();
    ASSERT_CONSISTENCY();
    Q_UNUSED(parents);
    Q_UNUSED(hint);
}

void QQuickTreeModelAdaptor::modelLayoutChanged(const QList<QPersistentModelIndex> &parents,
                                                QAbstractItemModel::LayoutChangeHint hint)
{
    Q_UNUSED(hint);
    qDebug() << "modelLayoutChanged" << parents << hint << m_items.count();
    if (parents.isEmpty()) {
        m_items.clear();
        showModelTopLevelItems(false /*doInsertRows*/);
        emit dataChanged(index(0), index(m_items.count() - 1));
    }

    Q_FOREACH (const QPersistentModelIndex &pmi, parents) {
        if (m_expandedItems.contains(pmi) && m_model->hasChildren(pmi)) {
            int row = itemIndex(pmi);
            if (row != -1) {
                const QModelIndex &lmi = m_model->index(m_model->rowCount(pmi) - 1, 0, pmi);
                int lastRow = lastChildIndex(lmi);
                removeVisibleRows(row + 1, lastRow, false /*doRemoveRows*/);
                showModelChildItems(m_items.at(row), 0, m_model->rowCount(pmi) - 1,
                                    false /*doInsertRows*/);
                emit dataChanged(index(row + 1), index(lastRow));
            }
        }
    }
    ASSERT_CONSISTENCY();
}

void QQuickTreeModelAdaptor::modelRowsAboutToBeInserted(const QModelIndex &parent, int start, int end)
{
    qDebug() << "modelRowsAboutToBeInserted" << parent << "start" << start << "end" << end;
    ASSERT_CONSISTENCY();
}

void QQuickTreeModelAdaptor::modelRowsInserted(const QModelIndex &parent, int start, int end)
{
    qDebug() << "modelRowsInserted" << parent << "start" << start << "end" << end;
    TreeItem item;
    int parentRow = itemIndex(parent);
    if (parentRow >= 0) {
        item = m_items.at(parentRow);
        if (!item.expanded) {
            ASSERT_CONSISTENCY();
            return;
        }
    } else if (parent.isValid()) {
        item = TreeItem(parent);
    }
    showModelChildItems(item, start, end);
    ASSERT_CONSISTENCY();
}

void QQuickTreeModelAdaptor::modelRowsAboutToBeRemoved(const QModelIndex &parent, int start, int end)
{
    qDebug() << "modelRowsAboutToBeRemoved" << parent << "start" << start << "end" << end;
    ASSERT_CONSISTENCY();
    if (!parent.isValid() || childrenVisible(parent)) {
        const QModelIndex &smi = m_model->index(start, 0, parent);
        int startIndex = itemIndex(smi);
        const QModelIndex &emi = m_model->index(end, 0, parent);
        int endIndex = itemIndex(emi);
        if (isExpanded(emi)) {
            const QModelIndex &idx = m_model->index(m_model->rowCount(emi) - 1, 0, emi);
            endIndex = lastChildIndex(idx);
        }
        removeVisibleRows(startIndex, endIndex);
    }

    for (int r = start; r <= end; r++) {
        const QModelIndex &cmi = m_model->index(r, 0, parent);
        m_expandedItems.remove(cmi);
    }
}

void QQuickTreeModelAdaptor::modelRowsRemoved(const QModelIndex &parent, int start, int end)
{
    qDebug() << "modelRowsRemoved" << parent << "start" << start << "end" << end;
    ASSERT_CONSISTENCY();
}

void QQuickTreeModelAdaptor::modelRowsAboutToBeMoved(const QModelIndex &sourceParent,
                                                     int sourceStart, int sourceEnd,
                                                     const QModelIndex &destinationParent,
                                                     int destinationRow)
{
    qDebug() << "modelRowsAboutToBeMoved" << sourceParent << "source start" << sourceStart << "end"
             << sourceEnd;
    qDebug() << "            destination" << destinationParent << "row" << destinationRow;
    ASSERT_CONSISTENCY();
    if (!childrenVisible(sourceParent))
        return; // Do nothing now. See modelRowsMoved() below.

    if (!childrenVisible(destinationParent)) {
        modelRowsAboutToBeRemoved(sourceParent, sourceStart, sourceEnd);
    } else {
        int depthDifference = -1;
        if (destinationParent.isValid()) {
            int destParentIndex = itemIndex(destinationParent);
            depthDifference = m_items.at(destParentIndex).depth;
        }
        if (sourceParent.isValid()) {
            int sourceParentIndex = itemIndex(sourceParent);
            depthDifference -= m_items.at(sourceParentIndex).depth;
        } else {
            depthDifference++;
        }
        qDebug() << "depth difference" << depthDifference;

        int startIndex = itemIndex(m_model->index(sourceStart, 0, sourceParent));
        const QModelIndex &emi = m_model->index(sourceEnd, 0, sourceParent);
        int endIndex;
        if (isExpanded(emi))
            endIndex = lastChildIndex(m_model->index(m_model->rowCount(emi) - 1, 0, emi));
        else
            endIndex = itemIndex(emi);

        int destIndex = -1;
        if (destinationRow == m_model->rowCount(destinationParent)) {
            const QModelIndex &emi = m_model->index(destinationRow - 1, 0, destinationParent);
            destIndex = lastChildIndex(emi) + 1;
        } else {
            destIndex = itemIndex(m_model->index(destinationRow, 0, destinationParent));
        }

        qDebug() << "moving" << (destIndex > endIndex ? "forward" : "backward") << startIndex
                 << endIndex << destIndex << m_items.count();
        beginMoveRows(QModelIndex(), startIndex, endIndex, QModelIndex(), destIndex);
        int totalMovedCount = endIndex - startIndex + 1;
        const QList<TreeItem> &buffer = m_items.mid(startIndex, totalMovedCount);
        qDebug() << "copied" << startIndex << totalMovedCount;
        int bufferCopyOffset;
        if (destIndex > endIndex) {
            for (int i = endIndex + 1; i < destIndex; i++) {
                m_items.swap(i, i - totalMovedCount); // Fast move from 1st to 2nd position
            }
            bufferCopyOffset = destIndex - totalMovedCount;
        } else {
            for (int i = startIndex - 1; i >= destIndex; i--) {
                m_items.swap(i, i + totalMovedCount); // Fast move from 1st to 2nd position
            }
            bufferCopyOffset = destIndex;
        }
        qDebug() << "copying back" << bufferCopyOffset << buffer.length();
        for (int i = 0; i < buffer.length(); i++) {
            TreeItem item = buffer.at(i);
            item.depth += depthDifference;
            m_items.replace(bufferCopyOffset + i, item);
        }
        endMoveRows();
    }
}

void QQuickTreeModelAdaptor::modelRowsMoved(const QModelIndex &sourceParent, int sourceStart,
                                            int sourceEnd, const QModelIndex &destinationParent,
                                            int destinationRow)
{
    qDebug() << "modelRowsMoved" << sourceParent << "source start" << sourceStart << "end" << sourceEnd;
    qDebug() << "   destination" << destinationParent << "row" << destinationRow;
    if (!childrenVisible(sourceParent) && childrenVisible(destinationParent))
        modelRowsInserted(destinationParent, destinationRow, destinationRow + sourceEnd - sourceStart);
    ASSERT_CONSISTENCY();
}

void QQuickTreeModelAdaptor::dump() const
{
    int count = m_items.count();
    if (count == 0)
        return;
    int countWidth = floor(log10(count)) + 1;
    qInfo() << "Dumping" << this;
    for (int i = 0; i < count; i++) {
        const TreeItem &item = m_items.at(i);
        bool hasChildren = m_model->hasChildren(item.index);
        int children = m_model->rowCount(item.index);
        qInfo().noquote().nospace()
                << QString("%1 ").arg(i, countWidth)
                << QString(4 * item.depth, QChar::fromLatin1('.'))
                << QLatin1String(!hasChildren ? ".. " : item.expanded ? " v " : " > ") << item.index
                << children;
    }
}

bool QQuickTreeModelAdaptor::testConsistency(bool dumpOnFail) const
{
    QModelIndex parent;
    QStack<QModelIndex> ancestors;
    QModelIndex idx = m_model->index(0, 0);
    for (int i = 0; i < m_items.count(); i++) {
        bool isConsistent = true;
        const TreeItem &item = m_items.at(i);
        if (item.index != idx) {
            qWarning() << "QModelIndex inconsistency" << i << item.index;
            qWarning() << "    expected" << idx;
            isConsistent = false;
        }
        if (item.index.parent() != parent) {
            qWarning() << "Parent inconsistency" << i << item.index;
            qWarning() << "    stored index parent" << item.index.parent() << "model parent" << parent;
            isConsistent = false;
        }
        if (item.depth != ancestors.count()) {
            qWarning() << "Depth inconsistency" << i << item.index;
            qWarning() << "    item depth" << item.depth << "ancestors stack" << ancestors.count();
            isConsistent = false;
        }
        if (item.expanded && !m_expandedItems.contains(item.index)) {
            qWarning() << "Expanded inconsistency" << i << item.index;
            qWarning() << "    set" << m_expandedItems.contains(item.index) << "item" << item.expanded;
            isConsistent = false;
        }
        if (!isConsistent) {
            if (dumpOnFail)
                dump();
            return false;
        }
        QModelIndex firstChildIndex;
        if (item.expanded)
            firstChildIndex = m_model->index(0, 0, idx);
        if (firstChildIndex.isValid()) {
            ancestors.push(parent);
            parent = idx;
            idx = m_model->index(0, 0, parent);
        } else {
            while (idx.row() == m_model->rowCount(parent) - 1) {
                if (ancestors.isEmpty())
                    break;
                idx = parent;
                parent = ancestors.pop();
            }
            idx = m_model->index(idx.row() + 1, 0, parent);
        }
    }

    return true;
}

QList<int> QQuickTreeModelAdaptor::selectedIdList() const
{
    QList<int> list;
    for (int row = 0; row < rowCount(); ++row) {
        const QModelIndex idx = index(row);
        //        if (data(idx, Selected).toBool()) {
        //            int locationId = data(idx, Qt::UserRole).toInt();
        //            list.push_back(locationId);
        //        }
    }
    return list;
}

// void QQuickTreeModelAdaptor::collapseSource(const QModelIndex &idx)
//{
//    collapse(mapToModel)
//}

QT_END_NAMESPACE
