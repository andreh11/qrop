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

#ifndef NAMETREE_H
#define NAMETREE_H

#include <QMap>
#include <QString>

#include "core_global.h"

class CORESHARED_EXPORT NameTree
{
public:
    NameTree(const QString &name, int level);
    ~NameTree();
    void insert(QList<QString> &path);
    QString fullName() const;

private:
    QString m_name;
    int m_level;
    QMap<QString, NameTree *> m_childrenName;
};

#endif // NAMETREE_H
