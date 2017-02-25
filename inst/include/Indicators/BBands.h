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

#ifndef BBANDS_H
#define BBANDS_H

#include "Indicator.h"
#include "Sma.h"
#include "RollSd.h"
#include "../ListBuilder.h"

class BBandsValue {
public:

  double upper;
  double lower;
  double sma;

};

class BBands : public Indicator< double, BBandsValue, Rcpp::List > {

private:

  Sma sma;
  RollSd sd;
  BBandsValue bbands;
  double k;

  std::vector< double > lowerHistory;
  std::vector< double > upperHistory;
  std::vector< double > smaHistory;

public:

  BBands( int n, double k ) :
  sma( ( size_t )n ),
  sd ( ( size_t )n ),
  k( k )
  {}

  void Add( double value ) {

    sma.Add( value );
    sd .Add( value );

    bbands.lower = sma.GetValue() - sd.GetValue() * k;
    bbands.upper = sma.GetValue() + sd.GetValue() * k;
    bbands.sma = sma.GetValue();

    IsFormed() ? lowerHistory.push_back( bbands.lower ) : lowerHistory.push_back( NA_REAL );
    IsFormed() ? upperHistory.push_back( bbands.upper ) : upperHistory.push_back( NA_REAL );
    IsFormed() ? smaHistory       .push_back( bbands.sma   ) : smaHistory       .push_back( NA_REAL );

  }

  bool IsFormed() { return sma.IsFormed() and sd.IsFormed(); }

  BBandsValue GetValue() { return bbands; }

  std::vector< double > GetUpperHistory() { return upperHistory; }
  std::vector< double > GetLowerHistory() { return lowerHistory; }
  std::vector< double > GetSmaHistory() { return smaHistory; }

  Rcpp::List GetHistory() {

    Rcpp::List history = ListBuilder().AsDataTable()
    .Add( "lower", lowerHistory )
    .Add( "upper", upperHistory )
    .Add( "sma"  , smaHistory   );
    return history;

  }

  void Reset() {

    sma.Reset();
    sd .Reset();
    bbands = {};

  }

};

#endif //BBANDS_H
