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

#ifndef LISTBUILDER_H
#define LISTBUILDER_H
//http://lists.r-forge.r-project.org/pipermail/rcpp-devel/2014-July/007808.html

#include <Rcpp.h>
#include "setDT.h"

class ListBuilder {
private:

  std::vector< std::string > names;
  Rcpp::List elements;

  ListBuilder( ListBuilder const& ) {};

  std::string type;

public:

  ListBuilder() { type = "list"; };
  ~ListBuilder() {};

  inline ListBuilder& AsDataFrame( ) { type = "data.frame"; return *this; }

  inline ListBuilder& AsDataTable( ) { type = "data.table"; return *this; }

  inline ListBuilder& Add( Rcpp::DataFrame x ) {

    std::vector< std::string > names = x.names();
    for ( int i = 0; i < x.size(); ++i ) {

      this->names.push_back( names[i] );
      elements.push_back( x[i] );

    }
    return *this;
  }

  inline ListBuilder& Add( Rcpp::List x ) {

    std::vector< std::string > names = x.names();
    for ( int i = 0; i < x.size(); ++i ) {

      this->names.push_back( names[i] );
      elements.push_back( x[i] );

    }
    return *this;
  }

  template <typename T>
  inline ListBuilder& Add( const std::string& name, const T& x ) {

    names.push_back( name ) ;
    elements.push_back( Rcpp::wrap( x ) );
    return *this;

  }

  inline operator Rcpp::List() const {

    Rcpp::List result( elements );

    result.attr( "names" ) = Rcpp::wrap( names );

    if( type == "data.frame" ) {

      result.attr( "class"     ) = "data.frame";
      result.attr( "row.names" ) = Rcpp::IntegerVector::create( NA_INTEGER, XLENGTH( elements[0] ) );

    }

    if( type == "data.table" ) {

      setDT( result );

    }

    return result;

  }

  inline operator Rcpp::DataFrame() const { return R_NilValue; }

};

#endif //LISTBUILDER_H
