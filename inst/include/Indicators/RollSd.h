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

#ifndef ROLLSD_H
#define ROLLSD_H

#include <queue>
#include <vector>
#include <stdexcept>
#include <cmath>
#include "Rcpp.h"
#include "Indicator.h"

class RollSd : public Indicator< double, double, std::vector<double> > {

private:

  double sumX;
  double sumXX;

  double sd;

  std::size_t n;

  std::queue< double > window;

  std::vector< double > history;

public:

  RollSd( int n ) :
  n( ( std::size_t )n )
  {
    if( n < 2 ) throw std::invalid_argument( "n must be greater than 1" );
    sumX = 0;
    sumXX = 0;
  }

  void Add( double value ) {

    sumX += value;
    sumXX += value * value;
    window.push( value );

    if( window.size() > n ) {

      double old = window.front();

      window.pop();

      sumX -= old;
      sumXX -= old * old;

    }
    sd = sqrt( sumXX / n - ( sumX / n ) * ( sumX / n ) ) * std::sqrt( n * 1. / ( n - 1 ) );

    IsFormed() ? history.push_back( GetValue() ) : history.push_back( NA_REAL );

  }

  bool IsFormed() { return window.size() == n; }

  double GetValue() { return sd; }

  std::vector<double> GetHistory() { return history; }

  void Reset() {

    std::queue<double> empty;
    std::swap( window, empty );
    sumX = 0;
    sumXX = 0;

  }

};

#endif //ROLLSD_H
