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

#ifndef SQLPLANTINGMODEL_H
#define SQLPLANTINGMODEL_H

#include "sqltablemodel.h"

class SqlPlantingModel : public SqlTableModel
{
    Q_OBJECT
    Q_PROPERTY(QString crop READ crop WRITE setCrop NOTIFY cropChanged)

public:
    SqlPlantingModel(QObject *parent = nullptr);

    QString crop() const;
    void setCrop(const QString &crop);

    QVariant data(const QModelIndex &idx, int role) const Q_DECL_OVERRIDE;

signals:
    void cropChanged();

private:
    QString m_crop;
    QHash<QString, int> m_rolesIndexes;
    QHash<QModelIndex, bool> m_selected;
};

#endif // SQLPLANTINGMODEL_H
