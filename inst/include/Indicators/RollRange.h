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

#ifndef ROLLRANGE_H
#define ROLLRANGE_H

#include "Indicator.h"
#include <math.h>
#include <queue>
#include <set>
#include "../ListBuilder.h"

class Range {

public:

  double min;
  double max;
  double quantile;

};

class RollRange : public Indicator< double, double, Rcpp::DataFrame > {

private:

  Range range;
  size_t n;
  double p;
  std::queue< double > window;
  std::multiset< double > windowSorted;

  std::vector< double > minHistory;
  std::vector< double > maxHistory;
  std::vector< double > quantileHistory;

public:

  RollRange( int n, double p = 1 ) :
  n( ( size_t )n ),
  p( p )
  {
    if( n < 1 ) throw std::invalid_argument( "n must be greater than 0" );
    if( p < 0 or p > 1 ) throw std::invalid_argument( "p must be in [0,1]" );
  }

  void Add( double value ) {

    window.push( value );
    windowSorted.insert( value );

    if( window.size() > n ) {

      windowSorted.erase( windowSorted.find( window.front() ) );
      window.pop();

    }
    range.min = *windowSorted.begin();
    range.max = *std::prev( windowSorted.end() );
    if( IsFormed() ) range.quantile = p >= 0.5 ?
    *std::next( windowSorted.rbegin() , static_cast< int >( std::trunc( ( 1. - p ) * n ) ) ) :
    *std::next( windowSorted.begin() , static_cast< int >( std::trunc( p * n ) ) );

    //Rcpp::Rcout << range.min << " " << range.max << " " << range.quantile << std::endl;

    IsFormed() ? minHistory.push_back( range.min ) : minHistory.push_back( NA_REAL );
    IsFormed() ? maxHistory.push_back( range.max ) : maxHistory.push_back( NA_REAL );
    IsFormed() ? quantileHistory.push_back( range.quantile ) : quantileHistory.push_back( NA_REAL );

  }

  bool IsFormed() { return window.size() == n; }

  Range GetValue() { return range; }

  std::vector< double > GetMinHistory() { return minHistory; }
  std::vector< double > GetMaxHistory() { return maxHistory; }
  std::vector< double > GetQuantileHistory() { return quantileHistory; }

  Rcpp::DataFrame GetHistory() {

    Rcpp::DataFrame history = ListBuilder()
    .Add( "min", minHistory )
    .Add( "max", maxHistory );
    return history;

  }

  void Reset() {

    std::queue< double > empty;
    std::swap( window, empty );
    windowSorted.clear();

  }

};

#endif //ROLLRANGE_H
