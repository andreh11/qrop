#ifndef SQLNOTEMODEL_H
#define SQLNOTEMODEL_H

#include <QSqlTableModel>
#include <QDate>

#include "core_global.h"

class CORESHARED_EXPORT NoteModel : public QSqlTableModel
{
    Q_OBJECT
    Q_PROPERTY(QDate date READ date WRITE setDate NOTIFY dateChanged)

public:
    NoteModel(QObject *parent = 0);

    QDate date() const;
    void setDate(const QDate &date);

    QVariant data(const QModelIndex &idx, int role) const Q_DECL_OVERRIDE;
    QHash<int, QByteArray> roleNames() const Q_DECL_OVERRIDE;

    Q_INVOKABLE void addNote(const QString &content, const QDate &date);

signals:
    void dateChanged();

private:
    QDate m_date;
};

#endif // SQLNOTEMODEL_H
