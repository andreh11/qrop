#pragma once

#include "core_global.h"

#include <QObject>
#include <QMap>

class CORESHARED_EXPORT FileSystem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString rootPath READ rootPath CONSTANT FINAL)
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    Q_PROPERTY(QString csvPath READ csvPath CONSTANT FINAL)
    Q_PROPERTY(QString pdfPath READ pdfPath CONSTANT FINAL)
#endif

public:
    explicit FileSystem(QObject *parent = nullptr);

    inline static QString rootPath() { return s_rootPath; }

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    inline static QString csvPath()
    {
        return QString("%1/%2").arg(s_rootPath).arg(s_subFolders.value("csv"));
    }
    inline static QString pdfPath()
    {
        return QString("%1/%2").arg(s_rootPath).arg(s_subFolders.value("pdf"));
    }

    Q_INVOKABLE static QStringList getAvailableDataBasesNames();
    Q_INVOKABLE static QStringList getAvailableCsvFileNames();

    static void createMobileRootFilesDirectories();
#endif

private:
    static QString s_rootPath;
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    static const QMap<QString, QString> s_subFolders;
    static bool createDocumentsFolder();
    static bool createQropFolder();
#endif
};

//#if defined(Q_OS_ANDROID) || defined (Q_OS_IOS)
//#endif
