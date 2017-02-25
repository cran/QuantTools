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

#include "../inst/include/Indicators/RollVolumeProfile.h"

//' Rolling Volume Profile
//'
//' @name roll_volume_profile
//' @param ticks read 'Ticks' section in \link{Processor}
//' @param timeFrame indicator period in seconds, when to apply alpha correction
//' @param step price round off value, bar width
//' @param alpha multiplication coefficient must be between (0,1]
//' @param cut threshold volume when to delete bar
//' @return data.table with columns \code{time, profile} where profile is data.table with columns \code{time, price, volume}
//' @description This indicator is not common. Volume profile is the distribution of volume over price. It is formed tick by tick and partially forgets past values over time interval. When volume on any bar is lower than specified critical value the bar is cut.
//' @family technical indicators
//' @export
// [[Rcpp::export]]
Rcpp::List roll_volume_profile( Rcpp::DataFrame ticks, int timeFrame, double step, double alpha, double cut ) {

  Rcpp::StringVector names = ticks.attr( "names" );

  bool hasTime   = std::find( names.begin(), names.end(), "time"   ) != names.end();
  bool hasPrice  = std::find( names.begin(), names.end(), "price"  ) != names.end();
  bool hasVolume = std::find( names.begin(), names.end(), "volume" ) != names.end();

  if( !hasTime   ) throw std::invalid_argument( "ticks must contain 'time' column"   );
  if( !hasPrice  ) throw std::invalid_argument( "ticks must contain 'price' column"  );
  if( !hasVolume ) throw std::invalid_argument( "ticks must contain 'volume' column" );

  Rcpp::NumericVector prices  = ticks[ "price"   ];
  Rcpp::NumericVector times   = ticks[ "time"    ];
  Rcpp::IntegerVector volumes = ticks[ "volume"  ];

  RollVolumeProfile volumeProfile( timeFrame, step, alpha, cut );

  Tick tick;

  for( auto i = 0; i < times.size(); i++ ) {

    tick.id = i + 1;
    tick.time = times[i];
    tick.volume = volumes[i];
    tick.price = prices[i];

    volumeProfile.Add( tick );

  }

  return volumeProfile.GetHistory();

}
