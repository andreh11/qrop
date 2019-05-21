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

#ifndef TEMPLATE_TASK_H
#define TEMPLATE_TASK_H

#include <QDate>

#include "core_global.h"
#include "databaseutility.h"

class CORESHARED_EXPORT TemplateTask : public DatabaseUtility
{
    Q_OBJECT
public:
    TemplateTask(QObject *parent = nullptr);
    Q_INVOKABLE int add(const QVariantMap &map) const override;
};

#endif // TEMPLATE_TASK_H
