#ifndef LOCATIONTREEVIEWMODEL_H
#define LOCATIONTREEVIEWMODEL_H

#include <QObject>

#include "core_global.h"
#include "treeviewmodel.h"

class LocationModel;

class CORESHARED_EXPORT LocationTreeViewModel : public TreeViewModel
{
    Q_OBJECT

    Q_PROPERTY(bool showOnlyGreenhouseLocations READ showOnlyGreenhouseLocations WRITE
                       setShowOnlyGreenhouseLocations NOTIFY showOnlyGreenhouseLocationsChanged)
    Q_PROPERTY(int depth READ depth NOTIFY depthChanged)
    Q_PROPERTY(int rowCount READ rowCount() NOTIFY countChanged)

public:
    explicit LocationTreeViewModel(QObject *parent = nullptr);

    bool showOnlyGreenhouseLocations() const;
    void setShowOnlyGreenhouseLocations(bool show);
    int depth() const;

private:
    LocationModel *m_locationModel;

signals:
    void showOnlyGreenhouseLocationsChanged();
    void depthChanged();
    void countChanged();
};

#endif // LOCATIONTREEVIEWMODEL_H
