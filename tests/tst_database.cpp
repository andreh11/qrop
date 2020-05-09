#include <QtTest>
#include <QCoreApplication>
#include <QSqlDatabase>
#include <QDate>

#include "db.h"

class tst_Database : public QObject
{
    Q_OBJECT

public:
    tst_Database();
    ~tst_Database();

private:
    Database *mDatabase;

private slots:
    void databasePath();
    void connectToDatabase();
    void init();
    void cleanup();
};

tst_Database::tst_Database()
    : mDatabase(nullptr)
{
}

tst_Database::~tst_Database() = default;

void tst_Database::init()
{
    mDatabase = new Database;
}

void tst_Database::cleanup()
{
    delete mDatabase;
}

void tst_Database::databasePath()
{
    QVERIFY(mDatabase->databasePath().contains("qrop.db"));
}

void tst_Database::connectToDatabase()
{
    mDatabase->connectToDatabase();
    QVERIFY(QSqlDatabase::database().isValid());
}

// QTEST_MAIN(tst_Database)

QTEST_APPLESS_MAIN(tst_Database)

#include "tst_database.moc"
