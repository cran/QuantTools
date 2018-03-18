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

#include "../inst/include/Indicators/RollLinReg.h"

//' Rolling Linear Regression
//'
//' @name roll_lm
//' @param n window size
//' @param x,y numeric vectors
//' @family technical indicators
//' @return roll_lm returns data.table with columns \code{alpha, beta, r, r.squared}
//' @description Rolling linear regression calculates regression coefficients over n past paired values.
//' \cr Others return numeric vector
//' @export
// [[Rcpp::export]]
Rcpp::List roll_lm( Rcpp::NumericVector x, Rcpp::NumericVector y, std::size_t n ) {

  RollLinReg lm( n );

  for( auto i = 0; i < x.size(); i++ ) lm.Add( std::pair< double, double >( x[i], y[i] ) );

  return lm.GetHistory();

}
//' @rdname roll_lm
//' @export
// [[Rcpp::export]]
std::vector< double > roll_correlation( Rcpp::NumericVector x, Rcpp::NumericVector y, std::size_t n ) {

  RollLinReg lm( n );

  for( auto i = 0; i < x.size(); i++ ) lm.Add( std::pair< double, double >( x[i], y[i] ) );

  return lm.GetRHistory();

}
