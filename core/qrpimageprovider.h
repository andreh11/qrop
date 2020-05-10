#ifndef PICTUREIMAGEPROVIDER_H
#define PICTUREIMAGEPROVIDER_H

#include <QObject>
#include <QQuickImageProvider>

#include "core_global.h"

class CORESHARED_EXPORT QrpImageProvider : public QQuickImageProvider
{
public:
    QrpImageProvider();
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override;
};

#endif // PICTUREIMAGEPROVIDER_H
