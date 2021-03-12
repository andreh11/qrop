#include "familyservice.h"
#include "qrop.h"
#include "models/familymodel.h"
#include "models/seedcompanymodel.h"
#include "commands/cmdfamilyupdate.h"
#include "commands/cmdcropupdate.h"
#include "commands/cmdvarietyupdate.h"
#include "commands/cmdvarietyadddel.h"
#include "commands/cmdcropadddel.h"
#include "commands/cmdfamilyadddel.h"

FamilyService::FamilyService(QObject *parent)
    : QObject(parent)
    , m_familyProxyModel(new FamilyProxyModel(this))
    , m_seedCompanyProxyModel(new SeedCompanyProxyModel(this))
{
}

FamilyService::~FamilyService()
{
    delete m_seedCompanyProxyModel;
    delete m_familyProxyModel;

    qDeleteAll(m_seedCompanies);
    qDeleteAll(m_families);
    qDeleteAll(m_crops);
    qDeleteAll(m_varieties);

    qDebug() << "FamilyService Deleted";
}

void FamilyService::clear()
{
    if (!m_seedCompanies.isEmpty()) {
        emit beginResetSeedCompanyModel();
        qDeleteAll(m_seedCompanies);
        m_seedCompanies.clear();
        emit endResetSeedCompanyModel();
    }
    if (!m_families.isEmpty()) {
        emit beginResetFamilyModel();
        qDeleteAll(m_families);
        m_families.clear();
        emit endResetFamilyModel();
    }
    qDeleteAll(m_crops);
    m_crops.clear();
    qDeleteAll(m_varieties);
    m_varieties.clear();

    qrp::SeedCompany::sLastId = 0;
    qrp::Family::sLastId = 0;
    qrp::Crop::sLastId = 0;
    qrp::Variety::sLastId = 0;
}

QAbstractItemModel *FamilyService::modelFamily() const
{
    return m_familyProxyModel;
}

QAbstractItemModel *FamilyService::modelSeedCompany() const
{
    return m_seedCompanyProxyModel;
}

int FamilyService::seedCompanyIdFromProxyRow(int proxyRow) const
{
    QModelIndex proxyIndex = m_seedCompanyProxyModel->index(proxyRow, 0);
    if (proxyIndex.isValid())
        return m_seedCompanyProxyModel->data(proxyIndex, SeedCompanyModel2::SeedCompanyRole::id).toInt();
    return 0;
}

int FamilyService::seedCompanyProxyIndex(int seedCompanyId) const
{
    for (int row = 0; row < m_seedCompanyProxyModel->rowCount(); ++row) {
        if (seedCompanyId
            == m_seedCompanyProxyModel
                       ->data(m_seedCompanyProxyModel->index(row, 0),
                              SeedCompanyModel2::SeedCompanyRole::id)
                       .toInt())
            return row;
    }
    qDebug() << "[FamilyService::seedCompanyProxyIndex] NOT FOUND seedCompanyId: " << seedCompanyId;
    return 0;
}

void FamilyService::updateFamilyName(int proxyRow, int family_id, const QString &oldV,
                                     const QString &newV)
{
    int srcRow = m_familyProxyModel->sourceRow(proxyRow);
    qDebug() << "[FamilyService::updateFamilyName] Row: " << srcRow << ", family_id: " << family_id
             << ", oldV : " << oldV << ", newV: " << newV;
    if (oldV != newV)
        Qrop::instance()->pushCommand(
                new CmdFamilyUpdate(srcRow, family_id, FamilyModel2::FamilyRole::name, oldV, newV));
}

void FamilyService::updateFamilyColor(int proxyRow, int family_id, const QString &oldV,
                                      const QString &newV)
{
    int srcRow = m_familyProxyModel->sourceRow(proxyRow);
    qDebug() << "[FamilyService::updateFamilyColor] Row: " << srcRow << ", family_id: " << family_id
             << ", oldV : " << oldV << ", newV: " << newV;
    if (oldV != newV)
        Qrop::instance()->pushCommand(
                new CmdFamilyUpdate(srcRow, family_id, FamilyModel2::FamilyRole::color, oldV, newV));
}

void FamilyService::updateFamilyInterval(int proxyRow, int family_id, int oldV, int newV)
{
    int srcRow = m_familyProxyModel->sourceRow(proxyRow);
    qDebug() << "[FamilyService::updateFamilyInterval] Row: " << srcRow
             << ", family_id: " << family_id << ", oldV : " << oldV << ", newV: " << newV;
    if (oldV != newV)
        Qrop::instance()->pushCommand(new CmdFamilyUpdate(
                srcRow, family_id, FamilyModel2::FamilyRole::interval, oldV, newV));
}

void FamilyService::updateCropName(int srcRow, int family_id, int crop_id, const QString &oldV,
                                   const QString &newV)
{
    qDebug() << "[FamilyService::updateCropName] Row: " << srcRow << ", family_id: " << family_id
             << ", crop_id: " << crop_id << ", oldV : " << oldV << ", newV: " << newV;
    if (oldV != newV)
        Qrop::instance()->pushCommand(new CmdCropUpdate(srcRow, family_id, crop_id,
                                                        CropModel2::CropRole::name, oldV, newV));
}

void FamilyService::updateCropColor(int srcRow, int family_id, int crop_id, const QString &oldV,
                                    const QString &newV)
{
    qDebug() << "[FamilyService::updateCropColor] Row: " << srcRow << ", family_id: " << family_id
             << ", crop_id: " << crop_id << ", oldV : " << oldV << ", newV: " << newV;
    if (oldV != newV)
        Qrop::instance()->pushCommand(new CmdCropUpdate(srcRow, family_id, crop_id,
                                                        CropModel2::CropRole::color, oldV, newV));
}

void FamilyService::updateVarietyName(int srcRow, int crop_id, int variety_id, const QString &oldV,
                                      const QString &newV)
{
    qDebug() << "[FamilyService::updateVarietyName] Row: " << srcRow << ", crop_id: " << crop_id
             << ", variety_id: " << variety_id << ", oldV : " << oldV << ", newV: " << newV;
    if (oldV != newV)
        Qrop::instance()->pushCommand(new CmdVarietyUpdate(srcRow, crop_id, variety_id,
                                                           qrp::Variety::r_name, oldV, newV));
}

void FamilyService::updateVarietyCompanySeed(int srcRow, int crop_id, int variety_id, int oldV, int newV)
{
    qDebug() << "[FamilyService::updateVarietyCompanySeed] Row: " << srcRow << ", crop_id: " << crop_id
             << ", variety_id: " << variety_id << ", oldV : " << oldV << ", newV: " << newV;
    if (oldV != newV)
        Qrop::instance()->pushCommand(new CmdVarietyUpdate(
                srcRow, crop_id, variety_id, qrp::Variety::r_seedCompanyId, oldV, newV));
}

void FamilyService::updateVarietyIsDefault(int srcRow, int crop_id, int variety_id, bool oldV, bool newV)
{
    qDebug() << "[FamilyService::updateVarietyIsDefault] Row: " << srcRow << ", crop_id: " << crop_id
             << ", variety_id: " << variety_id << ", oldV : " << oldV << ", newV: " << newV;

    if (oldV != newV)
        Qrop::instance()->pushCommand(new CmdVarietyUpdate(srcRow, crop_id, variety_id,
                                                           qrp::Variety::r_isDefault, oldV, newV));
}

void FamilyService::deleteVariety(int crop_id, int variety_id)
{
    qDebug() << "[FamilyService::deleteVariety]  crop_id: " << crop_id << ", variety_id: " << variety_id;
    Qrop::instance()->pushCommand(new CmdVarietyAddDel(crop_id, variety_id));
}

int FamilyService::addNewVariety(int crop_id, const QString &name, int seedCompanyId)
{
    CmdVarietyAddDel *cmd = new CmdVarietyAddDel(crop_id, name, seedCompanyId);
    qDebug() << "[FamilyService::addNewVariety]  crop_id: " << crop_id << ", name: " << name
             << " => id: " << cmd->varietyId();
    Qrop::instance()->pushCommand(cmd);
    return cmd->varietyId();
}

void FamilyService::deleteCrop(int familyId, int cropId)
{
    qDebug() << "[FamilyService::deleteCrop]  familyId: " << familyId << ", cropId: " << cropId;
    Qrop::instance()->pushCommand(new CmdCropAddDel(familyId, cropId));
}

int FamilyService::addNewCrop(int familyId, const QString &name, const QString &color)
{
    CmdCropAddDel *cmd = new CmdCropAddDel(familyId, name, color);
    qDebug() << "[FamilyService::addNewCrop]  familyId: " << familyId << ", name: " << name
             << " => id: " << cmd->cropId();
    Qrop::instance()->pushCommands(tr("Create crop %1").arg(name),
                                   { cmd, new CmdVarietyAddDel(cmd->cropId(), tr("Unknown"), 0, true) });
    return cmd->cropId();
}

void FamilyService::deleteFamily(int familyId)
{
    qDebug() << "[FamilyService::deleteFamily]  familyId: " << familyId;
    Qrop::instance()->pushCommand(new CmdFamilyAddDel(familyId));
}

int FamilyService::addNewFamily(const QString &name, const QString &color)
{
    CmdFamilyAddDel *cmd = new CmdFamilyAddDel(name, color);
    qDebug() << "[FamilyService::addNewFamily]  name: " << name << " => id: " << cmd->familyId();
    Qrop::instance()->pushCommand(cmd);
    return cmd->familyId();
}
