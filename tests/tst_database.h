#ifndef TSTAPP_H
#define TSTAPP_H

#include <QtTest>

class Database;

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

#endif // TSTAPP_H
