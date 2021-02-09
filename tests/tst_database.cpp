#include <QtTest>
#include <QCoreApplication>
#include <QSqlDatabase>
#include <QDate>

#include "dbutils/db.h"

class tst_Database : public QObject
{
    Q_OBJECT

public:
    tst_Database();
    ~tst_Database() override;

private slots:
    void databasePath();
    void connectToDatabase();
};

tst_Database::tst_Database() {}

tst_Database::~tst_Database() = default;

void tst_Database::databasePath()
{
    QVERIFY(Database::defaultDatabasePath().contains("qrop.db"));
}

void tst_Database::connectToDatabase()
{
    Database::connectToDatabase();
    QVERIFY(QSqlDatabase::database().isValid());
}

QTEST_APPLESS_MAIN(tst_Database)

#include "tst_database.moc"
