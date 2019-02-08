#ifndef PICTUREIMAGEPROVIDER_H
#define PICTUREIMAGEPROVIDER_H

#include <QObject>
#include <QQuickImageProvider>

class PictureImageProvider : public QQuickImageProvider
{
public:
    PictureImageProvider();
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize) override;
};

#endif // PICTUREIMAGEPROVIDER_H
