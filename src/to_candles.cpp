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

#include <Rcpp.h>
#include <vector>
#include "../inst/include/BackTest/Candle.h"
#include "../inst/include/BackTest/Tick.h"
#include "../inst/include/ListBuilder.h"
#include "../inst/include/CppToR.h"

//' Convert ticks to candles
//'
//' @name to_candles
//' @param ticks read 'Ticks' section in \link{Processor}
//' @param timeframe candle timeframe in seconds
//' @return data.table with columns \code{time, open, high, low, close, volume, id}. Where \code{id} is row number of last tick in candle. \cr
//' Note: last candle is always omitted.
//' @rdname to_candles
//' @export
// [[Rcpp::export]]
Rcpp::List to_candles( Rcpp::DataFrame ticks, int timeframe ) {

  Rcpp::StringVector names = ticks.attr( "names" );

  bool hasTime   = std::find( names.begin(), names.end(), "time"   ) != names.end();
  bool hasPrice  = std::find( names.begin(), names.end(), "price"  ) != names.end();
  bool hasVolume = std::find( names.begin(), names.end(), "volume" ) != names.end();

  if( !hasTime   ) throw std::invalid_argument( "ticks must contain 'time' column"   );
  if( !hasPrice  ) throw std::invalid_argument( "ticks must contain 'price' column"  );
  if( !hasVolume ) throw std::invalid_argument( "ticks must contain 'volume' column" );

  Rcpp::NumericVector  times   = ticks[ "time"   ];
  Rcpp::NumericVector  prices  = ticks[ "price"  ];
  Rcpp::IntegerVector  volumes = ticks[ "volume" ];

  Candle candle( timeframe );
  Candle candleProcessing( timeframe );
  std::vector<Candle> candles;

  for( int id = 0; id < times.size(); id++ ) {

    Tick tick = { (int)id, times[id], prices[id], volumes[id] };

    bool startOver = candleProcessing.time != floor( tick.time / timeframe ) * timeframe + timeframe;

    if( startOver and candleProcessing.time != 0 ) {

      candle = candleProcessing;
      candles.push_back( candle );

    }

    candleProcessing.Add( tick );

  };

  int n = candles.size();

  Rcpp::IntegerVector id    ( n );
  Rcpp::NumericVector open  ( n );
  Rcpp::NumericVector high  ( n );
  Rcpp::NumericVector low   ( n );
  Rcpp::NumericVector close ( n );
  Rcpp::NumericVector time  ( n );
  Rcpp::IntegerVector volume( n );

  for( int i = 0; i < n; i++ ){

    id    [i] = candles[i].id;
    open  [i] = candles[i].open;
    high  [i] = candles[i].high;
    low   [i] = candles[i].low;
    close [i] = candles[i].close;
    time  [i] = candles[i].time;
    volume[i] = candles[i].volume;

  }

  time.attr( "class" ) = Rcpp::CharacterVector::create( "POSIXct", "POSIXt" );
  time.attr( "tzone" ) = times.attr( "tzone" );

  Rcpp::List output = ListBuilder().AsDataTable()
    .Add( "time"  , time   )
    .Add( "open"  , open   )
    .Add( "high"  , high   )
    .Add( "low"   , low    )
    .Add( "close" , close  )
    .Add( "volume", volume )
    .Add( "id"    , id + 1 );

  setDT( output );

  return output;


}
