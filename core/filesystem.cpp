#include "filesystem.h"
#include <QStandardPaths>
#include <QDebug>
FileSystem::FileSystem(QObject *parent)
    : QObject(parent),
//      m_rootPath("/home/bruel/Documents/Qrop"),
      m_rootPath(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation)),
      m_subFolders({ {"csv", "csv"}, {"pdf", "pdf"} })
{
#if defined(Q_OS_ANDROID) || defined (Q_OS_IOS)
    createMobileRootFilesDirectories();
#endif
}


//#if defined(Q_OS_ANDROID) || defined (Q_OS_IOS)
#define APP_NAME "Qrop"
#include <QDir>
#if defined(Q_OS_ANDROID)
#include <QtAndroidExtras/QtAndroid>
#endif
void FileSystem::createMobileRootFilesDirectories()
{
//    qDebug() << "[MB_TRACE] standard writable app data loc: " << QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
//    qDebug() << "[MB_TRACE] standard writable app conf loc: " << QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
//    qDebug() << "[MB_TRACE] standard writable data loc: "     << QStandardPaths::writableLocation(QStandardPaths::DataLocation);
//    qDebug() << "[MB_TRACE] standard writable apps loc: "     << QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation);
//    qDebug() << "[MB_TRACE] standard writable doc loc: "      << QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
//    qDebug() << "[MB_TRACE] standard writable down loc: "     << QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);

    m_rootPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
#if defined(Q_OS_ANDROID)
    QtAndroid::PermissionResultMap res = QtAndroid::requestPermissionsSync({"android.permission.WRITE_EXTERNAL_STORAGE"});
    if (res["android.permission.WRITE_EXTERNAL_STORAGE"] != QtAndroid::PermissionResult::Granted) {
        qCritical() << "don't have WRITE_EXTERNAL_STORAGE permission...";
        return;
    }
#endif

    // 1. Check if main Documents folder exist
    if (!QDir(m_rootPath).exists()) {
        qDebug() << "Creating Documents folder: " << m_rootPath;
        QFileInfo fi(m_rootPath);
        QDir dir(fi.absolutePath());
        if (!dir.mkdir(fi.fileName())){
            qCritical() << "Couldn't create Documents folder...";
            return;
        }
    }

    // 2.: Create Qrop subFolder
    QFileInfo fi(QString("%1/%2").arg(m_rootPath).arg(APP_NAME));
    if (!fi.exists()) {
        QDir dir(m_rootPath);
        if (!dir.mkdir(APP_NAME))
            qCritical() << "Couldn't create folder: " << fi.absoluteFilePath();
    }

    // 3.: create all subFolders
    if (fi.exists())
    {
        m_rootPath = fi.absoluteFilePath();
        QDir dir(m_rootPath);
        for (const auto & folder : m_subFolders.values()) {
            if (!QFileInfo(QString("%1/%2").arg(m_rootPath).arg(folder)).exists())
                dir.mkdir(folder);
        }
    }
}

QStringList FileSystem::getAvailableDataBasesNames() const
{
    QStringList dbNames;
    QDir dir(m_rootPath);
    for(const QFileInfo &fi: dir.entryInfoList(QStringList("*.sqlite"),
                                               QDir::Filter::Files,
                                               QDir::SortFlag::Name))
        dbNames << fi.completeBaseName();
    return dbNames;
}

QStringList FileSystem::getAvailableCsvFileNames() const
{
    QStringList csvNames;
    QDir dir(csvPath());
    for(const QFileInfo &fi: dir.entryInfoList(QStringList("*.csv"),
                                               QDir::Filter::Files,
                                               QDir::SortFlag::Name))
        csvNames << fi.completeBaseName();
    return csvNames;
}
//#endif // #if defined(Q_OS_ANDROID) || defined (Q_OS_IOS)
