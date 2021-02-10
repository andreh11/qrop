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

#ifndef PURESTATICCLASS_H
#define PURESTATICCLASS_H

class PureStaticClass {
public:
  PureStaticClass() = delete;
  PureStaticClass(const PureStaticClass &other) = delete;
  PureStaticClass(const PureStaticClass &&other) = delete;

  PureStaticClass &operator=(const PureStaticClass &other) = delete;
  PureStaticClass &operator=(const PureStaticClass &&other) = delete;
};

#endif // PURESTATICCLASS_H
