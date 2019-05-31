#include <QDebug>
#include <QTime>

#include "timevalidator.h"

TimeValidator::TimeValidator(QObject *parent)
    : QValidator(parent)
{
}

// void TimeValidator::fixup(QString &input) const
//{
//    int length = input.length();
//    if (length == 0)
//        input = "00:00";
//    else if (length == 1)
//        input = QString("00:0%1").arg(input);
//    else if (length == 2)
//        input = QString("00:%1").arg(input);
//    else if (length == 3)
//        input = QString("0%1:%2%3").arg(input.at(0)).arg(input.at(1)).arg(input.at(2));
//    else if (length == 4)
//        input = QString("%1%2:%3%4").arg(input.at(0)).arg(input.at(1)).arg(input.at(2)).arg(input.at(3));
//}

QValidator::State TimeValidator::validate(QString &input, int &pos) const
{
    //    int length = input.length();
    auto sp = input.split(":");

    //    int h = input.at(0).toInt();
    int m = sp.at(1).toInt();
    if (m < 60)
        return Acceptable;
    return Invalid;

    //    if (length == 0)
    //        return Acceptable;
    //    else if (length == 1)
    //        m = input.toInt();
    //    else if (length == 2)
    //        m = input.toInt();
    //    else if (length == 3)
    //        s = QString("0%1:%2%3").arg(input.at(0)).arg(input.at(1)).arg(input.at(2));
    //    else if (length == 4)
    //        s = QString("%1%2:%3%4").arg(input.at(0)).arg(input.at(1)).arg(input.at(2)).arg(input.at(3));
    //    else
    //        return Invalid;

    //    auto sp = s.split(":");
    //    qDebug() << "INPUT" << input << "LENGTH" << length << "S" << s << "SP" << sp;
    //    QTime time(sp.first().toInt(), sp[1].toInt());

    //    input = s;

    //    return time.isValid() ? Acceptable : Invalid;
}
