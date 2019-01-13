#ifndef QROPDOUBLEVALIDATOR_H
#define QROPDOUBLEVALIDATOR_H

#include <QObject>
#include <QDoubleValidator>

// A subclass of QDoubleValidator which always use "." as a decimalPoint.
class QropDoubleValidator : public QDoubleValidator
{
    Q_OBJECT

public:
    QropDoubleValidator(QObject *parent = nullptr);
    QropDoubleValidator(double bottom, double top, int decimals, QObject *parent);
    QValidator::State validate(QString &input, int &pos) const override;
};

#endif // QROPDOUBLEVALIDATOR_H
