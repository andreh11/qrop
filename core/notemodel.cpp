#include "notemodel.h"

#include <QDebug>
#include <QSqlRecord>
#include <QSqlError>
#include <QSqlQuery>

static const char *noteTableName = "note";

NoteModel::NoteModel(QObject *parent)
    : SqlTableModel(parent)
{
    m_date = QDate();

    setTable(noteTableName);
    setSort(2, Qt::AscendingOrder);
    setEditStrategy(QSqlTableModel::OnManualSubmit);
    select();
}

//void NoteModel::removePlantingNotes(int plantingId)
//{
//    qDebug() << "[NoteModel] Removing notes of planting" << plantingId;
//    QString queryString("DELETE FROM planting_note WHERE planting_id = %1");
//    QSqlQuery query(queryString.arg(plantingId));
//}

QDate NoteModel::date() const
{
    return m_date;
}

void NoteModel::setDate(const QDate &date)
{
    if (date == m_date)
        return;

    m_date = date;

    const QString filterString = QString::fromLatin1(
                "date_assigned = %1").arg(date.toString(Qt::ISODate));
    setFilter(filterString);
    select();

    emit dateChanged();
}

//void NoteModel::addNote(const QString &content, const QDate &date)
//{
//    QSqlRecord newRecord = record();
//    newRecord.setValue("text", content);
//    newRecord.setValue("date_modified", date);
//    if (!insertRecord(rowCount(), newRecord)) {
//        qWarning() << "Failed to send message:" << lastError().text();
//        return;
//    }

//    submitAll();
//}
