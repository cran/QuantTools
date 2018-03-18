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
#'
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
#' ## IQFeed data storage
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
#' ## MOEX data storage
#' settings = list(
#'   # set MOEX data url
#'   moex_data_url = 'url/to/moex/data',
#'   # set storage path, it is perfect to use Solid State Drive for data storage
#'   # it is no problem to move storage folder just don't forget to set new path in settings
#'   moex_storage = paste( path.expand('~') , 'Market Data', 'moex', sep = '/' ),
#'   # and set storage start date
#'   moex_storage_from = '2003-01-01'
#' )
#' QuantTools_settings( settings )
#' # now it is time to add some data into storage. You have three options here:
#'
#'   # 1 update storage with data from last date available until today
#'   # it is very convenient to create a script with this function and
#'   # run it every time you need to update your storage
#'   store_moex_data()
#'
#'   # 2 update storage with data from last date available until specified date
#'   store_moex_data( to = format( Sys.Date() ) )
#'
#'   # 3 update storage with data between from and to dates,
#'   # if data already present it will be overwritten
#'   store_moex_data( from = format( Sys.Date() - 3 ), to = format( Sys.Date() ) )
#'
#' # set local = TRUE to load from just created local market data storage
#' get_moex_futures_data( 'RIH9', '2009-01-01', '2009-02-01', 'tick', local = T )
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

    # ticks
    if( verbose ) message( 'ticks:' )

    dates_available = gsub( '.rds', '', list.files( paste( save_dir, symbol, sep = '/' ), pattern = '\\d{4}-\\d{2}-\\d{2}.rds' ) )
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

    # minutes
    if( verbose ) message( 'minutes:' )

    if( from_is_null ) from = NULL
    dates_available = gsub( '.rds', '-01', list.files( paste( save_dir, symbol, sep = '/' ), pattern = '\\d{4}-\\d{2}.rds' ) )
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
    to   = as.Date( to )

    data.table( from = as.Date( unique( format( seq( from, to, 1 ), '%Y-%m-01' ) ) ) )[, to := shift( from - 1, type = 'lead', fill = to ) ][, {

      month = format( from, '%Y-%m' )

      mins = get_finam_data( symbol, from, to, period = '1min' )

      if( !is.null( mins ) ) {

        dir.create( paste0( save_dir, '/' , symbol ), recursive = TRUE, showWarnings = FALSE )

        saveRDS( mins, file = paste0( save_dir, '/' , symbol, '/', month, '.rds' ) )

        if( verbose ) message( paste( month,  'saved' ) )

      } else {

        if( verbose ) message( paste( month,  'not available' ) )

      }

    }, by = from ]

  }

}
#' @rdname store_market_data
#' @export
# iqfeed
store_iqfeed_data = function( from = NULL, to = format( Sys.Date() ), verbose = TRUE ) {

  .store_iqfeed_data_mins ( from, to, verbose )
  .store_iqfeed_data_ticks( from, to, verbose )

}

.store_iqfeed_data_ticks = function( from = NULL, to = format( Sys.Date() ), verbose = TRUE ) {

  save_dir = .settings$iqfeed_storage
  symbols = .settings$iqfeed_symbols

  if( save_dir == '' ) stop( 'please set storage path via QuantTools_settings( \'iqfeed_storage\', \'/storage/path/\' ) ' )
  if( is.null( symbols ) ) stop( 'please set symbols vector via QuantTools_settings( \'iqfeed_symbols\', c( \'symbol_1\', ...,\'symbol_n\' ) ) ' )


  from_is_null = is.null( from )

  for( symbol in symbols ) {

    if( verbose ) message( symbol )
    if( from_is_null ) from = NULL

    dates_available = gsub( '.rds', '', list.files( paste( save_dir, symbol, sep = '/' ), pattern = '\\d{4}-\\d{2}-\\d{2}.rds' ) )
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
    if( !is.null( ticks ) ) {

      dir.create( paste0( save_dir, '/' , symbol ), recursive = TRUE, showWarnings = FALSE )

      time = NULL
      ticks[, date := format( time, '%Y-%m-%d' ) ]
      ticks[ , {

        saveRDS( .SD, file = paste0( save_dir, '/' , symbol, '/', date, '.rds' ) )

        if( verbose ) message( paste( date,  'saved' ) )

      }, by = date ]

    }

  }

}

.store_iqfeed_data_mins =  function( from = NULL, to = format( Sys.Date() ), verbose = TRUE ) {

  save_dir = .settings$iqfeed_storage
  symbols = .settings$iqfeed_symbols

  if( save_dir == '' ) stop( 'please set storage path via QuantTools_settings( \'iqfeed_storage\', \'/storage/path/\' ) ' )
  if( is.null( symbols ) ) stop( 'please set symbols vector via QuantTools_settings( \'iqfeed_symbols\', c( \'symbol_1\', ...,\'symbol_n\' ) ) ' )


  from_is_null = is.null( from )

  for( symbol in symbols ) {

    if( verbose ) message( symbol )
    if( from_is_null ) from = NULL

    months_available = gsub( '.rds', '', list.files( paste( save_dir, symbol, sep = '/' ), pattern = '\\d{4}-\\d{2}.rds' ) )
    if( is.null( from ) && length( months_available ) == 0 ) {

      from = .settings$iqfeed_storage_from
      if( from == '' ) stop( 'please set iqfeed storage start date via QuantTools_settings( \'iqfeed_storage_from\', \'YYYYMMDD\' )' )
      message( 'not found in storage, \ntrying to download since storage start date' )

    }
    if( is.null( from ) && substr( to, 1, 7 ) >= max( months_available ) ) {

      from = max( months_available )
      message( paste( 'months to be added:', from, '-', substr( to, 1, 7 ) ) )

    }

    mins = get_iqfeed_data( symbol, paste0( substr( from, 1, 7 ), '-01' ), format( as.Date( to ) + 31 ), period = '1min' )
    if( !is.null( mins ) && nrow( mins ) != 0 ) {

      dir.create( paste0( save_dir, '/' , symbol ), recursive = TRUE, showWarnings = FALSE )

      time = NULL
      mins[, month := format( time, '%Y-%m' ) ]
      mins[ , {

        saveRDS( .SD, file = paste0( save_dir, '/' , symbol, '/', month, '.rds' ) )

        if( verbose ) message( paste( month,  'saved' ) )

      }, by = month ]

    }

  }

}

.get_local_data = function( symbol, from, to, source, period ) {

  data_dir = switch( source, finam = .settings$finam_storage, iqfeed = .settings$iqfeed_storage )

  if( data_dir == '' ) stop( paste0('please set storage path via QuantTools_settings( \'', source, '_storage\', \'/storage/path/\' )
  use store_', source, '_data to add some data into the storage' ) )

  if( period == 'tick' ) {

    dates_available = gsub( '.rds', '', list.files( paste( data_dir, symbol, sep = '/' ), pattern = '\\d{4}-\\d{2}-\\d{2}.rds' ) )

    dates_to_load = sort( dates_available[ dates_available %bw% substr( c( from, to ), 1, 10 ) ] )

    data = vector( length( dates_to_load ), mode = 'list' )
    names( data ) = dates_to_load

    for( date in dates_to_load ) data[[ date ]] = readRDS( file = paste0( data_dir, '/' , symbol, '/', date, '.rds' ) )

    data = rbindlist( data )

    time_range = as.POSIXct( format( as.Date( c( from, to ) ) + c( 0, 1 ) ), 'UTC' )

    time = NULL
    if( !is.null( data ) ) data = data[ time > time_range[1] & time < time_range[2] ]

    return( data )

  }
  if( period == '1min' ) {

    months_available = gsub( '.rds', '', list.files( paste( data_dir, symbol, sep = '/' ), pattern = '\\d{4}-\\d{2}.rds' ) )

    months_to_load = sort( months_available[ months_available %bw% substr( c( from, to ), 1, 7 ) ] )

    if( length( months_to_load ) == 0 ) return( NULL )
    data = vector( length( months_to_load ), mode = 'list' )
    names( data ) = months_to_load

    for( month in months_to_load ) data[[ month ]] = readRDS( file = paste0( data_dir, '/' , symbol, '/', month, '.rds' ) )

    data = rbindlist( data )#[ as.Date( time ) %bw% as.Date( c( from, to ) )  ]

    time_range = as.POSIXct( format( as.Date( c( from, to ) ) + c( 0, 1 ) ), 'UTC' )

    time = NULL
    if( !is.null( data ) ) data = data[ time > time_range[1] & time < time_range[2] ]

    return( data )

  }

}
#' @rdname store_market_data
#' @export
# moex
store_moex_data = function( from = NULL, to = format( Sys.Date() ), verbose = TRUE ) {

  save_dir = .settings$moex_storage
  if( save_dir == '' ) stop( 'please set storage path via QuantTools_settings( \'moex_storage\', \'/storage/path/\' ) ' )
  temp_dir = .settings$temp_directory
  if( temp_dir == '' ) stop( 'please set temp directory path via QuantTools_settings( \'temp_directory_\', \'/temp/directory/path/\' ) ' )

  from_is_null = is.null( from )
  if( from_is_null ) from = NULL

  dates_available = gsub( '.rds', '', list.files( paste0( save_dir, '/futures/' ), pattern = '.rds' ) )
  if( is.null( from ) && length( dates_available ) == 0 ) {

    from = .settings$moex_storage_from
    if( from == '' ) stop( 'please set moex storage start date via QuantTools_settings( \'moex_storage_from\', \'YYYYMMDD\' )' )
    message( 'no data found in storage, \ntrying to download since storage start date' )

  }
  if( is.null( from ) && to >= max( dates_available ) ) {

    from = max( dates_available )
    message( paste( 'dates to be added:', from, '-', to ) )

  }

  for( date in as.Date( from ):as.Date( to ) ) {

    date = as.Date( date, origin = '1970-01-01' )

    dir_fut = paste0( save_dir, '/futures' )
    dir_opt = paste0( save_dir, '/options' )
    dir.create( dir_fut, recursive = T, showWarnings = F )
    dir.create( dir_opt, recursive = T, showWarnings = F )

    file_fut = paste0( dir_fut, '/', format( date ), '.rds' )
    file_opt = paste0( dir_opt, '/', format( date ), '.rds' )

    year = format( date, '%Y' )
    yymmdd = format( date, '%y%m%d')


    data_url = .settings$moex_data_url

    if( !RCurl::url.exists( data_url ) ) stop( 'please set MOEX data url via QuantTools_settings( \'moex_data_url\', \'/moe/data/url/\' )' )

    url = paste0( data_url, '/', year, '/FT', yymmdd, '.ZIP')

    if( !RCurl::url.exists( url ) ) next
    file_zip = paste0( temp_dir, '/', yymmdd, '.zip' )


    unlink( list.files( temp_dir, full.names = T ), force = T, recursive = T )
    dir.create( temp_dir, recursive = T, showWarnings = F )

    download.file( url, destfile = file_zip, mode = 'wb', quiet = T )

    unzip( file_zip, exdir = temp_dir )
    #cmd = paste0( '7z x "', file_zip, '" -o"', temp_dir, '"' )
    #shell( cmd, wait = T )

    files = list.files( temp_dir, pattern = 'ft|ot|FT|OT', recursive = T, full.names = T )

    ft = files[ grepl( 'ft', tolower( files ) ) ]
    ot = files[ grepl( 'ot', tolower( files ) ) ]

    is_xls = grepl( '.xls', tolower( ft ) )

    format_trades = function( trades ) {

      code = contract = dat_time = NULL
      trades[, code := as.factor( code ) ]
      trades[, contract := as.factor( contract ) ]
      trades[, dat_time := fasttime::fastPOSIXct( dat_time, 'UTC' ) ]

    }

    if( is_xls ) {

      . = capture.output( { sheets = readxl::excel_sheets( ft ) } )
      fut_sheet = sheets[ grepl( 'fut.*trade', sheets ) ]
      opt_sheet = sheets[ grepl( 'opt.*trade', sheets ) ]

      if( is.na( fut_sheet ) ) {

        message( 'no futures trades sheet available' )

      } else {

        . = capture.output( { trades = setDT( readxl::read_excel( ft, sheet = fut_sheet ) ) } )

        format_trades( trades )
        saveRDS( trades, file_fut )

      }

      if( is.na( opt_sheet ) ) {

        message( 'no options trades sheet available' )

      } else {

        . = capture.output( { trades = setDT( readxl::read_excel( ft, sheet = opt_sheet ) ) } )

        format_trades( trades )
        saveRDS( trades, file_opt )

      }

      if( verbose ) message( date, ' saved' )

    } else {

      if( is.null( ft ) ) {

        message( 'no futures trades file available' )

      } else {

        trades = fread( ft )

        format_trades( trades )
        saveRDS( trades, file_fut )

      }

      if( is.null( ot ) ) {

        message( 'no options trades file available' )

      } else {

        if( date == as.Date( '2008-09-15' ) ) next ## embeded nul

        trades = fread( ot )

        format_trades( trades )
        saveRDS( trades, file = file_opt )

      }

      if( verbose ) message( date, ' saved' )

    }

  }

}
