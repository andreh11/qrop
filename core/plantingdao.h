#ifndef PLANTINGDAO_H
#define PLANTINGDAO_H

#include <memory>
#include <vector>

#include "core_global.h"

class QSqlDatabase;
class Planting;
class Location;
class Task;
class Harvest;

class PlantingDao
{
public:
    PlantingDao(QSqlDatabase& database);
    void init() const;

    void addPlanting(Planting& planting) const;
//    void duplicatePlanting(const Planting& planting) const;
    void updatePlanting(const Planting& planting) const;
    void removePlanting(int id) const;
    std::unique_ptr<std::vector<std::unique_ptr<Planting>>> plantings() const;

    void addLocation(Planting& planting, Location& location) const;
    void removeLocation(Planting& planting, Location& location) const;
    std::unique_ptr<std::vector<std::unique_ptr<Location>>> locations(Planting& planting) const;

    void addTask(Planting& planting, Task& task) const;
    void removeTask(Planting& planting, Task& task) const;
    std::unique_ptr<std::vector<std::unique_ptr<Task>>> tasks() const;

    void addHarvest(Planting& planting, Harvest& harvest) const;
    void removeHarvest(Planting& planting, Harvest& harvest) const;
    std::unique_ptr<std::vector<std::unique_ptr<Harvest>>> harvests() const;

private:
    QSqlDatabase& mDatabase;
};

#endif // PLANTINGDAO_H
