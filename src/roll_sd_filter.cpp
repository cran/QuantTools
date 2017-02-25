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

#include "../inst/include/Indicators/RollSd.h"

//' Rolling Filter
//'
//' @name roll_sd_filter
//' @param x numeric vector
//' @param n window size
//' @param k number of standard deviations
//' @param m number of consequent large returns to stop filtering out
//' @description Logical vector is returned. This function is useful to filter ticks. Finds consequent elements which absolute change is higher than k standard deviation of past n changes and mark them \code{FALSE}. If sequence length greater than \code{m} values become \code{TRUE}.
//' @export
// [[Rcpp::export]]
std::vector< bool > roll_sd_filter( Rcpp::NumericVector x, int n, double k = 1, int m = 10 ) {

  std::vector< bool > filter;
  filter.push_back( false );

  RollSd sd( n );

  int j = 0;
  for( int i = 1; i < x.size(); i++ ) {

    double change = std::abs( x[i] - x[i-1] );
    sd.Add( change );
    if( not sd.IsFormed() ) {

      filter.push_back( true );
      continue;

    }
    if( std::abs( x[i + j] - x[i-1] ) > sd.GetValue() * k ) {
      j++;
      filter.push_back( false );
    } else {
      j = 0;
      filter.push_back( true );
    }

    if( j == m ) j = 0;

  }

  return filter;

};
