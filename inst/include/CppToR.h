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

#ifndef CPPTOR_H
#define CPPTOR_H

inline Rcpp::NumericVector DoubleToDateTime( std::vector<double> times, std::string timeZone = "UTC" ) {

  Rcpp::NumericVector dateTimeVector = Rcpp::wrap( times );
  dateTimeVector.attr( "class" ) = Rcpp::CharacterVector::create( "POSIXct", "POSIXt" );
  dateTimeVector.attr( "tzone" ) = Rcpp::CharacterVector::create( timeZone );

  return dateTimeVector;

}

inline Rcpp::NumericVector DoubleToDateTime( double time, std::string timeZone = "UTC" ) {

  Rcpp::NumericVector dateTimeVector( 1, time );
  dateTimeVector.attr( "class" ) = Rcpp::CharacterVector::create( "POSIXct", "POSIXt" );
  dateTimeVector.attr( "tzone" ) = Rcpp::CharacterVector::create( timeZone );

  return dateTimeVector;

}

inline Rcpp::IntegerVector IntToDate( std::vector<int> dates ) {

  Rcpp::IntegerVector dateVector = Rcpp::wrap( dates );
  dateVector.attr( "class" ) = Rcpp::CharacterVector::create( "Date" );

  return dateVector;

}

inline Rcpp::IntegerVector IntToFactor( std::vector<int> x, std::vector<std::string> levels ) {

  Rcpp::IntegerVector factor = Rcpp::wrap( x );
  factor.attr( "levels" ) = Rcpp::wrap( levels );
  factor.attr( "class" ) = "factor";

  return factor;

}

#endif //CPPTOR_H
