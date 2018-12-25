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

#include <QDebug>
#include "nametree.h"

NameTree::NameTree(const QString &name, int level)
    : m_name(name)
    , m_level(level)
{
}

NameTree::~NameTree()
{
    qDeleteAll(m_childrenName);
}

void NameTree::insert(QList<QString> &path)
{
    if (path.isEmpty())
        return;

    QString name = path.takeFirst();
    if (!m_childrenName.contains(name))
        m_childrenName[name] = new NameTree(name, m_level + 1);
    m_childrenName.value(name)->insert(path);
}

QString NameTree::fullName() const
{
    if (m_childrenName.isEmpty())
        return m_name;

    QString name(m_name);
    for (auto child : m_childrenName) {
        name += child->fullName();
        switch (m_level) {
        case 0:
            name += " ";
            break;
        case 1:
            name += "|";
            break;
        default:
            name += ",";
        }
    }
    name.chop(1);
    return name;
}
