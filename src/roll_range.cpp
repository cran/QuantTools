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

#include "../inst/include/Indicators/RollRange.h"

//' Rolling Range
//'
//' @name roll_range
//' @param x numeric vectors
//' @param n window size
//' @param p probability value \code{[0, 1]}
//' @family technical indicators
//' @return
//' roll_range returns data.table with columns \code{min, max}
//' \cr others return numeric vector
//' @description Rolling range is minimum and maximum values over n past values. Can be used to identify price range.
//' @export
// [[Rcpp::export]]
Rcpp::List roll_range( Rcpp::NumericVector x, std::size_t n ) {

  RollRange range( n );

  for( auto i = 0; i < x.size(); i++ ) range.Add( x[i] );

  return range.GetHistory();

}
//' @rdname roll_range
//' @export
// [[Rcpp::export]]
std::vector<double> roll_quantile( Rcpp::NumericVector x, std::size_t n, double p ) {

  RollRange range( n, p );

  for( auto i = 0; i < x.size(); i++ ) range.Add( x[i] );

  return range.GetQuantileHistory();

}
//' @rdname roll_range
//' @export
// [[Rcpp::export]]
std::vector<double> roll_min( Rcpp::NumericVector x, std::size_t n ) {

  RollRange range( n );

  for( auto i = 0; i < x.size(); i++ ) range.Add( x[i] );

  return range.GetMinHistory();

}
//' @rdname roll_range
//' @export
// [[Rcpp::export]]
std::vector<double> roll_max( Rcpp::NumericVector x, std::size_t n ) {

  RollRange range( n );

  for( auto i = 0; i < x.size(); i++ ) range.Add( x[i] );

  return range.GetMaxHistory();

}
