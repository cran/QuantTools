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

#' Check if values are between specified interval
#'
#' @param x vector
#' @param interval vector of length 1 or 2, see 'Examples' section
#' @details If second element of interval contains time selection is closed on the left only (\code{a <= x < b}) otherwise selection is closed (\code{a <= x <= b}).
#' @examples
#' \donttest{
#'
#' data( ticks )
#'
#' # bw is very usefull to filter time series data:
#' # select single year
#' ticks[ time %bw% '2016' ]
#'
#' # select single month
#' ticks[ time %bw% '2016-05' ]
#'
#' # select single date
#' ticks[ time %bw% '2016-05-11' ]
#' # also works with Date class
#' ticks[ time %bw% as.Date( '2016-05-11' ) ]
#'
#' # select single hour
#' ticks[ time %bw% '2016-05-11 10' ]
#'
#' # select single minute
#' ticks[ time %bw% '2016-05-11 10:20' ]
#'
#' # select single second
#' ticks[ time %bw% '2016-05-11 10:20:53' ]
#'
#' # select between two months inclusive
#' ticks[ time %bw% c( '2016-05', '2016-08' ) ]
#'
#' # select from month begin and date
#' ticks[ time %bw% c( '2016-05', '2016-06-23' ) ]
#'
#' # select between two timestamps
#' ticks[ time %bw% c( '2016-05-02 09:30', '2016-05-02 11:00' ) ]
#' # also works with incomplete timestamps
#' ticks[ time %bw% c( '2016-05-02 09:30', '2016-05-02 11' ) ]
#'
#' # select all dates but with time between 09:30 and 16:00
#' ticks[ time %bw% c( '09:30', '16:00' ) ]
#'
#' # also bw can be used as a shortcut for 'a <= x & x <= b' for non-'POSIXct' classes:
#' # numeric
#' 15:25 %bw% c( 10, 20 )
#'
#' # character
#' letters %bw% c( 'a', 'f' )
#'
#' # dates
#' Sys.Date() %bw% ( Sys.Date() + c( -10, 10 ) )
#'
#'
#' }
#' @name bw
#' @export
bw = function( x, interval ) {

  if( is.null( interval ) ) return( rep( T, length( x ) ) )
  len  = length( interval )

  if( len > 2 ) stop( "interval must be a vector of length 1 or 2" )

  if( 'POSIXct' %in% class( x ) ) {

    tz = attr( x, 'tzone' )
    if( is.null( tz ) ) tz = ''

    format_error = function() stop(
      "incorrect string format. Must be
      '%Y', '%Y-%m', '%Y-%m-%d', '%Y-%m-%d %H',
      '%Y-%m-%d %H:%M', '%Y-%m-%d %H:%M:%OS' or
      '%H:%M', '%H:%M:%OS' " )

    interval = sapply( interval, format )

    if( len == 2 & all( grepl( '^\\d{2}:\\d{2}', interval ) ) ) {

      to_hours = function( text_time ) {

        x = unlist( strsplit( text_time, ':' ) )
        x = as.numeric( x )

        h = sum( x / 60^( seq_along( x ) - 1 ) )
        round( h, 6 )

      }
      interval = c( to_hours( interval[1] ), to_hours( interval[2] ) )

      return( round( ( as.numeric( to_UTC( x ) ) / ( 3600 ) ) %% 24, 6 ) %bw% interval )


    }

    to_time = function( text_time, upper = F ) {

      if( nchar( text_time ) < 10 ) {

        switch( format( nchar( text_time ) ),
                '7' = { text_time = paste0( text_time, '-01' ); units = 'month' },
                '4' = { text_time = paste0( text_time, '-01-01' ); units = 'years' },
                format_error() )

        time = strptime( text_time, format = '%Y-%m-%d', tz = tz )
        if( units == 'month' ) time$mon = time$mon + upper
        if( units == 'years' ) time$year = time$year + upper

      } else {

        switch( format( nchar( text_time ) ),
                '10' = { format = '%Y-%m-%d'; units = 'days' },
                '13' = { format = '%Y-%m-%d %H'; units = 'hours' },
                '16' = { format = '%Y-%m-%d %H:%M'; units = 'mins' },
                '19' = { format = '%Y-%m-%d %H:%M:%OS'; units = 'secs' },
                format_error() )

        time = strptime( text_time, format, tz = tz ) + as.difftime( upper * 1, units = units )

      }

      if( is.na( time ) ) format_error()
      return( as.POSIXct( time ) )

    }

    from = to_time( interval[1] )[1]
    to   = to_time( interval[len], !grepl( ' ', interval[2] ) )[1]

    if( to < from ) stop( "interval start must be lower or equal to end" )
    return( from <= x & x < to )

  } else {

    from = interval[1]
    to   = interval[2]

    if( len == 1 ) stop( "both interval start and end must be set" )
    return( from <= x & x <= to )

  }

}
#' @name bw
#' @export
`%bw%` = bw
