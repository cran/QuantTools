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

  std::vector<std::string> names;
  std::vector<SEXP> elements;

  ListBuilder(ListBuilder const&) {};

public:

  ListBuilder() {};
  ~ListBuilder() {};
  template <typename T>
  inline ListBuilder& Add( std::string name, T x ) {

    names.push_back( name );
    elements.push_back( Rcpp::wrap( x ) );
    return *this;

  }
  inline ListBuilder& Add( Rcpp::DataFrame x ) {

    std::vector< std::string > names = x.names();
    for ( int i = 0; i < x.size(); ++i ) {

      this->names.push_back( names[i] );
      elements.push_back( x[i] );

    }
    return *this;
  }
  inline operator Rcpp::List() const {

    Rcpp::List list( elements.size() );

    for ( size_t i = 0; i < elements.size(); ++i ) {

      list[i] = elements[i];

    }
    list.attr( "names" ) = Rcpp::wrap( names );
    return list;

  }

  inline operator Rcpp::DataFrame() const {

    Rcpp::List df = static_cast< Rcpp::List >( *this );
    setDT( df );
    return df;

  }

};
#endif //LISTBUILDER_H
