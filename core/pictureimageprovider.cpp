#include <QSqlQuery>
#include <QDebug>
#include <QByteArray>

#include "pictureimageprovider.h"

PictureImageProvider::PictureImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Pixmap)
{
}

QPixmap PictureImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(size)
    Q_UNUSED(requestedSize)

    QStringList lst = id.split("/");
    if (lst.empty())
        return {};

    int photoId = lst[0].toInt();
    QSqlQuery query;
    query.prepare("SELECT data FROM file WHERE file_id = :file_id");
    query.bindValue(":file_id", photoId);
    query.exec();
    if (!query.first())
        return {};

    QByteArray byteArray = query.value("data").toByteArray();
    QPixmap pixmap;
    pixmap.loadFromData(byteArray);
    return pixmap;
}
