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

#ifndef EMA_H
#define EMA_H

#include "Rcpp.h"
#include "Indicator.h"
#include <vector>
#include <stdexcept>

class Ema : public Indicator< double, double, std::vector< double > > {

  private:

    double k;
    size_t n;
    double ema;
    size_t counter;
    std::vector< double > history;

  public:

    Ema( int n ) :
    n( ( size_t )n )
    {

      if( n < 1 ) throw std::invalid_argument( "n must be greater than 0" );

      k = 2. / ( n + 1 );
      counter = 0;
      ema = 0;

    }

    void Add( double value ) {

      if( counter < n ) counter++;
      if( counter == 1 ) ema = value; else ema = value * k + ema * ( 1 - k );
      IsFormed() ? history.push_back( GetValue() ) : history.push_back( NA_REAL );

    }

    bool IsFormed() { return counter == n; }

    double GetValue() { return ema; }

    std::vector<double> GetHistory() { return history; }

    void Reset() {

      counter = 0;
      ema = 0;

    }

};

#endif //EMA_H
