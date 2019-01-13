#include "qropdoublevalidator.h"

QropDoubleValidator::QropDoubleValidator(QObject *parent)
    : QDoubleValidator(parent)
{
}

QropDoubleValidator::QropDoubleValidator(double bottom, double top, int decimals, QObject *parent)
    : QDoubleValidator(bottom, top, decimals, parent)
{
}

QValidator::State QropDoubleValidator::validate(QString &input, int &pos) const
{
    const QString decimalPoint = locale().decimalPoint();
    input.replace(".", decimalPoint);
    return QDoubleValidator::validate(input, pos);
}
