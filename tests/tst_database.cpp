#include <QCoreApplication>
#include <QSqlDatabase>
#include <QDate>
#include <QPair>

#include "tst_database.h"
#include "db.h"

tst_Database::tst_Database()
    : mDatabase(nullptr)
{
}

tst_Database::~tst_Database() {}

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

QTEST_MAIN(tst_Database)
