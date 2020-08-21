#ifndef RECORDMODEL_H
#define RECORDMODEL_H

#include <QDate>

#include "core_global.h"
#include "sortfilterproxymodel.h"

class CORESHARED_EXPORT RecordModel : public SortFilterProxyModel
{
    Q_OBJECT
    //    Q_PROPERTY(int plantingId READ plantingId WRITE setPlantingId NOTIFY plantingIdChanged)

public:
    RecordModel(QObject *parent = nullptr, const QString &tableName = "record_view");
    //    bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;

    //    int plantingId() const;
    //    void setPlantingId(int plantingId);

    // signals:
    //    void plantingIdChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    bool inYear(int sourceRow, const QModelIndex &sourceParent) const;
    //    int m_plantingId { -1 };
};

#endif // RECORDMODEL_H
