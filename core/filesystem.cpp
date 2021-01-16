#include "filesystem.h"
#include <QStandardPaths>
#include <QDebug>

// QString FileSystem::s_rootPath = "/home/bruel/Documents/Qrop";
QString FileSystem::s_rootPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
//#if defined(Q_OS_ANDROID) || defined (Q_OS_IOS)
const QMap<QString, QString> FileSystem::s_subFolders = { { "csv", "csv" }, { "pdf", "pdf" } };
//#endif

FileSystem::FileSystem(QObject *parent)
    : QObject(parent)
{
}

//#if defined(Q_OS_ANDROID) || defined (Q_OS_IOS)
#define APP_NAME "Qrop"
#include <QDir>
#if defined(Q_OS_ANDROID)
#include <QtAndroidExtras/QtAndroid>
#endif
void FileSystem::createMobileRootFilesDirectories()
{
    s_rootPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
#if defined(Q_OS_ANDROID)
    QtAndroid::PermissionResultMap res =
            QtAndroid::requestPermissionsSync({ "android.permission.WRITE_EXTERNAL_STORAGE" });
    if (res["android.permission.WRITE_EXTERNAL_STORAGE"] != QtAndroid::PermissionResult::Granted) {
        qCritical() << "don't have WRITE_EXTERNAL_STORAGE permission...";
        return;
    }
#endif

    // 1. Check if main Documents folder exist
    if (!QDir(s_rootPath).exists()) {
        qDebug() << "Creating Documents folder: " << s_rootPath;
        QFileInfo fi(s_rootPath);
        QDir dir(fi.absolutePath());
        if (!dir.mkdir(fi.fileName())) {
            qCritical() << "Couldn't create Documents folder...";
            return;
        }
    }

    // 2.: Create Qrop subFolder
    QFileInfo fi(QString("%1/%2").arg(s_rootPath).arg(APP_NAME));
    if (!fi.exists()) {
        QDir dir(s_rootPath);
        if (!dir.mkdir(APP_NAME))
            qCritical() << "Couldn't create folder: " << fi.absoluteFilePath();
    }

    // 3.: create all subFolders
    if (fi.exists()) {
        s_rootPath = fi.absoluteFilePath();
        QDir dir(s_rootPath);
        for (const auto &folder : s_subFolders.values()) {
            if (!QFileInfo(QString("%1/%2").arg(s_rootPath).arg(folder)).exists())
                dir.mkdir(folder);
        }
    }
}

QStringList FileSystem::getAvailableDataBasesNames() const
{
    QStringList dbNames;
    QDir dir(s_rootPath);
    for (const QFileInfo &fi :
         dir.entryInfoList(QStringList("*.sqlite"), QDir::Filter::Files, QDir::SortFlag::Name))
        dbNames << fi.completeBaseName();
    return dbNames;
}

QStringList FileSystem::getAvailableCsvFileNames() const
{
    QStringList csvNames;
    QDir dir(csvPath());
    for (const QFileInfo &fi :
         dir.entryInfoList(QStringList("*.csv"), QDir::Filter::Files, QDir::SortFlag::Name))
        csvNames << fi.completeBaseName();
    return csvNames;
}
//#endif // #if defined(Q_OS_ANDROID) || defined (Q_OS_IOS)
