#ifndef SQLNOTEMODEL_H
#define SQLNOTEMODEL_H

#include <QDate>

#include "core_global.h"
#include "sortfilterproxymodel.h"

class CORESHARED_EXPORT NoteModel : public SortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int plantingId READ plantingId WRITE setPlantingId NOTIFY plantingIdChanged)

public:
    NoteModel(QObject *parent = nullptr, const QString &tableName = "note_view");

    int plantingId() const;
    void setPlantingId(int plantingId);

signals:
    void plantingIdChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    int m_plantingId { -1 };
};

#endif // SQLNOTEMODEL_H
