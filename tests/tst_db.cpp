#include <QtTest>
#include <QCoreApplication>
#include <QSqlDatabase>

#include "db.h"

class tst_Database : public QObject
{
    Q_OBJECT

public:
    tst_Database();
    ~tst_Database();

private slots:
    void tst_databasePath();
    void tst_connectToDatabase();
};

tst_Database::tst_Database() {}

tst_Database::~tst_Database() {}

void tst_Database::tst_databasePath()
{
    Database db;
    QVERIFY(db.databasePath().contains("qrop.db"));
}

void tst_Database::tst_connectToDatabase()
{
    Database db;
    db.connectToDatabase();
    QVERIFY(QSqlDatabase::database().isValid());
}

QTEST_MAIN(tst_Database)

#include "tst_db.moc"
