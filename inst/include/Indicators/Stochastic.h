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

#ifndef STOCHASTIC_H
#define STOCHASTIC_H

#include "Indicator.h"
#include "Sma.h"
#include "RollRange.h"
#include "../BackTest/Candle.h"
#include "../ListBuilder.h"
#include <queue>


class StochasticValue {

public:

  double kFast;
  double dFast;
  double dSlow;

};

template< typename Input >
class Stochastic : public Indicator< Input, StochasticValue, Rcpp::List > {

  private:

    RollRange high;
    RollRange low;
    Sma dFast;
    Sma dSlow;
    StochasticValue info;

    std::vector< double > kFastHistory;
    std::vector< double > dFastHistory;
    std::vector< double > dSlowHistory;

    void Update( Candle candle ) {

      high.Add( candle.high );
      low.Add( candle.low );

      if( high.IsFormed() and low.IsFormed() ) {

        info.kFast = ( candle.close - low.GetValue().min ) / ( high.GetValue().max - low.GetValue().min ) * 100;
        dFast.Add( info.kFast );
        if( dFast.IsFormed() ) dSlow.Add( dFast.GetValue() );
        info.dFast = dFast.GetValue();
        info.dSlow = dSlow.GetValue();

      }

    }

    void Update( double value ) {

      high.Add( value );
      low.Add( value );

      if( high.IsFormed() and low.IsFormed() ) {

        info.kFast = ( value - low.GetValue().min ) / ( high.GetValue().max - low.GetValue().min ) * 100;
        dFast.Add( info.kFast );
        if( dFast.IsFormed() ) dSlow.Add( dFast.GetValue() );
        info.dFast = dFast.GetValue();
        info.dSlow = dSlow.GetValue();

      }

    }

  public:

    Stochastic( int n, int nFast, int nSlow ) :
    high( ( size_t )n ),
    low( ( size_t )n ),
    dFast( ( size_t )nFast ),
    dSlow( ( size_t )nSlow )
    {}

    void Add( Input value )
    {

      info = {};

      Update( value );

      IsFormed() ? kFastHistory.push_back( info.kFast ) : kFastHistory.push_back( NA_REAL );
      IsFormed() ? dFastHistory.push_back( info.dFast ) : dFastHistory.push_back( NA_REAL );
      IsFormed() ? dSlowHistory.push_back( info.dSlow ) : dSlowHistory.push_back( NA_REAL );

    }

    bool IsFormed() { return dSlow.IsFormed(); }

    StochasticValue GetValue() { return info; }

    Rcpp::List GetHistory() {

      Rcpp::List history = ListBuilder().AsDataTable()
      .Add( "k_fast", kFastHistory )
      .Add( "d_fast", dFastHistory )
      .Add( "d_slow", dSlowHistory );
      return history;

    }

    std::vector< double > GetKFastHistory() { return kFastHistory; }
    std::vector< double > GetDFastHistory() { return dFastHistory; }
    std::vector< double > GetDSlowHistory() { return dSlowHistory; }

    void Reset() {

      dFast.Reset();
      dSlow.Reset();

    }


};

#endif //STOCHASTIC_H
