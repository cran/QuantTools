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

#ifndef CROSSOVER_H
#define CROSSOVER_H

#include <vector>
#include "Indicator.h"
#include <Rcpp.h>

class Crossover : public Indicator< std::pair< double, double >, double, Rcpp::IntegerVector > {

private:

  enum class Type: int { ABOVE, BELOW, WAIT };
  std::vector< std::string > TypeString = { "UP", "DN" };

  std::pair< double, double > pair;
  Type type;
  std::vector< int > history;

  public:

    Crossover()
    {
      Reset();
    }

    void Add( std::pair< double, double > pair )
    {

      if( this->pair.first > this->pair.second and pair.first < pair.second ) {

        type = Type::BELOW;
        this->pair = pair;
        history.push_back( (int)type + 1 );
        return;

      }

      if( this->pair.first < this->pair.second and pair.first > pair.second ) {

        type = Type::ABOVE;
        this->pair = pair;
        history.push_back( (int)type + 1 );
        return;

      }
      if( pair.first != pair.second ) {

        this->pair = pair;

      }

      type = Type::WAIT;
      history.push_back( NA_INTEGER );

    }

    bool IsFormed() { return not ( std::isnan( pair.first ) or std::isnan( pair.second ) ); }

    bool IsAbove() { return type == Type::ABOVE; }
    bool IsBelow() { return type == Type::BELOW; }
    Rcpp::IntegerVector GetHistory() {

      Rcpp::IntegerVector history = Rcpp::wrap( this->history );
      history.attr( "levels" ) = Rcpp::wrap( TypeString );
      history.attr( "class" ) = "factor";
      return history;

    }

    void Reset() {
      pair = { NAN, NAN };
      type = Type::WAIT;
    }


};

#endif //CROSSOVER_H
