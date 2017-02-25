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

#include "../inst/include/Indicators/RollPercentRank.h"

//' Rolling Percent Rank
//'
//' @name roll_percent_rank
//' @param x numeric vector
//' @param n window size
//' @family technical indicators
//' @description Rolling percent rank normalizes values to a range from 0 to 100.
//' @export
// [[Rcpp::export]]
std::vector<double> roll_percent_rank( Rcpp::NumericVector x, std::size_t n ) {

  RollPercentRank percentRank( n );

  for( auto i = 0; i < x.size(); i++ ) percentRank.Add( x[i] );

  return percentRank.GetHistory();

}
