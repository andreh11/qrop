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

#ifndef QROP_H
#define QROP_H

#include <QObject>
#include <QSettings>
#include <QNetworkAccessManager>
#include <QMap>
#include <QSortFilterProxyModel>
#include "singleton.h"
#include "buildinfo.h"

class BuildInfo;
class Database;
class QropNews;
class QTranslator;
class FamilyProxyModel;
class SeedCompanyProxyModel;
class QUndoStack;

#include "business/family.h"
class Qrop : public QObject, public Singleton<Qrop>
{
    Q_OBJECT
    friend class Singleton<Qrop>;

private:
    QSettings m_settings;
    QTranslator *m_translator;

    Database *const m_db; //!< db connection
    BuildInfo *const m_buildInfo;

    QStringList m_errors; //!< non critical errors happening prior to the GUI
    QNetworkAccessManager m_netMgr; //!< for http(s) requests
    QropNews *m_news;

    QMap<int, qrp::Family *> m_families;
    QMap<int, qrp::Crop *> m_crops;
    QMap<int, qrp::Variety *> m_varieties;
    QMap<int, qrp::SeedCompany *> m_seedCompanies;

    FamilyProxyModel *m_familyProxyModel;
    SeedCompanyProxyModel *m_seedCompanyProxyModel;

    QUndoStack *m_undoStack;
    bool m_isLocalDatabase;

signals:
    void info(const QString &msg);
    void error(const QString &err);

    // signals for FamilyModel
    void beginResetFamilyModel();
    void endResetFamilyModel();

    void familyUpdated(int srcRow);
    void cropUpdated(int familyId, int srcRow);
    void varietyUpdated(int cropId, int srcRow);
    void varietyDeleted(int cropId, int varietyId);

    // signals for SeedCompanyModel
    void beginResetSeedCompanyModel();
    void endResetSeedCompanyModel();

private:
    Qrop(QObject *parent = nullptr);

    void clearBusinessObjects();

public:
    ~Qrop() override;

    int init();

    Q_INVOKABLE void undo();
    Q_INVOKABLE void redo();

    Q_INVOKABLE bool loadDatabase(const QUrl &url);
    Q_INVOKABLE QUrl defaultDatabaseUrl() const;
    Q_INVOKABLE bool saveDatabase(const QUrl &from, const QUrl &to);

    Q_INVOKABLE bool isMobileDevice() { return m_buildInfo->isMobileDevice(); }

    Q_INVOKABLE QropNews *news() const { return m_news; }

    bool hasErrors() const { return m_errors.size() != 0; }
    void showErrors()
    {
        emit error(m_errors.join("\n"));
        m_errors.clear();
    }

    bool isLocalDatabase() const { return m_isLocalDatabase; }

    QNetworkAccessManager &networkManager() { return m_netMgr; }
    Q_INVOKABLE BuildInfo *buildInfo() const { return m_buildInfo; }

    void sendInfo(const QString &msg)
    {
        emit info(msg);
        qDebug() << msg;
    }
    void sendError(const QString &err)
    {
        emit error(err);
        qCritical() << err;
    }

    QString preferredLanguage() const
    {
        return m_settings.value("preferredLanguage", "system").toString();
    }

    QDate lastNewsUpdate() const
    {
        QString dateStr = m_settings.value("lastNewsUpdate", "").toString();
        return dateStr.isEmpty() ? QDate() : QDate::fromString(dateStr, Qt::ISODate);
    }

    bool newReleaseAvailable(const QString &lastOnlineVersion);

    qrp::Family *family(int familyId) const { return m_families.value(familyId, nullptr); }
    qrp::Crop *crop(int cropId) const { return m_crops.value(cropId, nullptr); }
    qrp::Variety *variety(int varietyId) const { return m_varieties.value(varietyId, nullptr); }
    qrp::SeedCompany *seedCompany(int seedCompanyId)
    {
        return m_seedCompanies.value(seedCompanyId, nullptr);
    }

    void addSeedCompany(int id, bool del, const QString &name, bool is_default)
    {
        m_seedCompanies.insert(id, new qrp::SeedCompany(id, del, name, is_default));
    }
    void addFamily(int id, bool del, const QString &name, ushort interval, const QString &color)
    {
        m_families.insert(id, new qrp::Family(id, del, name, interval, color));
    }
    void addCrop(int id, bool del, const QString &name, const QString &color, int family_id)
    {
        qrp::Family *fam = family(family_id);
        if (fam) {
            qrp::Crop *crop = new qrp::Crop(id, del, name, color, fam);
            m_crops.insert(id, crop);
            fam->addCrop(crop);
        }
    }
    void addVariety(int id, bool del, const QString &name, int crop_id, bool is_default,
                    int seed_company_id)
    {
        qrp::Crop *crp = crop(crop_id);
        if (crp) {
            qrp::SeedCompany *seed = seedCompany(seed_company_id);
            qrp::Variety *variety = new qrp::Variety(id, del, name, is_default, crp, seed);
            m_varieties.insert(id, variety);
            crp->addVariety(variety);
        }
    }

    Q_INVOKABLE QAbstractItemModel *modelFamily() const;
    int numberOfFamilies() const { return m_families.size(); }
    qrp::Family *familyFromIndexRow(int row) const
    {
        if (row >= m_families.size())
            return nullptr;
        auto it = m_families.cbegin();
        it += row;
        return it.value();
    }

    Q_INVOKABLE QAbstractItemModel *modelSeedCompany() const;
    int numberOfSeedCompanies() const { return m_seedCompanies.size(); }
    qrp::SeedCompany *seedCompanyFromIndexRow(int row) const
    {
        if (row >= m_seedCompanies.size())
            return nullptr;
        auto it = m_seedCompanies.cbegin();
        it += row;
        return it.value();
    }
    Q_INVOKABLE int seedCompanyIdFromProxyRow(int proxyRow) const;
    Q_INVOKABLE int seedCompanyProxyIndex(int seedCompanyId) const;

    Q_INVOKABLE void updateFamilyName(int proxyRow, int family_id, const QString &oldV,
                                      const QString &newV);
    Q_INVOKABLE void updateFamilyColor(int proxyRow, int family_id, const QString &oldV,
                                       const QString &newV);
    Q_INVOKABLE void updateFamilyInterval(int proxyRow, int family_id, int oldV, int newV);

    Q_INVOKABLE void updateCropName(int srcRow, int family_id, int crop_id, const QString &oldV,
                                    const QString &newV);
    Q_INVOKABLE void updateCropColor(int srcRow, int family_id, int crop_id, const QString &oldV,
                                     const QString &newV);

    Q_INVOKABLE void updateVarietyName(int srcRow, int crop_id, int variety_id, const QString &oldV,
                                       const QString &newV);
    Q_INVOKABLE void updateVarietyCompanySeed(int srcRow, int crop_id, int variety_id, int oldV,
                                              int newV);
    Q_INVOKABLE void updateVarietyIsDefault(int srcRow, int crop_id, int variety_id, bool oldV,
                                            bool newV);

    Q_INVOKABLE void deleteVariety(int crop_id, int variety_id);

private:
    void loadCurrentDatabase();
    void installTranslator();

    void _dumpSettings();
};

#endif // QROP_H
