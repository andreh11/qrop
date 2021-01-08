#include "filesystem.h"
#include <QStandardPaths>
#include <QDebug>

//#if defined(Q_OS_ANDROID) || defined (Q_OS_IOS)
#define APP_NAME "Qrop"
#include <QDir>
#if defined(Q_OS_ANDROID)
#include <QtAndroidExtras/QtAndroid>
#endif

QString FileSystem::s_rootPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
QString FileSystem::s_qropPath = QString("%1/%2").arg(s_rootPath, APP_NAME);
const QMap<QString, QString> FileSystem::s_subFolders { { "csv", "csv" }, { "pdf", "pdf" } };

FileSystem::FileSystem(QObject *parent)
    : QObject(parent)
{
}

void FileSystem::createDocumentsFolder()
{
    if (QDir(s_rootPath).exists())
        return;

    qDebug() << "Creating Documents folder: " << s_rootPath;

    QFileInfo fi(s_rootPath);
    QDir dir(fi.absolutePath());

    if (!dir.mkdir(fi.fileName())) {
        qCritical() << "Couldn't create Documents folder...";
        return;
    }
}

void FileSystem::createQropFolder()
{
    QFileInfo fi(s_qropPath);
    if (!fi.exists()) {
        QDir dir(s_rootPath);
        if (!dir.mkdir(APP_NAME))
            qCritical() << "Couldn't create folder: " << fi.absoluteFilePath();
    }
}

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

    createDocumentsFolder();
    createQropFolder();

    // 3.: create all subFolders
    QFileInfo fi(s_qropPath);
    if (fi.exists()) {
        QDir dir(s_qropPath);
        for (const auto &folder : s_subFolders.values())
            dir.mkdir(folder);
    }
}

QStringList FileSystem::getAvailableDataBasesNames()
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
