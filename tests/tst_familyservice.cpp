#include <QtTest>

#include "qrop.h"
#include "services/familyservice.h"

class TstFamilyService : public QObject
{
    Q_OBJECT

public:
    TstFamilyService() {}
    ~TstFamilyService() override = default;

private slots:
    void init();
    void cleanup();

    //    void initTestCase();
    //    void cleanupTestCase();

    void testPrivateInsertionMethods();

private:
    void _testInitialFamilyServiceState(FamilyService *familySvc);
};

void TstFamilyService::init()
{
    qDebug() << "Init Qrop instance";
    Qrop::instance()->initStatics();
}

void TstFamilyService::cleanup()
{
    qDebug() << "Clear Qrop instance";
    Qrop::instance()->clear();
}

void TstFamilyService::testPrivateInsertionMethods()
{
    FamilyService *familySvc = Qrop::instance()->familyService();
    _testInitialFamilyServiceState(familySvc);

    // add 2 families
    qrp::Family *fam1 =
            familySvc->addFamily(qrp::Family::getNextId(), false, "Family 1", 1, "black", false);
    qrp::Family *fam2 =
            familySvc->addFamily(qrp::Family::getNextId(), false, "Family 2", 1, "black", false);
    QVERIFY(familySvc->m_families.size() == 2);
    QVERIFY(fam1 != nullptr);
    QVERIFY(fam2 != nullptr);

    // add 1 crop and do all checks
    qrp::Crop *crop1 = familySvc->addCrop(qrp::Crop::getNextId(), false, "Crop 1 of Family 1",
                                          "black", fam1->id, false);
    QVERIFY(familySvc->m_crops.size() == 1);
    QVERIFY(crop1 != nullptr);
    QVERIFY(crop1->family == fam1);
    QVERIFY(fam1->crops.size() == 1);
    QVERIFY(fam1->crops.first() == crop1);

    // add 1 variety and do all checks
    qrp::Variety *var1 = familySvc->addVariety(qrp::Variety::getNextId(), false, "Variety 1",
                                               crop1->id, true, -1, false);
    QVERIFY(familySvc->m_varieties.size() == 1);
    QVERIFY(var1 != nullptr);
    QVERIFY(var1->crop == crop1);
    QVERIFY(crop1->varieties.size() == 1);
    QVERIFY(crop1->varieties.first() == var1);

    // check clear
    familySvc->clear();
    _testInitialFamilyServiceState(familySvc);
}

void TstFamilyService::_testInitialFamilyServiceState(FamilyService *familySvc)
{
    QVERIFY(familySvc != nullptr);
    QVERIFY(qrp::SeedCompany::sLastId == 0);
    QVERIFY(qrp::Family::sLastId == 0);
    QVERIFY(qrp::Crop::sLastId == 0);
    QVERIFY(qrp::Variety::sLastId == 0);
    QVERIFY(familySvc->m_seedCompanies.size() == 0);
    QVERIFY(familySvc->m_families.size() == 0);
    QVERIFY(familySvc->m_crops.size() == 0);
    QVERIFY(familySvc->m_varieties.size() == 0);
}

QTEST_APPLESS_MAIN(TstFamilyService)

#include "tst_familyservice.moc"
