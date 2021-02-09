/*
 * Copyright (C) 2021 André Hoarau <ah@ouvaton.org>
 *                  & Matthieu Bruel <Matthieu.Bruel@gmail.com>
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

#ifndef CMDUPDATE_H
#define CMDUPDATE_H

#include <QUndoCommand>
#include <QVariant>
#include "cmdfamily.h"
class CmdUpdate : public QUndoCommand, public CmdFamily
{
public:
    explicit CmdUpdate(int row, int role, const QVariant &oldV, const QVariant &newV)
        : QUndoCommand(nullptr), m_row(row), m_role(role), m_oldValue(oldV), m_newValue(newV){}

    virtual QString str() const {return QString("row: %1, role: %2, <old: %3>, <new: %4>").arg(
                    m_row).arg(m_role).arg(variantStr(m_oldValue)).arg(variantStr(m_newValue));}

    QString variantStr(const QVariant &v) const {
        switch(v.type())
        {
        case QMetaType::QString:
            return v.toString();
        case QMetaType::Bool:
            return v.toBool() ? "true" : "false";
        case QMetaType::Int:
            return QString("%1").arg(v.toInt());
        case QMetaType::UInt:
            return QString("%1").arg(v.toUInt());
        case QMetaType::Double:
            return QString("%1").arg(v.toDouble());
        case QMetaType::QChar:
            return QString("%1").arg(v.toChar());
        case QMetaType::Long:
        case QMetaType::LongLong:
            return QString("%1").arg(v.toLongLong());
        case QMetaType::ULong:
        case QMetaType::ULongLong:
            return QString("%1").arg(v.toULongLong());
        case QMetaType::Float:
            return QString("%1").arg(v.toFloat());
        default:
            return QString("TODO variantStr...");
        }
    }
protected:
    const int m_row;
    const int m_role;
    const QVariant m_oldValue;
    const QVariant m_newValue;
};

#endif // CMDUPDATE_H
