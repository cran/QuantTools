# Copyright (C) 2016 Stanislav Kovalevsky
#
# This file is part of QuantTools.
#
# QuantTools is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# QuantTools is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with QuantTools. If not, see <http://www.gnu.org/licenses/>.

#' Convert candles to ticks
#'
#' @param x candles, read 'Candles' in \link{Processor}
#' @name to_ticks
#' @details Convert OHLCV candles to ticks using the following model. One candle is equivalent to four ticks \code{( time, price, volume )}: \code{( time - period, open, volume / 4 ); ( time - period / 2, high, volume / 4 ); ( time - period / 2, low, volume / 4 ); ( time - period / 100, close, volume / 4 )}. Assuming provided candles have frequent period ( less than a minute ) it is a good approximation for tick data which can be used to speed up back testing or if no raw tick data available.
#' @examples
#' \donttest{
#'
#' data( ticks )
#' candles = to_candles( ticks, timeframe = 60 )
#' to_ticks( candles )
#'
#' }
#' @export
to_ticks = function( x ){

  period = x[ 1:min( 100, .N ), min( diff( time )[ -1 ] ) ]

  time = open = high = low = volume = NULL

  ticks = x[, list(
    time   = c( time - period, time - period / 2, time - period / 2, time - period / 100 ),
    price  = c( open         , high             , low              , close               ),
    volume = c( volume / 4   , volume / 4       , volume / 4       , volume / 4          )
  ) ][ order( time ) ]
  ticks[, volume := pmax( volume, 1 ) ]
  attributes( ticks$time ) = attributes( x$time )



  return( ticks )

}
