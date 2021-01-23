#ifndef QROPNEWS_H
#define QROPNEWS_H

#include <QObject>
#include <QString>
#include <QList>

class QropNews :  public QObject
{
    Q_OBJECT

    static constexpr const char *s_newsJsonBaseLink = "https://mbruel.fr/qrop_news"; //!< we might add "_lang" then the ".json"

    typedef struct News {
        const QString date;
        const QString title;
        const QString link;
        const QString desc;
        News(const QString &date_, const QString &title_, const QString &link_, const QString &desc_):
            date(date_), title(title_), link(link_), desc(desc_)
        {}
    } News;

private:
    QString m_lastUpdate;
    QString m_mainText;
    QString m_lastRelease;
    QString m_dateFormat;
    QList<News> m_news;

    QString m_netError;
    ushort m_numTryFetched;


private slots:
    void onNewsReceived();

public:
    QropNews(QObject *parent = nullptr);
    ~QropNews() = default;


    void fetchNews();

};

#endif // QROPNEWS_H
