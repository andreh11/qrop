#ifndef QROPNEWS_H
#define QROPNEWS_H

#include <QObject>
#include <QString>
#include <QVector>
#include <QDate>
class QropNews :  public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString mainText READ mainText CONSTANT FINAL)
    Q_PROPERTY(QString toHtml READ toHtml CONSTANT FINAL)

    static constexpr const char *s_newsJsonBaseLink = "https://framagit.org/ah/qrop/-/raw/284-bdd-erreur-ouverture-logiciel/news/qrop_news"; //!< we might add "_lang" then the ".json"
    static constexpr const char *s_qropDownloadURL = "https://qrop.frama.io/fr/download/";

    typedef struct News {
        const QString date;
        const QString title;
        const QString link;
        const QString desc;
        const bool unread;
        News(const QString &date_, const QString &title_, const QString &link_, const QString &desc_, bool unread_):
            date(date_), title(title_), link(link_), desc(desc_), unread(unread_)
        {}
    } News;

private:
    QString m_lang;
    QDate m_lastUpdate;
    QString m_mainText;
    QString m_lastRelease;
    QVector<News*> m_news;
    ushort m_numberOfUnreadNews;
    bool m_markAsRead;

signals:
    void newsReceived();

private slots:
    void onNewsReceived();

public:
    QropNews(QObject *parent = nullptr);
    ~QropNews();

    inline QDate lastUpdate() const {return m_lastUpdate;}
    inline QString lastRelease() const {return m_lastRelease;}

    inline QString mainText() const {return m_mainText;}
    QString toHtml();

    Q_INVOKABLE void fetchNews();
    inline Q_INVOKABLE int numberOfUnreadNews() const {return m_numberOfUnreadNews;}

    inline Q_INVOKABLE void markAsRead(bool read) {m_markAsRead = read;}
    inline bool areRead() const {return m_markAsRead;}

private:
    void _error(const QString &err);
};

#endif // QROPNEWS_H
