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

#ifndef ROLLPERCENTRANK_H
#define ROLLPERCENTRANK_H

#include <math.h>
#include <vector>
#include <queue>
#include <set>
#include "Indicator.h"
#include "Rcpp.h"

class RollPercentRank : public Indicator< double, double, std::vector< double > > {

private:

  size_t n;
  std::queue<double> window;
  std::multiset<double> windowSorted;
  double percentRank;

  std::vector< double > history;

public:

  RollPercentRank( int n ) :
  n( ( size_t )n )
  {
    if( n < 1 ) throw std::invalid_argument( "n must be greater than 0" );
  }

  void Add( double value ) {

    window.push( value );
    windowSorted.insert( value );

    if( window.size() > n ) {

      windowSorted.erase( windowSorted.find( window.front() ) );
      window.pop();

    }
    auto it = std::lower_bound( windowSorted.begin(), windowSorted.end(), value );
    int distance = std::distance( windowSorted.begin(), it );
    percentRank = distance * 1. / n;
    // bug max value not equal 1;

    IsFormed() ? history.push_back( GetValue() ) : history.push_back( NA_REAL );

  }

  bool IsFormed() { return window.size() == n; }

  double GetValue() { return percentRank; }

  std::vector< double > GetHistory() { return history; }

  void Reset() {

    std::queue< double > empty;
    std::swap( window, empty );
    windowSorted.clear();

  }

};

#endif //ROLLPERCENTRANK_H
