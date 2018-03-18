// Copyright (C) 2017 Stanislav Kovalevsky
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

#ifndef ALARM_H
#define ALARM_H

#include "NPeriods.h"

class Alarm {

private:

  double time;
  double prevTime;
  bool wasRingingToday;
  bool isSet;

public:

  Alarm() { isSet = false; }

  void Set( double time ) {

    if( 0 > time or time >= 24. ) throw std::invalid_argument( "alarm time must be in [0,24)" );
    this->time = time;
    wasRingingToday = false;
    isSet = true;
    prevTime = 0;

  }

  bool IsSet() { return isSet; }

  bool IsRinging( double time ) {

    if( not isSet ) return false;

    bool isShouldBeRinging = NHours( time ) >= this->time;
    bool isNewDateStarted = NNights( time, prevTime ) > 0;
    prevTime = time;

    if( isNewDateStarted ) wasRingingToday = false;

    if( not wasRingingToday and isShouldBeRinging ) {

      wasRingingToday = true;
      return true;

    }
    return false;

  }

  double GetTime() { return time; }

};

#endif //ALARM_H
