/*
 * Copyright (C) 2018 André Hoarau <ah@ouvaton.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "planting.h"

class Task;

Planting::Planting(const QString& crop) :
    mId(-1),
    mCrop(crop),
    mVariety(""),
    mFamily(""),
    mUnit("")
{

}

int Planting::id() const
{
    return mId;
}

void Planting::setId(int id)
{
    mId = id;
}

QString Planting::crop() const
{
    return mCrop;
}

void Planting::setCrop(const QString& crop)
{
    mCrop = crop;
}

QString Planting::variety() const
{
    return mVariety;
}

void Planting::setVariety(const QString& variety)
{
    mVariety = variety;
}

QString Planting::unit() const
{
    return mUnit;
}

void Planting::setUnit(const QString& unit)
{
    mUnit = unit;
}

//QList<Task>* Planting::generateTasks() const {
//    QList<Task>* tasks = new QList<Task>;
//    if (mPlantingType == PlantingType::DS) {
//        Task* task = new Task();
//        task->setType(TaskType::DS);
//        tasks->pull_back(task);
//    } else if (mPlantingType == PlantingType::TPBOUGHT) {
//        Task* task = new Task();
//        task->setType(TaskType::PLANT);
//        tasks->pull_back(task);
//    } else if (mPlantingType == PlantingType::TPRAISED) {
//        Task* seedingTask = new Task();
//        seedingTask->setType(TaskType::GHSEED);
//        tasks->pull_back(seedingTask);

//        Task* plantingTask = new Task();
//        plantingTask->setType(TaskType::TRANSPLANT);
//        tasks->pull_back(plantingTask);
//    }

//    return tasks;
//}
