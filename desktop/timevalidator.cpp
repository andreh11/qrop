#include <QDebug>
#include <QTime>

#include "timevalidator.h"

TimeValidator::TimeValidator(QObject *parent)
    : QValidator(parent)
{
}

void TimeValidator::fixup(QString &input) const
{
    auto stringList = input.split(":");
    QString h = stringList.at(0);
    QString m = stringList.at(1);

    if (h.at(0) == " ")
        h.replace(0, 1, "0");
    if (h.at(1) == " ") {
        h.replace(1, 1, h.at(0));
        h.replace(0, 1, "0");
    }

    if (m.at(0) == " ")
        m.replace(0, 1, "0");
    if (m.at(1) == " ") {
        m.replace(1, 1, m.at(0));
        m.replace(0, 1, "0");
    }

    input = QString("%1:%2").arg(h, m);
}

QValidator::State TimeValidator::validate(QString &input, int &pos) const
{
    Q_UNUSED(pos)

    if (input.contains(" "))
        return Intermediate;

    auto sp = input.split(":");
    int m = sp.at(1).toInt();
    if (m < 60)
        return Acceptable;
    return Invalid;
}
