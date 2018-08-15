#include "plantingdao.h"

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QVariant>
#include <QString>

#include "planting.h"
#include "location.h"
#include "databasemanager.h"

using namespace std;

PlantingDao::PlantingDao(QSqlDatabase& database) :
    mDatabase(database)
{
}

void PlantingDao::init() const
{
    if (!mDatabase.tables().contains("plantings")) {
        QSqlQuery query(mDatabase);
        query.exec(QString("CREATE TABLE IF NOT EXISTS planting ()") +
                   "planting_id    INTEGER   PRIMARY KEY AUTOINCREMENT" +
                   "crop           TEXT  NOT NULL" +
                   "variety        TEXT" +
                   "family         TEXT" +
                   "unit           TEXT" +
                   "code           TEXT" +
                   "planting_type    INTEGER" +
                   "comments       TEXT" +
                   "keywords       TEXT" +
                   "seeding_date       TEXT" +
                   "planting_date TEXT" +
                   "beg_harvest_date TEXT" +
                   "end_harvest_date TEXT" +
                   "nursery_period   INTEGER" +
                   "growing_period   INTEGER" +
                   "harvest_period   INTEGER" +
                   "spacing_rows     INTEGER -- cm" +
                   "spacing_plants   INTEGER -- cm" +
                   "surface          INTEGER -- sqm" +
                   "length           INTEGER -- m" +
                   "plants_needed    INTEGER" +
                   "fudge_factor INTEGER" +
                   "plants_to_start  INTEGER" +
                   "tray_size        INTEGER" +
                   "trays_to_start   FLOAT" +
                   "total_yield      INTEGER" +
                   "yield_per_bed_m  INTEGER" +
                   "yield_per_m2     INTEGER" +
                   "seeds_per_g      INTEGER" +
                   "seeds_per_hole   INTEGER" +
                   "seeds_number     INTEGER" +
                   "seeds_quantity   FLOAT;");
    }
}

void PlantingDao::addPlanting(Planting& planting) const
{
    QSqlQuery query(mDatabase);
    query.prepare("INSERT INTO plantings (crop) VALUES (:crop)");
    query.bindValue(":crop", planting.crop());
    query.exec();
    planting.setId(query.lastInsertId().toInt());
    DatabaseManager::debugQuery(query);
}

void PlantingDao::addLocation(Planting& planting, Location& location) const
{
    QSqlQuery query(mDatabase);
    query.prepare("INSERT INTO planting_location VALUES (:planting_id, :location_id");
    query.bindValue(":planting_id", planting.id());
    query.bindValue(":location_id", location.id());
    query.exec();
    DatabaseManager::debugQuery(query);
}

void PlantingDao::removeLocation(Planting& planting, Location& location) const
{
    QSqlQuery query(mDatabase);
    query.prepare("DELETE FROM planting_location WHERE planting_id = :planting_id AND location_id = :location_id");
    query.bindValue(":planting_id", planting.id());
    query.bindValue(":location_id", location.id());
    query.exec();
    DatabaseManager::debugQuery(query);
}

std::unique_ptr<std::vector<std::unique_ptr<Location>>> PlantingDao::locations(Planting& planting) const
{
    QSqlQuery query(mDatabase);
    query.prepare("SELECT * FROM planting_location WHERE planting_id = :planting_id");
    query.bindValue(":planting_id", planting.id());
    query.exec();
    DatabaseManager::debugQuery(query);

    unique_ptr<vector<unique_ptr<Location>>> list(new vector<unique_ptr<Location>>());
    while(query.next()) {
        unique_ptr<Location> location(new Location());
        location->setId(query.value("location_id").toInt());
        location->setName(query.value("name").toString());
        location->setLength(query.value("lenght").toInt());
        location->setWidth(query.value("width").toInt());
        location->setParentId(query.value("parent_id").toInt());
        list->push_back(move(location));
    }
    return list;
}
