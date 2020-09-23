#pragma once

#include "core_global.h"

#include <QObject>
#include <QQuickImageProvider>

class CORESHARED_EXPORT QrpImageProvider : public QQuickImageProvider
{
public:
    QrpImageProvider();
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override;
};
