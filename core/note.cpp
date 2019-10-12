/*
 * Copyright (C) 2018-2019 André Hoarau <ah@ouvaton.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <QDate>
#include <QDebug>
#include <QSqlRecord>
#include <QVariantMap>
#include <QBuffer>
#include <QUrl>
#include <QFile>

#include "note.h"

Note::Note(QObject *parent)
    : DatabaseUtility(parent)
{
    m_table = "note";
    m_viewTable = "note_view";
}

void Note::addPlantingNote(int plantingId, int noteId) const
{
    addLink("planting_note", "planting_id", plantingId, "note_id", noteId);
}

void Note::removePlantingNote(int plantingId, int noteId) const
{
    removeLink("planting_note", "planting_id", plantingId, "note_id", noteId);
}

void Note::removePlantingNotes(int plantingId) const
{
    QString queryString = "DELETE FROM planting_note WHERY planting_id = %1)";
    QSqlQuery query(queryString.arg(plantingId));
    debugQuery(query);
}

void Note::addLocationNote(int locationId, int noteId) const
{
    addLink("location_note", "location_id", locationId, "note_id", noteId);
}

void Note::removeLocationNote(int locationId, int noteId) const
{
    removeLink("location_note", "location_id", locationId, "note_id", noteId);
}

void Note::removeLocationNotes(int locationId) const
{
    QString queryString = "DELETE FROM location_note WHERY location_id = %1)";
    QSqlQuery query(queryString.arg(locationId));
    debugQuery(query);
}

void Note::addTaskNote(int taskId, int noteId) const
{
    addLink("task_note", "task_id", taskId, "note_id", noteId);
}

void Note::removeTaskNote(int taskId, int noteId) const
{
    removeLink("task_note", "task_id", taskId, "note_id", noteId);
}

void Note::removeTaskNotes(int taskId) const
{
    QString queryString = "DELETE FROM task_note WHERY task_id = %1)";
    QSqlQuery query(queryString.arg(taskId));
    debugQuery(query);
}

void Note::addNoteFile(int noteId, int fileId) const
{
    addLink("note_file", "note_id", noteId, "file_id", fileId);
}

void Note::removeNoteFile(int noteId, int fileId) const
{
    removeLink("note_file", "note_id", noteId, "file_id", fileId);
}

void Note::removeNoteFiles(int noteId) const
{
    QString queryString = "DELETE FROM note_file WHERY note = %1)";
    QSqlQuery query(queryString.arg(noteId));
    debugQuery(query);
}

void Note::addPhoto(const QUrl &path, int noteId) const
{
    QFile file(path.toLocalFile());
    if (!file.open(QIODevice::ReadOnly)) {
        qDebug() << "[addPhoto] Can't open file" << path;
        return;
    }

    QByteArray byteArray = file.readAll();

    QSqlQuery query;
    query.prepare("INSERT INTO file (filename, data) values (:filename, :data);");
    query.bindValue(":filename", path);
    query.bindValue(":data", byteArray);
    query.exec();
    debugQuery(query);

    int fileId = query.lastInsertId().toInt();
    addNoteFile(noteId, fileId);
}

QList<int> Note::photoList(int noteId) const
{
    QString queryString = "SELECT * FROM note_file WHERE note_id = %1";
    return queryIds(queryString.arg(noteId), "file_id");
}
