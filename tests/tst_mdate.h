#ifndef TST_MDATE_H
#define TST_MDATE_H

#include <QtTest>

class tst_MDate : public QObject
{
    Q_OBJECT

public:
    tst_MDate();
    ~tst_MDate();

private slots:
    void dateFromWeekString();
    void dateFromDateString();
    void firstMondayOfYear_data();
    void firstMondayOfYear();
    //    void weekDates_data();
    //    void weekDates();
    void formatDate();
    void season();
    void seasonYear();
};

#endif // TST_MDATE_H
