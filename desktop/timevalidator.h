#ifndef TIMEVALIDATOR_H
#define TIMEVALIDATOR_H

#include <QObject>
#include <QValidator>

class TimeValidator : public QValidator
{
    Q_OBJECT

public:
    TimeValidator(QObject *parent = nullptr);
    void fixup(QString &input) const override;
    QValidator::State validate(QString &input, int &pos) const override;
};

#endif // TIMEVALIDATOR_H
