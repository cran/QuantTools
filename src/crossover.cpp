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

#include "../inst/include/Indicators/Crossover.h"
#include <stdexcept>

//' Crossover
//'
//' @name crossover
//' @param x,y numeric vectors
//' @family technical indicators
//' @description Crossover is binary indicator indicating the moment when one value goes above or below another.
//' @export
// [[Rcpp::export]]
Rcpp::IntegerVector crossover( Rcpp::NumericVector x, Rcpp::NumericVector y ) {

  if( x.size() != y.size() ) throw std::invalid_argument( "x and y lengths must be equal" );

  Crossover crossover;

  for( auto i = 0; i < x.size(); i++ ) crossover.Add( std::pair< double, double > ( x[i], y[i] ) );

  return crossover.GetHistory();

}
