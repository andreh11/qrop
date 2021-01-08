#pragma once

#include "core_global.h"

#include <QObject>
#include <QMap>

class CORESHARED_EXPORT FileSystem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString rootPath READ rootPath)
    //#if defined(Q_OS_ANDROID) || defined (Q_OS_IOS)
    Q_PROPERTY(QString csvPath READ csvPath)
    Q_PROPERTY(QString pdfPath READ pdfPath)
    //#endif

public:
    explicit FileSystem(QObject *parent = nullptr);

    inline QString rootPath() const;

    //#if defined(Q_OS_ANDROID) || defined (Q_OS_IOS)
    inline QString csvPath() const;
    inline QString pdfPath() const;

    Q_INVOKABLE static QStringList getAvailableDataBasesNames();
    Q_INVOKABLE QStringList getAvailableCsvFileNames() const;

    static void createMobileRootFilesDirectories();
    //#endif

private:
    static QString s_rootPath;
    static QString s_qropPath;
    static const QMap<QString, QString> s_subFolders;
    static void createDocumentsFolder();
    static void createQropFolder();
};

QString FileSystem::rootPath() const
{
    return s_rootPath;
}

//#if defined(Q_OS_ANDROID) || defined (Q_OS_IOS)
QString FileSystem::csvPath() const
{
    return QString("%1/%2").arg(s_rootPath).arg(s_subFolders.value("csv"));
}
QString FileSystem::pdfPath() const
{
    return QString("%1/%2").arg(s_rootPath).arg(s_subFolders.value("pdf"));
}
//#endif
