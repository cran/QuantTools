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

#ifndef SMA_H
#define SMA_H

#include "Rcpp.h"
#include "Indicator.h"
#include <queue>
#include <stdexcept>

class Sma : public Indicator< double, double, std::vector<double> > {

  private:

    double sum;
    std::size_t n;
    std::queue< double > window;
    std::vector< double > history;

  public:

    Sma( int n ) :
    n( ( std::size_t )n )
    {
      if( n < 1 ) throw std::invalid_argument( "n must be greater than 0" );
      sum = 0;
    }

    void Add( double value )
    {

      sum += value;
      window.push( value );

      if( window.size() > n ) {

        sum -= window.front();
        window.pop();

      }

      IsFormed() ? history.push_back( GetValue() ) : history.push_back( NA_REAL );


    }

    bool IsFormed() { return window.size() == n; }

    double GetValue() { return sum / n; }

    std::vector<double> GetHistory() { return history; }

    void Reset() {
      sum = 0;
      std::queue< double > empty;
      std::swap( window, empty );

    }

};

#endif //SMA_H
