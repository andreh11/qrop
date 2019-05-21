/*
 * Copyright (C) 2018, 2019 André Hoarau <ah@ouvaton.org>
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
#include <QPair>
#include <QDebug>
#include <QVariantMap>

#include "templatetask.h"

TemplateTask::TemplateTask(QObject *parent)
    : DatabaseUtility(parent)
{
    m_table = "template_task";
    m_viewTable = "template_task_view";
}

int TemplateTask::add(const QVariantMap &map) const
{
    QVariantMap newMap(map);

    int methodId = newMap.value("task_method_id").toInt();
    if (methodId < 1)
        newMap.take("task_method_id");

    int implementId = newMap.value("task_implement_id").toInt();
    if (implementId < 1)
        newMap.take("task_implement_id");

    int id = DatabaseUtility::add(newMap);
    return id;
}
