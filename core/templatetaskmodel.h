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

#ifndef TEMPLATETASKMODEL_H
#define TEMPLATETASKMODEL_H

#include <QDate>

#include "core_global.h"
#include "sortfilterproxymodel.h"

class CORESHARED_EXPORT TemplateTaskModel : public SortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(int taskTemplateId READ taskTemplateId WRITE setTaskTemplateId NOTIFY taskTemplateIdChanged)
    Q_PROPERTY(int templateDateType READ templateDateType WRITE setTemplateDateType NOTIFY templateDateTypeChanged)
    Q_PROPERTY(bool beforeDate READ beforeDate WRITE setBeforeDate NOTIFY beforeDateChanged)

public:
    TemplateTaskModel(QObject *parent = nullptr, const QString &tableName = "template_task_view");
//    bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;

    int taskTemplateId() const;
    void setTaskTemplateId(int taskTemplateId);

    int templateDateType() const;
    void setTemplateDateType(int templateDateType);

    bool beforeDate() const;
    void setBeforeDate(bool before);

signals:
    void taskTemplateIdChanged();
    void templateDateTypeChanged();
    void beforeDateChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

private:
    int m_taskTemplateId;
    int m_templateDateType;
    bool m_beforeDate;
};

#endif // TEMPLATETASKMODEL_H
