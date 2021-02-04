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

namespace qrp {

struct Crop;
struct Variety;

struct SeedCompany {
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

struct Family {
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
};

struct Crop {
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
};

struct Variety {
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
};

} // namespace qrp
#endif // FAMILY_H
