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

// http://stockcharts.com/school/doku.php?id=chart_school:technical_indicators:relative_strength_index_rsi

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

    double avgGain;
    double avgLoss;
    int counter;
    int n;

    double prevValue;

  public:

    Rsi( int n ) :
    n( n )
    {
      avgGain = 0;
      avgLoss = 0;
      counter = 0;
      prevValue = NAN;
    }

    void Add( double value )
    {

      counter++;

      if( std::isnan( prevValue ) ) prevValue = value;
      double change = value - prevValue;
      prevValue = value;

      double currGain = change > 0 ?  change : 0;
      double currLoss = change < 0 ? -change : 0;

      if( counter > n ) {

        avgGain = ( avgGain * ( n - 1 ) + currGain ) / n;
        avgLoss = ( avgLoss * ( n - 1 ) + currLoss ) / n;

      } else {

        avgGain += currGain;
        avgLoss += currLoss;

        if( counter == n ) {

          avgGain = avgGain / n;
          avgLoss = avgLoss / n;

        }

      }
      //Rcpp::Rcout << " avgGain " << avgGain << " avgLoss " << avgLoss << " currGain " << currGain << " currLoss " << currLoss << std::endl;

      IsFormed() ? history.push_back( GetValue() ) : history.push_back( NA_REAL );


    }

    bool IsFormed() { return counter > n; }

    double GetValue() {

      double rsi = avgGain > 0 ? 100. - 100. / ( 1 + avgGain / avgLoss ) : 100.;
      return rsi;

    }

    std::vector<double> GetHistory() { return history; }

    void Reset() {

      avgGain = 0;
      avgLoss = 0;
      counter = 0;
      prevValue = NAN;

    }

};

#endif //RSI_H
