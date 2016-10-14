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

#include "../inst/include/Indicators/Ema.h"

//' @title Exponential Moving Average
//' @param x numeric vectors
//' @param n window size
//' @family technical indicators
//' @description Exponentially weighted moving average aka EMA is exponentially weighted SMA. EMAs have faster response to recent value changes than SMAs.
//' @export
// [[Rcpp::export]]
std::vector<double> ema( Rcpp::NumericVector x, std::size_t n ) {

  Ema ema( n );

  for( auto i = 0; i < x.size(); i++ ) ema.Add( x[i] );

  return ema.GetHistory();

}
//' @name ema
