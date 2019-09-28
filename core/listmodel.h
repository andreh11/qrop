#ifndef LISTMODEL_H
#define LISTMODEL_H

#include <QAbstractTableModel>

class IntListModel : public QAbstractListModel
{
public:
    IntListModel(QObject *parent = nullptr);

    void addList();
    void addItem(int row, int item);

    Q_INVOKABLE int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

private:
    QList<QList<int>> m_list;
};

#endif // LISTMODEL_H
