/*
 * Copyright (C) 2021 André Hoarau <ah@ouvaton.org>
 *                  & Matthieu Bruel <Matthieu.Bruel@gmail.com>
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

#ifndef SINGLETON_H
#define SINGLETON_H

template <typename T> class Singleton
{
protected:
    // Constructor /Destructor
    Singleton() = default;
    virtual ~Singleton() = default;

public:
    Singleton(const Singleton &other) = delete;
    Singleton(const Singleton &&other) = delete;
    Singleton & operator=(const Singleton &other) = delete;
    Singleton & operator=(const Singleton &&other) = delete;

    // Public Interface
    static T *instance()
    {
        if (!_singleton)
            _singleton = new T;
        return (static_cast<T*> (_singleton));
    }

    static void clear()
    {
        if (_singleton) {
            delete _singleton;
            _singleton = nullptr;
        }
    }

private:
    // Unique instance
    static T *_singleton;
};

template <typename T> T *Singleton<T>::_singleton;
#endif // SINGLETON_H
