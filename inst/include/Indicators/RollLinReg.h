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

#ifndef ROLLLINREG_H
#define ROLLLINREG_H

#include <queue>
#include "Indicator.h"
#include "../ListBuilder.h"

class LinRegCoeffs {

public:

  double alpha;
  double beta;
  double r;
  double rSquared;

};

class RollLinReg : public Indicator< std::pair< double, double >, double, Rcpp::DataFrame > {

private:

  double sumX;
  double sumXX;
  double sumY;
  double sumYY;
  double sumXY;

  LinRegCoeffs coeffs;

  size_t n;

  typedef std::pair< double, double > pair;

  std::queue< pair > window;

  std::vector< double > alphaHistory;
  std::vector< double > betaHistory;
  std::vector< double > rHistory;
  std::vector< double > rSquaredHistory;

public:

  RollLinReg( int n ) :
  n( ( size_t )n )
  {
    if( n < 1 ) throw std::invalid_argument( "n must be greater than 0" );

    sumX  = 0;
    sumXX = 0;
    sumY  = 0;
    sumYY = 0;
    sumXY = 0;
    coeffs = {};

  }

  void Add( std::pair< double, double > pair ) {

    window.push( pair );

    sumX  += pair.first;
    sumXX += pair.first * pair.first;
    sumY  += pair.second;
    sumYY += pair.second * pair.second;
    sumXY += pair.first * pair.second;

    if( window.size() > n ) {

      double oldX = window.front().first;
      double oldY = window.front().second;

      window.pop();

      sumX  -= oldX;
      sumXX -= oldX * oldX;
      sumY  -= oldY;
      sumYY -= oldY * oldY;
      sumXY -= oldX * oldY;

    }

    if( window.size() == n ) {

      double covXY = n * sumXY - sumX * sumY; // * 1.0 / ( n * ( n - 1 ) )
      double varX  = n * sumXX - sumX * sumX; // * 1.0 / ( n * ( n - 1 ) )
      double varY  = n * sumYY - sumY * sumY; // * 1.0 / ( n * ( n - 1 ) )

      coeffs.beta     = covXY / varY;
      coeffs.alpha    = ( sumX - coeffs.beta  * sumY ) / n;
      coeffs.r        = covXY / std::sqrt( varX * varY );
      coeffs.rSquared = coeffs.r * coeffs.r;

    }

    if( IsFormed() ) {

      alphaHistory.push_back( coeffs.alpha );
      betaHistory.push_back( coeffs.beta );
      rHistory.push_back( coeffs.r );
      rSquaredHistory.push_back( coeffs.rSquared );

    } else {

      alphaHistory.push_back( NA_REAL );
      betaHistory.push_back( NA_REAL );
      rHistory.push_back( NA_REAL );
      rSquaredHistory.push_back( NA_REAL );

    }

  }

  LinRegCoeffs GetValue() { return coeffs; }

  bool IsFormed() { return window.size() == n; }

  void Reset() {

    sumX  = 0;
    sumXX = 0;
    sumY  = 0;
    sumYY = 0;
    sumXY = 0;
    coeffs = {};

    std::queue< pair > empty;
    std::swap( window, empty );

  }

  Rcpp::DataFrame GetHistory() {

    Rcpp::DataFrame history = ListBuilder()
    .Add( "alpha", alphaHistory )
    .Add( "beta", betaHistory )
    .Add( "r", rHistory )
    .Add( "r.squared", rSquaredHistory );
    return history;

    return history;
  }

  std::vector< double > GetAlphaHistory() { return alphaHistory; }
  std::vector< double > GetBetaHistory() { return betaHistory; }
  std::vector< double > GetRHistory() { return rHistory; }
  std::vector< double > GetRSquaredHistory() { return rSquaredHistory; }

};

#endif //ROLLLINREG_H
