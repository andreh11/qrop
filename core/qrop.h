#ifndef QROP_H
#define QROP_H

#include <QObject>
#include <QSettings>
#include "singleton.h"

class Database;

class Qrop : public QObject, public Singleton<Qrop>
{
    Q_OBJECT
    friend class Singleton<Qrop>;

private:
    QSettings m_settings;
    Database *const m_db;
    QStringList m_errors;

signals:
    void info(const QString &msg);
    void error(const QString &err);

private:
    Qrop(QObject *parent = nullptr);

public:
    ~Qrop();

    int init();

    Q_INVOKABLE bool loadDatabase(const QUrl &url);

    inline bool hasErrors() const {return m_errors.size() != 0;}
    inline void showErrors() {
        emit error(m_errors.join("\n"));
        m_errors.clear();
    };

private:
    void loadCurrentDatabase();

};

#endif // QROP_H
