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
#' ticks[ time %bw% '2016-05/2016-08' ]
#'
#' # select from month begin and date
#' ticks[ time %bw% '2016-05/2016-06-23' ]
#'
#' # select between two timestamps
#' ticks[ time %bw% '2016-05-02 09:30/2016-05-02 11:00' ]
#' # also works with incomplete timestamps
#' ticks[ time %bw% '2016-05-02 09:30/2016-05-02 11' ]
#'
#' # select all dates but with time between 09:30 and 16:00
#' ticks[ time %bw% '09:30/16:00' ]
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

  if( is.null( interval ) ) return( !vector( length = length( x ) ) )
  if( is.character( interval ) ) {

    if( inherits( x, 'POSIXct' ) ) {

      if( length( interval ) == 2 ) interval = paste( interval, collapse = '/' )
      interval = .text_to_time_interval( interval, attr( x, 'tzone' ) )
      if( is.numeric( interval ) ) {
        return( round( as.numeric( to_UTC( x ) ) %% ( 24 * 60 * 60 ), 6 ) %bw% interval )
      }
      return( interval[1] <= x & x < interval[2] )

    }
    if( inherits( x, 'Date' ) ) {

      if( length( interval ) == 2 ) interval = paste( interval, collapse = '/' )
      interval = as.Date( .text_to_time_interval( interval ) )
      return( interval[1] <= x & x <= interval[2] )

    }
  }
  if( length( interval ) == 1 ) {

    if( inherits( interval, 'Date' ) ) {

      interval[2] = interval + 1

      if( inherits( x, 'POSIXct' ) ) {

        interval = fasttime::fastPOSIXct( interval, attr( x, 'tzone' ) )

      }
      return( interval[1] <= x & x < interval[2] )

    }
    stop( 'interval must contain two elements' )

  }

  x >= interval[1] & x <= interval[2]

}
#' @name bw
#' @export
`%bw%` = bw

.text_to_time_interval = function( x, tzone = NULL ) {

  tlim = NULL
  if( is.null( tzone ) ) tzone = 'UTC'
  from_to = strsplit( x, split = '/', fixed = T )[[1]]
  nchar = nchar( from_to )
  if( nchar[1] > 12 ) {

    if( length( nchar ) == 1 ) {
      tlim = fasttime::fastPOSIXct( if( any( nchar == c( 15, 18 ) ) ) paste0( from_to, '0' ) else from_to, tz = tzone )
      # dt
      tlim[2] = tlim[1] +
        if( nchar > 18 ) as.difftime( 1 , units = 'secs' ) else
        if( nchar > 17 ) as.difftime( 10, units = 'secs' ) else
        if( nchar > 15 ) as.difftime( 1 , units = 'mins' ) else
        if( nchar > 14 ) as.difftime( 10, units = 'mins' ) else
        as.difftime( 1, units = 'hours' )

    } else
      # dt/dt
      if( nchar[2] > 12 ) tlim = fasttime::fastPOSIXct( from_to, tz = tzone ) else
      # dt/t
      if( nchar[2] > 1  ) tlim = fasttime::fastPOSIXct( c( from_to[1], paste( substr( from_to[1], 1, 10 ), from_to[2] ) ), tz = tzone )

  }
  if( nchar[1] < 11 ) {

    if( all( nchar < 4 | ( nchar > 4 & !grepl( '-', from_to, fixed = T ) ) ) ) {
      # t/t
      return( .text_time_to_seconds( from_to ) )
    }
    # d
    if( nchar[1] > 9 ) {
      tlim = as.Date( from_to[1] ) + 0:1
    } else
    if( nchar[1] > 6 ) {
      tlim = rep( as.POSIXlt( paste0( from_to[1], '-01' ), tz = tzone ), 2 )
      tlim[2]$mon = tlim[2]$mon + 1
    } else
    if( nchar[1] > 3 ) {
      tlim = rep( as.POSIXlt( paste0( from_to[1], '-01-01' ), tz = tzone ), 2 )
      tlim[2]$year = tlim[2]$year + 1
    }

    if( length( nchar ) == 2 ) {
      if( nchar[2] < 11 ) {
        # d/d
        if( nchar[2] > 9 ) {
          tlim[2] = as.Date( from_to[2] ) + 1
        } else
        if( nchar[2] > 6 ) {
          tlim[2] = as.POSIXlt( paste0( from_to[2], '-01' ), tz = tzone )
          tlim[2]$mon = tlim[2]$mon + 1
        } else
        if( nchar[2] > 3 ) {
          tlim[2] = as.POSIXlt( paste0( from_to[2], '-01-01' ), tz = tzone )
          tlim[2]$year = tlim[2]$year + 1
        }
      }
    }
    if( !is.null( tlim ) ) tlim = fasttime::fastPOSIXct( tlim, tz = tzone )
  }
  tlim
}

.text_time_to_seconds = function( text_time ) {

  h = lapply( strsplit( text_time, ':', fixed = T ), function( x ) {

    sum( as.numeric( x ) / 60^( seq_along( x ) - 1 ) )

  } )
  round( unlist( h ) * 60 * 60, 6 )

}


