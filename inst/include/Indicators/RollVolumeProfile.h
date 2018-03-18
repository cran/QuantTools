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

#ifndef ROLLVOLUMEPROFILE_H
#define ROLLVOLUMEPROFILE_H

#include <math.h>
#include <queue>
#include <set>
#include "../BackTest/Tick.h"
#include "../ListBuilder.h"
#include "../CppToR.h"
#include "Indicator.h"

class RollVolumeProfile : public Indicator< Tick, std::map<double,double>, Rcpp::List > {

private:

  int timeFrame;
  double step;
  double alpha;
  double cut;
  std::map<double,double> histogram;
  double time;

  std::vector< double > timeHistory;
  std::vector<Rcpp::List> volumeProfileHistory;

public:

  RollVolumeProfile( int timeFrame, double step, double alpha, double cut ) :
  timeFrame( timeFrame ),
  step( step ),
  alpha( alpha ),
  cut( cut )
  {

    if( timeFrame <= 0 ) throw std::invalid_argument( "timeFrame must be greater than 0" );
    if( step      <= 0 ) throw std::invalid_argument(      "step must be greater than 0" );
    if( alpha < 0 or alpha > 1 ) throw std::invalid_argument(     "alpha must be in (0,1]" );
    if( cut       <= 0 ) throw std::invalid_argument(       "cut must be greater than 0" );
    time = 0;

  }

  void Add( Tick tick ) {

    double time = trunc( tick.time / timeFrame ) * timeFrame + timeFrame;

    if( histogram.size() == 0 ) this->time = time;
    if( this->time != time ) {

      std::vector< double > prices;
      std::vector< double > volumes;

      for( auto it = histogram.begin(); it != histogram.end(); ) {

        prices.push_back( it->first );
        volumes.push_back( it->second );

        it->second *= alpha;

        if ( it->second <= cut ) {
          it = histogram.erase( it );
        } else {
          ++it;
        }

      }

      Rcpp::NumericVector rTime( prices.size(), this->time );

      rTime.attr( "class" ) = Rcpp::CharacterVector::create( "POSIXct", "POSIXt" );
      rTime.attr( "tzone" ) = "UTC";

      Rcpp::List volumeProfile = ListBuilder().AsDataTable()
        .Add( "time"  , rTime   )
        .Add( "price" , prices  )
        .Add( "volume", volumes );

      volumeProfileHistory.push_back( volumeProfile );
      timeHistory.push_back( time );

      this->time = time;
    }

    double price = round( tick.price / step ) * step;
    histogram[ price ] += tick.volume;

  }

  bool IsFormed() { return true; }

  std::map<double,double> GetValue() { return histogram; }

  Rcpp::List GetHistory(){

    Rcpp::List history = ListBuilder()
    .Add( "time"   , DoubleToDateTime( timeHistory, "UTC" ) )
    .Add( "profile", volumeProfileHistory                   );
    return history;

  }

  void Reset() {

    histogram.clear();
    time = 0;

  }

};

#endif //ROLLVOLUMEPROFILE_H
