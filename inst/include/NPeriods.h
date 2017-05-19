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

#ifndef NPERIODS_H
#define NPERIODS_H

constexpr const int nSecondsInDay = 60 * 60 * 24;
constexpr const int nSecondsInHour = 60 * 60;
constexpr const int nHoursInDay = 24;


inline int NNights( double time1, double time2 ) {

  return std::abs( (int)time1 / nSecondsInDay - (int)time2 / nSecondsInDay );

}

inline int NDays( double time1, double time2 ) { return NNights( time1, time2 ); }

inline double NHours( double time ) {

  double x =  time / nSecondsInHour;

  return x - (int)x / nHoursInDay * nHoursInDay;

  //return std::fmod( time / nSecondsInHour, nHoursInDay );

}

inline double NHours( double time1, double time2 ) {

  return std::abs( time1 - time2 ) / nSecondsInHour;

}

#endif //NPERIODS_H
