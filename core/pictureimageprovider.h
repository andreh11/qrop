#ifndef PICTUREIMAGEPROVIDER_H
#define PICTUREIMAGEPROVIDER_H

#include <QObject>
#include <QQuickImageProvider>

#include "core_global.h"

class CORESHARED_EXPORT PictureImageProvider : public QQuickImageProvider
{
public:
    PictureImageProvider();
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override;
};

#endif // PICTUREIMAGEPROVIDER_H
