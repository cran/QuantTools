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

#ifndef RSI_H
#define RSI_H

#include "Indicator.h"
#include "Sma.h"
#include <queue>

class Rsi : public Indicator< double, double, std::vector<double> > {

  private:

    //Sma avgGain;
    //Sma avgLoss;
    std::vector< double > history;

    double sumGain;
    double sumLoss;
    int counter;
    int n;

    double prevValue;

  public:

    Rsi( int n ) :
    n( n )
    {
      sumGain = 0;
      sumLoss = 0;
      counter = 0;
      prevValue = NAN;
    }

    void Add( double value )
    {

      counter++;

      if( std::isnan( prevValue ) ) prevValue = value;
      double change = value - prevValue;

      if( counter > n ) {

        change > 0 ? sumGain = sumGain * ( n - 1 ) / n + change : sumLoss = sumLoss * ( n - 1 ) / n - change;

      } else {

        change > 0 ? sumGain += change : sumLoss += -change;

      }

      IsFormed() ? history.push_back( GetValue() ) : history.push_back( NA_REAL );


    }

    bool IsFormed() { return counter > n; }

    double GetValue() {

      double rsi = sumGain > 0 ? 100. - 100. / ( 1 + sumGain / sumLoss ) : 100.;
      return rsi;

    }

    std::vector<double> GetHistory() { return history; }

    void Reset() {

      sumGain = 0;
      sumLoss = 0;
      counter = 0;

    }

};

#endif //RSI_H
