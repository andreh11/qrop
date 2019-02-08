/*
 * Copyright (C) 2018 André Hoarau <ah@ouvaton.org>
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

#ifndef NOTE_H
#define NOTE_H

#include "core_global.h"
#include "databaseutility.h"

class CORESHARED_EXPORT Note : public DatabaseUtility
{
    Q_OBJECT
public:
    Note(QObject *parent = nullptr);
    Q_INVOKABLE void addPlantingNote(int plantingId, int noteId) const;
    Q_INVOKABLE void removePlantingNote(int plantingId, int noteId) const;
    Q_INVOKABLE void removePlantingNotes(int plantingId) const;

    Q_INVOKABLE void addLocationNote(int locationid, int noteId) const;
    Q_INVOKABLE void removeLocationNote(int locationid, int noteId) const;
    Q_INVOKABLE void removeLocationNotes(int plantingId) const;

    Q_INVOKABLE void addTaskNote(int taskId, int noteId) const;
    Q_INVOKABLE void removeTaskNote(int taskId, int noteId) const;
    Q_INVOKABLE void removeTaskNotes(int plantingId) const;

    Q_INVOKABLE void addNoteFile(int noteId, int fileId) const;
    Q_INVOKABLE void removeNoteFile(int noteId, int fileId) const;
    Q_INVOKABLE void removeNoteFiles(int noteId) const;
    Q_INVOKABLE void addPhoto(const QUrl &path, int noteId) const;
    Q_INVOKABLE QList<int> photoList(int noteId) const;
};

#endif // NOTE_H
