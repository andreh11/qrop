#include "sqlnotemodel.h"

#include <QDebug>
#include <QSqlRecord>
#include <QSqlError>
#include <QSqlQuery>

static const char *noteTableName = "comment";

SqlNoteModel::SqlNoteModel(QObject *parent)
    : QSqlTableModel(parent)
{
    m_date = QDate();

    setTable(noteTableName);
    setSort(2, Qt::AscendingOrder);
    setEditStrategy(QSqlTableModel::OnManualSubmit);
    select();
}

QDate SqlNoteModel::date() const
{
    return m_date;
}

void SqlNoteModel::setDate(const QDate &date)
{
    if (date == m_date)
        return;

    m_date = date;

    const QString filterString = QString::fromLatin1(
                "date_assigned = %1").arg("2018-06-16");
//                "date_assigned = %1").arg(date.toString(Qt.ISODate));
    setFilter(filterString);
    select();

    emit dateChanged();
}

QVariant SqlNoteModel::data(const QModelIndex &index, int role) const
{
    if (role < Qt::UserRole)
        return QSqlTableModel::data(index, role);

    const QSqlRecord sqlRecord = record(index.row());
    return sqlRecord.value(role - Qt::UserRole);
}

QHash<int, QByteArray> SqlNoteModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[Qt::UserRole] = "comment_id";
    names[Qt::UserRole + 1] = "text";
    names[Qt::UserRole + 2] = "date_modified";

    return names;
}

void SqlNoteModel::addNote(const QString &content, const QDate &date)
{
    QSqlRecord newRecord = record();
    newRecord.setValue("text", content);
    newRecord.setValue("date_modified", date);
    if (!insertRecord(rowCount(), newRecord)) {
        qWarning() << "Failed to send message:" << lastError().text();
        return;
    }

}
