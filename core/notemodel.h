#ifndef SQLNOTEMODEL_H
#define SQLNOTEMODEL_H

#include <QDate>

#include "core_global.h"
#include "sqltablemodel.h"

class CORESHARED_EXPORT NoteModel : public SqlTableModel
{
    Q_OBJECT
    Q_PROPERTY(QDate date READ date WRITE setDate NOTIFY dateChanged)

public:
    NoteModel(QObject *parent = nullptr);

    QDate date() const;
    void setDate(const QDate &date);

    //    Q_INVOKABLE void addNote(const QString &content, const QDate &date);
    //    static void removePlantingNotes(int plantingId);

signals:
    void dateChanged();

private:
    QDate m_date;
};

#endif // SQLNOTEMODEL_H
