#ifndef FAMILYSERVICE_H
#define FAMILYSERVICE_H

#include <QObject>
#include <QMap>
#include "core_global.h"
#include "../business/family.h"
class FamilyProxyModel;
class SeedCompanyProxyModel;
class QAbstractItemModel;

class CORESHARED_EXPORT FamilyService : public QObject
{
    Q_OBJECT

public:
    FamilyService(QObject *parent = nullptr);
    ~FamilyService();

    void clear();

    int numberOfSeedCompanies() const { return m_seedCompanies.size(); }
    int numberOfFamilies() const { return m_families.size(); }
    int numberOfCrops() const { return m_crops.size(); }
    int numberOfVarieties() const { return m_varieties.size(); }


    qrp::Family *family(int familyId) const { return m_families.value(familyId, nullptr); }
    qrp::Crop *crop(int cropId) const { return m_crops.value(cropId, nullptr); }
    qrp::Variety *variety(int varietyId) const { return m_varieties.value(varietyId, nullptr); }
    qrp::SeedCompany *seedCompany(int seedCompanyId) const
    {
        return m_seedCompanies.value(seedCompanyId, nullptr);
    }

    void addSeedCompany(int id, bool del, const QString &name, bool is_default)
    {
        m_seedCompanies.insert(id, new qrp::SeedCompany(id, del, name, is_default));
        if (id > qrp::SeedCompany::sLastId)
            qrp::SeedCompany::sLastId = id;
    }
    void addFamily(int id, bool del, const QString &name, ushort interval, const QString &color)
    {
        m_families.insert(id, new qrp::Family(id, del, name, interval, color));
        if (id > qrp::Family::sLastId)
            qrp::Family::sLastId = id;
    }
    void addCrop(int id, bool del, const QString &name, const QString &color, int family_id)
    {
        qrp::Family *fam = family(family_id);
        if (fam) {
            qrp::Crop *crop = new qrp::Crop(id, del, name, color, fam);
            m_crops.insert(id, crop);
            fam->addCrop(crop);
            if (id > qrp::Crop::sLastId)
                qrp::Crop::sLastId = id;
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
            if (id > qrp::Variety::sLastId)
                qrp::Variety::sLastId = id;
        }
    }

    Q_INVOKABLE QAbstractItemModel *modelFamily() const;
    qrp::Family *familyFromIndexRow(int row) const
    {
        if (row >= m_families.size())
            return nullptr;
        auto it = m_families.cbegin();
        it += row;
        return it.value();
    }

    Q_INVOKABLE QAbstractItemModel *modelSeedCompany() const;
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
    Q_INVOKABLE void addNewVariety(int crop_id, const QString &name, int seedCompanyId);

signals:
    // signals for FamilyModel
    void beginResetFamilyModel();
    void endResetFamilyModel();

    void familyUpdated(int srcRow);
    void cropUpdated(int familyId, int srcRow);
    void varietyUpdated(int cropId, int srcRow);

    void beginAppendVariety(int cropId);
    void endAppendVariety(int endId);
    void varietyVisible(int cropId, int varietyId);

    // signals for SeedCompanyModel
    void beginResetSeedCompanyModel();
    void endResetSeedCompanyModel();

private:
    QMap<int, qrp::Family *> m_families;
    QMap<int, qrp::Crop *> m_crops;
    QMap<int, qrp::Variety *> m_varieties;
    QMap<int, qrp::SeedCompany *> m_seedCompanies;

    FamilyProxyModel *m_familyProxyModel;
    SeedCompanyProxyModel *m_seedCompanyProxyModel;

};

#endif // FAMILYSERVICE_H
