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

#ifndef QRP_FAMILY_H
#define QRP_FAMILY_H
#include <QtGlobal>
#include <QString>
#include <QList>
#include <QHash>
#include <QVariantMap>
#include "core_global.h"
namespace qrp {

struct Crop;
struct Variety;

struct CORESHARED_EXPORT SeedCompany {
    static int sLastId;
    static int getNextId() { return ++sLastId; }

    int id;
    bool deleted;
    QString name;
    bool isDefault;
    SeedCompany(int id_, bool del, const QString &n, bool d)
        : id(id_)
        , deleted(del)
        , name(n)
        , isDefault(d)
    {
    }
};

struct CORESHARED_EXPORT Family {
    static int sLastId;
    static int getNextId() { return ++sLastId; }

    int id;
    bool deleted;
    QString name;
    uint interval;
    QString color;
    QList<Crop *> crops;

    Family(int id_, bool del, const QString &n, uint i, const QString &c)
        : id(id_)
        , deleted(del)
        , name(n)
        , interval(i)
        , color(c)
        , crops()
    {
    }

    void addCrop(Crop *c) { crops << c; }

    Crop *crop(int row) const
    {
        if (row >= crops.size())
            return nullptr;
        return crops.at(row);
    }

    int row(int crop_id) const;
};

struct CORESHARED_EXPORT Crop {
    static int sLastId;
    static int getNextId() { return ++sLastId; }

    int id;
    bool deleted;
    QString name;
    QString color;
    Family *family;
    QList<Variety *> varieties;
    Crop(int id_, bool del, const QString &n, const QString &c, Family *f)
        : id(id_)
        , deleted(del)
        , name(n)
        , color(c)
        , family(f)
        , varieties()
    {
    }

    void addVariety(Variety *v) { varieties << v; }

    Variety *variety(int row) const
    {
        if (row >= varieties.size())
            return nullptr;
        return varieties.at(row);
    }

    int row(int variety_id) const;
};

struct CORESHARED_EXPORT Variety {
    static int sLastId;
    static int getNextId() { return ++sLastId; }

    int id;
    bool deleted;
    QString name;
    bool isDefault;
    Crop *crop;
    SeedCompany *seedCompany; //!< update from DB schema to allow several companies
    Variety(int id_, bool del, const QString &n, bool d, Crop *c, SeedCompany *s)
        : id(id_)
        , deleted(del)
        , name(n)
        , isDefault(d)
        , crop(c)
        , seedCompany(s)
    {
    }

    enum Role {
        r_name = Qt::DisplayRole,
        r_id = Qt::UserRole,
        r_deleted,
        r_isDefault,
        r_seedCompanyId,
        r_seedCompanyName,
    };

    static const QHash<int, QByteArray> sRoleNames;
    inline static QString roleName(int role) { return sRoleNames.value(role, ""); }

    inline QVariant data(int role) const
    {
        switch (role) {
        case Role::r_name:
            return name;
        case Role::r_id:
            return id;
        case Role::r_deleted:
            return deleted;
        case Role::r_isDefault:
            return isDefault;
        case Role::r_seedCompanyId:
            return seedCompany ? seedCompany->id : -1;
        case Role::r_seedCompanyName:
            return seedCompany ? seedCompany->name : "";
        default:
            return QVariant();
        }
    }

    inline QVariantMap toMap() const
    {
        QVariantMap map;
        for (auto it = sRoleNames.cbegin(), itEnd = sRoleNames.cend(); it != itEnd; ++it)
            map.insert(it.value(), data(static_cast<Role>(it.key())));
        return map;
    }
};

} // namespace qrp
#endif // FAMILY_H
