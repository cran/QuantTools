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

#ifndef PROCESSORMULTI_H
#define PROCESSORMULTI_H

#include "Processor.h"

class ProcessorMulti {

private:

  std::vector< Processor* > processors;
  int n;

public:

  ProcessorMulti( int timeFrame, int n ) :
  n( n )
  {

    for( auto i = 0; i < n; i++ ) {

      processors.push_back( new Processor( timeFrame ) );

    }

  };

  ~ProcessorMulti() {

    for( auto processor: processors ) delete processor;
    processors.clear();

  }

  Processor* Get( int i ) { return processors[i]; }

  void Feed( Rcpp::DataFrame ticks ) {

    Rcpp::StringVector names = ticks.attr( "names" );

    bool hasTime   = std::find( names.begin(), names.end(), "time"   ) != names.end();
    bool hasPrice  = std::find( names.begin(), names.end(), "price"  ) != names.end();
    bool hasVolume = std::find( names.begin(), names.end(), "volume" ) != names.end();

    bool hasBid    = std::find( names.begin(), names.end(), "bid"    ) != names.end();
    bool hasAsk    = std::find( names.begin(), names.end(), "ask"    ) != names.end();
    //bool hasSystem = std::find( names.begin(), names.end(), "system" ) != names.end();
    bool hasSymbol = std::find( names.begin(), names.end(), "symbol" ) != names.end();

    if( !hasTime   ) throw std::invalid_argument( "ticks must contain 'time' column"   );
    if( !hasPrice  ) throw std::invalid_argument( "ticks must contain 'price' column"  );
    if( !hasVolume ) throw std::invalid_argument( "ticks must contain 'volume' column" );
    if( !hasSymbol ) throw std::invalid_argument( "ticks must contain 'symbol' column" );

  /*  if( executionType == ExecutionType::BBO ) {

      if( !hasBid ) throw std::invalid_argument( "ticks must contain 'bid' column"  );
      if( !hasAsk ) throw std::invalid_argument( "ticks must contain 'ask' column" );

  }*/

    Rcpp::NumericVector  bids;
    Rcpp::NumericVector  asks;
    Rcpp::LogicalVector  systems;

    Rcpp::NumericVector  times   = ticks[ "time"   ];
    Rcpp::NumericVector  prices  = ticks[ "price"  ];
    Rcpp::IntegerVector  volumes = ticks[ "volume" ];

    Rcpp::IntegerVector  symbols = ticks[ "symbol" ];

    if( hasBid    )      bids    = ticks[ "bid"    ];
    if( hasAsk    )      asks    = ticks[ "ask"    ];
/*
    std::vector<std::string> tzone = times.attr( "tzone" );

    if( tzone.empty() ) throw std::invalid_argument( "ticks timezone must be set" );
*/
    auto n = times.size();

    Tick tick;
    Tick tickTrigger;
    int symbol;

    for( auto id = 0; id < n; id++ ) {

      tick.id     = id;
      tick.time   = times  [id];
      tick.price  = prices [id];
      tick.volume = volumes[id];
      tick.system = false;

      if( hasBid    ) tick.bid    = bids   [id];
      if( hasAsk    ) tick.ask    = asks   [id];

      symbol = symbols[id];

      tickTrigger.id     = id;
      tickTrigger.time   = times[id];
      tickTrigger.system = true;


      for( int i = 0; i < this->n; i++ ) {

        processors[ i ]->Feed( symbol == i ? tick : tickTrigger );

      }

    }

    for( auto processor: processors ) processor->statistics.Finalize();

  }


};

#endif //PROCESSORMULTI_H
