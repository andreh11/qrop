#include <QtTest>

#include "qrop.h"
#include "services/familyservice.h"
#include "models/familymodel.h"

class TstFamilyService : public QObject
{
    Q_OBJECT

public:
    TstFamilyService()
        : m_familySvc(nullptr)
    {
    }
    ~TstFamilyService() override = default;

private slots:
    void init();
    void cleanup();

    void testPrivateInsertionMethods();
    void testAddMethods();
    void testUndoRedoOnCreationThenDeletion();

private:
    void _testInitialFamilyServiceState();
    void _cleanupTestCase();

    FamilyService *m_familySvc;
};

void TstFamilyService::init()
{
    //    qDebug() << "Init Qrop instance";
    Qrop::instance()->initStatics();
    m_familySvc = Qrop::instance()->familyService();
}

void TstFamilyService::cleanup()
{
    //    qDebug() << "Clear Qrop instance";
    Qrop::instance()->clear();
}

void TstFamilyService::_cleanupTestCase()
{
    //    qDebug() << "running cleanup";
    m_familySvc->clear();
    _testInitialFamilyServiceState();
}

void TstFamilyService::_testInitialFamilyServiceState()
{
    QVERIFY(m_familySvc != nullptr);
    QVERIFY(qrp::SeedCompany::sLastId == 0);
    QVERIFY(qrp::Family::sLastId == 0);
    QVERIFY(qrp::Crop::sLastId == 0);
    QVERIFY(qrp::Variety::sLastId == 0);
    QVERIFY(m_familySvc->m_seedCompanies.size() == 0);
    QVERIFY(m_familySvc->m_families.size() == 0);
    QVERIFY(m_familySvc->m_crops.size() == 0);
    QVERIFY(m_familySvc->m_varieties.size() == 0);
}

void TstFamilyService::testPrivateInsertionMethods()
{
    _testInitialFamilyServiceState();

    // add 2 families
    qrp::Family *fam1 =
            m_familySvc->addFamily(qrp::Family::getNextId(), false, "Family 1", 1, "black", false);
    qrp::Family *fam2 =
            m_familySvc->addFamily(qrp::Family::getNextId(), false, "Family 2", 1, "black", false);
    QVERIFY(m_familySvc->m_families.size() == 2);
    QVERIFY(fam1 != nullptr);
    QVERIFY(fam2 != nullptr);

    // add 1 crop and do all checks
    qrp::Crop *crop1 = m_familySvc->addCrop(qrp::Crop::getNextId(), false, "Crop 1 of Family 1",
                                            "black", fam1->id, false);
    QVERIFY(m_familySvc->m_crops.size() == 1);
    QVERIFY(crop1 != nullptr);
    QVERIFY(crop1->family == fam1);
    QVERIFY(fam1->crops.size() == 1);
    QVERIFY(fam1->crops.last() == crop1);

    // add 1 variety and do all checks
    qrp::Variety *var1 = m_familySvc->addVariety(qrp::Variety::getNextId(), false, "Variety 1",
                                                 crop1->id, true, -1, false);
    QVERIFY(m_familySvc->m_varieties.size() == 1);
    QVERIFY(var1 != nullptr);
    QVERIFY(var1->crop == crop1);
    QVERIFY(crop1->varieties.size() == 1);
    QVERIFY(crop1->varieties.last() == var1);

    _cleanupTestCase();
}

void TstFamilyService::testAddMethods()
{
    _testInitialFamilyServiceState();

    // add 2 families
    int famId1 = m_familySvc->addNewFamily("Family 1", "black");
    QVERIFY(famId1 == 1);
    QVERIFY(m_familySvc->m_families.size() == 1);
    qrp::Family *fam1 = m_familySvc->family(famId1);
    QVERIFY(fam1 != nullptr);

    int famId2 = m_familySvc->addNewFamily("Family 2", "black");
    QVERIFY(famId2 == 2);
    QVERIFY(m_familySvc->m_families.size() == 2);
    qrp::Family *fam2 = m_familySvc->family(famId2);
    QVERIFY(fam2 != nullptr);

    // add 1 crop and do all checks
    int cropId1 = m_familySvc->addNewCrop(famId1, "Crop 1 of Family 1", "black");
    QVERIFY(cropId1 == 1);
    QVERIFY(m_familySvc->m_crops.size() == 1);
    qrp::Crop *crop1 = m_familySvc->crop(cropId1);
    QVERIFY(crop1 != nullptr);
    QVERIFY(crop1->family == fam1);
    QVERIFY(fam1->crops.size() == 1);
    QVERIFY(fam1->crops.last() == crop1);
    QVERIFY(crop1->varieties.size() == 1); // Unknown one
    QVERIFY(crop1->varieties.last()->name == tr("Unknown"));

    // add a second variety and do all checks
    int varId1 = m_familySvc->addNewVariety(crop1->id, "Variety 1", -1);
    QVERIFY(varId1 == 2);
    QVERIFY(m_familySvc->m_varieties.size() == 2);
    qrp::Variety *var1 = m_familySvc->variety(varId1);
    QVERIFY(var1 != nullptr);
    QVERIFY(var1->crop == crop1);
    QVERIFY(crop1->varieties.last() == var1);

    _cleanupTestCase();
}

void TstFamilyService::testUndoRedoOnCreationThenDeletion()
{
    _testInitialFamilyServiceState();

    // add 1 family
    int famId1 = m_familySvc->addNewFamily("Family 1", "black");
    QVERIFY(famId1 == 1);
    QVERIFY(m_familySvc->m_families.size() == 1);
    qrp::Family *fam1 = m_familySvc->family(famId1);
    QVERIFY(fam1 != nullptr);
    QVERIFY(fam1->deleted == false); // CmdFamilyAddDel::redo has been executed
    QVERIFY(m_familySvc->m_familyProxyModel->rowCount() == 1);

    Qrop *qrop = Qrop::instance();
    // undo => fam1 deleted
    qrop->undo();
    QVERIFY(fam1->deleted == true);
    QVERIFY(m_familySvc->m_familyProxyModel->rowCount() == 0);

    // redo => fam1 visible
    qrop->redo();
    QVERIFY(fam1->deleted == false);
    QVERIFY(m_familySvc->m_familyProxyModel->rowCount() == 1);

    // delete fam1
    m_familySvc->deleteFamily(fam1->id);
    QVERIFY(fam1->deleted == true);
    QVERIFY(m_familySvc->m_familyProxyModel->rowCount() == 0);

    // undo => fam1 visible again
    qrop->undo();
    QVERIFY(fam1->deleted == false);
    QVERIFY(m_familySvc->m_familyProxyModel->rowCount() == 1);

    // undo again (creation) => fam1 deleted
    qrop->undo();
    QVERIFY(fam1->deleted == true);
    QVERIFY(m_familySvc->m_familyProxyModel->rowCount() == 0);

    _cleanupTestCase();
}

QTEST_APPLESS_MAIN(TstFamilyService)

#include "tst_familyservice.moc"
