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

#' Store historical market data
#' @title Store historical market data
#' @param from,to text dates in format \code{"YYYY-mm-dd"}
#' @param verbose show progress?
#' @name store_market_data
#' @details
#' See example below.
#'
#' @examples
#' \donttest{
#'
#' ## Finam data storage
#' settings = list(
#'   # set storage path, it is perfect to use Solid State Drive for data storage
#'   # it is no problem to move storage folder just don't forget to set new path in settings
#'   finam_storage = paste( path.expand('~') , 'Market Data', 'finam', sep = '/' ),
#'   # add some symbols
#'   finam_symbols = c( 'GAZP', 'SBER' ),
#'   # and set storage start date
#'   finam_storage_from = '2016-09-01'
#' )
#' QuantTools_settings( settings )
#' # now it is time to add some data into storage. You have three options here:
#'
#'   # 1 update storage with data from last date available until today
#'   # it is very convenient to create a script with this function and
#'   # run it every time you need to update your storage
#'   store_finam_data()
#'
#'   # 2 update storage with data from last date available until specified date
#'   store_finam_data( to = '2016-09-28' )
#'
#'   # 3 update storage with data between from and to dates,
#'   # if data already present it will be overwritten
#'   store_finam_data( from = '2016-01-01', to = '2016-01-10' )
#'
#' # set local = TRUE to load from just created local market data storage
#' get_finam_data( 'GAZP', '2016-09-01', '2016-09-28', 'tick', local = T )
#'
#' ## iqfeed data storage
#' settings = list(
#'   # set storage path, it is perfect to use Solid State Drive for data storage
#'   # it is no problem to move storage folder just don't forget to set new path in settings
#'   iqfeed_storage = paste( path.expand('~') , 'Market Data', 'iqfeed', sep = '/' ),
#'   # add some symbols
#'   iqfeed_symbols = c( 'AAPL', '@ES#' ),
#'   # and set storage start date
#'   iqfeed_storage_from = format( Sys.Date() - 3 )
#' )
#' QuantTools_settings( settings )
#' # now it is time to add some data into storage. You have three options here:
#'
#'   # 1 update storage with data from last date available until today
#'   # it is very convenient to create a script with this function and
#'   # run it every time you need to update your storage
#'   store_iqfeed_data()
#'
#'   # 2 update storage with data from last date available until specified date
#'   store_iqfeed_data( to = format( Sys.Date() ) )
#'
#'   # 3 update storage with data between from and to dates,
#'   # if data already present it will be overwritten
#'   store_iqfeed_data( from = format( Sys.Date() - 3 ), to = format( Sys.Date() ) )
#'
#' # set local = TRUE to load from just created local market data storage
#' get_iqfeed_data( 'AAPL', format( Sys.Date() - 3 ), format( Sys.Date() ), 'tick', local = T )
#'
#' }
#' @rdname store_market_data
#' @export
store_finam_data = function( from = NULL, to = format( Sys.Date() ), verbose = TRUE ) {

  save_dir = .settings$finam_storage
  symbols = .settings$finam_symbols

  if( save_dir == '' ) stop( 'please set storage path via QuantTools_settings( \'finam_storage\', \'/storage/path/\' ) ' )
  if( is.null( symbols ) ) stop( 'please set symbols vector via QuantTools_settings( \'finam_symbols\', c( \'symbol_1\', ...,\'symbol_n\' ) ) ' )


  from_is_null = is.null( from )

  for( symbol in symbols ) {

    if( verbose ) message( symbol )

    if( from_is_null ) from = NULL

    dates_available = gsub( '.rds', '', list.files( paste( save_dir, symbol, sep = '/' ), pattern = '.rds' ) )
    if( is.null( from ) && length( dates_available ) == 0 ) {

      from = .settings$finam_storage_from
      if( from == '' ) stop( 'please set Finam storage start date via QuantTools_settings( \'finam_storage_from\', \'YYYYMMDD\' )' )
      message( 'not found in storage, \ntrying to download since storage start date' )

    }
    if( is.null( from ) && to >= max( dates_available ) ) {

      from = max( dates_available )
      message( paste( 'dates to be added:', from, '-', to ) )

    }

    from = as.Date( from )
    to = as.Date( to )

    dates = format( seq( from, to, 1 ) )

    for( date in dates ) {

      ticks = get_finam_data( symbol, date, period = 'tick' )
      if( is.null( ticks ) ) next

      dir.create( paste0( save_dir, '/' , symbol ), recursive = TRUE, showWarnings = FALSE )

      saveRDS( ticks, file = paste0( save_dir, '/' , symbol, '/', date, '.rds' ) )

      if( verbose ) message( paste( date,  'saved' ) )

    }

  }

}
#' @rdname store_market_data
#' @export
# iqfeed
store_iqfeed_data = function( from = NULL, to = format( Sys.Date() ), verbose = TRUE ) {

  save_dir = .settings$iqfeed_storage
  symbols = .settings$iqfeed_symbols

  if( save_dir == '' ) stop( 'please set storage path via QuantTools_settings( \'iqfeed_storage\', \'/storage/path/\' ) ' )
  if( is.null( symbols ) ) stop( 'please set symbols vector via QuantTools_settings( \'iqfeed_symbols\', c( \'symbol_1\', ...,\'symbol_n\' ) ) ' )


  from_is_null = is.null( from )

  for( symbol in symbols ) {

    if( verbose ) message( symbol )
    if( from_is_null ) from = NULL

    dates_available = gsub( '.rds', '', list.files( paste( save_dir, symbol, sep = '/' ), pattern = '.rds' ) )
    if( is.null( from ) && length( dates_available ) == 0 ) {

      from = .settings$iqfeed_storage_from
      if( from == '' ) stop( 'please set iqfeed storage start date via QuantTools_settings( \'iqfeed_storage_from\', \'YYYYMMDD\' )' )
      message( 'not found in storage, \ntrying to download since storage start date' )

    }
    if( is.null( from ) && to >= max( dates_available ) ) {

      from = max( dates_available )
      message( paste( 'dates to be added:', from, '-', to ) )

    }
    curr_time = Sys.time()
    attr( curr_time, 'tzone' ) = 'America/New_York'
    if( format( curr_time, '%H:%M' ) %bw% c( '09:30', '16:00' ) && diff( as.Date( c( from, to ) ) ) > as.difftime( 3, units = 'days' ) ) {

      message = 'please download data outside trading hours [ 9:30 - 16:30 America/New York ]'
      if( length( dates_available ) == 0 ) {
        message( message )
        next
      } else {
        stop( message )
      }

    }

    ticks = get_iqfeed_data( symbol, from, to, period = 'tick' )
    if( is.null( ticks ) ) next

    dir.create( paste0( save_dir, '/' , symbol ), recursive = TRUE, showWarnings = FALSE )

    ticks[, date := format( time, '%Y-%m-%d' ) ]
    ticks[ , {

      saveRDS( .SD, file = paste0( save_dir, '/' , symbol, '/', date, '.rds' ) )

      if( verbose ) message( paste( date,  'saved' ) )

    }, by = date ]

  }

}

.get_local_data = function( symbol, from, to, source ) {

  data_dir = switch( source, Finam = .settings$finam_storage, iqfeed = .settings$iqfeed_storage )

  if( data_dir == '' ) stop( paste0('please set storage path via QuantTools_settings( \'', source, '_storage\', \'/storage/path/\' )
use store_', source, '_data to add some data into the storage' ) )

  dates_available = gsub( '.rds', '', list.files( paste( data_dir, symbol, sep = '/' ), pattern = '.rds' ) )

  dates_to_load = sort( dates_available[ dates_available %bw% c( from, to ) ] )

  data = vector( length( dates_to_load ), mode = 'list' )
  names( data ) = dates_to_load

  for( date in dates_to_load ) data[[ date ]] = readRDS( file = paste0( data_dir, '/' , symbol, '/', date, '.rds' ) )

  data = rbindlist( data )

  return( data )

}

