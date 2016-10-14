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

#ifndef SETDT_H
#define SETDT_H

template <typename T>
void setDT( T& x ){

  x.attr( "class" ) = Rcpp::StringVector::create( "data.table", "data.frame" );
  x.attr( ".internal.selfref" ) = R_MakeExternalPtr( R_NilValue, x.attr( "names" ), R_MakeExternalPtr( x, R_NilValue, R_NilValue ) );
  SET_TRUELENGTH( x, LENGTH( x )  );

}

#endif //SETDT_H
