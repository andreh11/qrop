#ifndef SQLNOTEMODEL_H
#define SQLNOTEMODEL_H

#include <QSqlTableModel>
#include <QDate>

class SqlNoteModel : public QSqlTableModel
{
    Q_OBJECT
    Q_PROPERTY(QDate date READ date WRITE setDate NOTIFY dateChanged)

public:
    SqlNoteModel(QObject *parent = nullptr);

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
