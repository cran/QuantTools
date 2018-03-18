// Copyright (C) 2016 Stanislav Kovalevsky
//
// This file is part of QuantTools.
//
// QuantTools is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 2 of the License, or
// (at your option) any later version.
//
// QuantTools is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with QuantTools. If not, see <http://www.gnu.org/licenses/>.

#ifndef UTILS_H
#define UTILS_H

#include <time.h>

// https://stackoverflow.com/questions/824118/why-is-floor-so-slow
inline int fastFloor(double x)
{
    return ( int ) x - ( x < ( int ) x );
}

inline int fastCeiling( double x )
{
    return ( int ) x + ( x > ( int ) x );
}

inline int floorDateToMonthStart( int x ) {

  int secondsInDay = 24 * 60 * 60;
  time_t t( x * secondsInDay );
  time_t tMonth = t - ( gmtime( &t )->tm_mday - 1 ) * secondsInDay;
  return tMonth / secondsInDay;

}


#endif //UTILS_H
