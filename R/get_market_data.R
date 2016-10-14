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

#' Download historical market data
#' @title Download historical market data
#' @param symbol symbol name
#' @param from,to text dates in format \code{"YYYY-mm-dd"}
#' @param period candle period \code{tick, 1min, 5min, 10min, 15min, 30min, hour, day, week, month}
#' @param split.adjusted should data be split adjusted?
#' @param local should data be loaded from local storage? Only 'tick' period supported for local storage. See 'Details' section
#' @name get_market_data
#' @details
#' Use external websites to get desired symbol name for
#' \href{http://www.finam.ru/profile/moex-akcii/sberbank/export/}{Finam},
#' \href{http://www.iqfeed.net/symbolguide/index.cfm?symbolguide=lookup}{IQFeed},
#' \href{http://finance.yahoo.com/}{Yahoo} and
#' \href{https://www.google.com/finance}{Google} sources. \cr
#' Note: Timestamps timezones set to UTC. \cr
#' It is recommended to store tick market data locally.
#' Load time is reduced dramatically. It is a good way to collect market data as
#' e.g. IQFeed gives only 180 days of tick data if you would need more it will
#' cost you a lot. See \code{\link{store_market_data}} for details. \cr
#' See \link{iqfeed} return format specification.
#'
#' @examples
#' \donttest{
#' get_finam_data( 'GAZP', '2015-01-01', '2016-01-01' )
#' get_finam_data( 'GAZP', '2015-01-01', '2016-01-01', 'hour' )
#' get_finam_data( 'GAZP', Sys.Date(), Sys.Date(), 'tick' )
#'
#' get_iqfeed_data( 'MSFT', '2015-01-01', '2016-01-01' )
#' get_iqfeed_data( 'MSFT', '2015-01-01', '2016-01-01', 'hour' )
#' get_iqfeed_data( 'MSFT', Sys.Date() - 3, Sys.Date() , 'tick' )
#'
#' get_google_data( 'MSFT', '2015-01-01', '2016-01-01' )
#' get_yahoo_data( 'MSFT', '2015-01-01', '2016-01-01' )
#'
#' }
# split character date into desired parts
NULL
.extract_date_parts = function( date, what = c( '%m', '%d', '%Y' ) ) {
  extract_date_part = function( date, what ) {

    # date = '2014-06-01'
    # what = '%m'
    as_text = format( as.Date( date ), what )
    as_numeric = as.numeric( as_text )
    return( as_numeric )

  }
  parts = sapply( what, extract_date_part, date = date  )
  names( parts ) = gsub( '%', '', names( parts ) )
  return( parts )

}
# download market data from Yahoo server
#' @rdname get_market_data
#' @export
get_yahoo_data = function( symbol, from, to, split.adjusted = TRUE ) {

  splits = get_yahoo_splits_and_dividends( symbol, from, to )
  # split dates into parts
  from = .extract_date_parts( from )
  to = .extract_date_parts( to )
  # construct download url
  url = paste0(
    'http://real-chart.finance.yahoo.com/table.csv?s=',
    symbol,'&a=',
    from[['m']] - 1, '&b=', from[['d']], '&c=', from[['Y']],'&d=',
    to[['m']]  - 1, '&e=', to[['d']] ,'&f=', to[['Y']] , '&g=d&ignore=.csv'
  )
  # download data silently
  options( warn = -1 )
  dat = NULL
  try( { dat = fread( url, showProgress = FALSE ) }, silent = T )
  options( warn = 0 )

  if( is.null( dat ) ) return( dat )
  # change names
  setnames( dat, tolower( names( dat ) ) )
  # change date format
  dat[, date := as.Date( date ) ]
  # set key for later use
  setkey( dat, date )

  if( split.adjusted ) {

    . = split_date = split_coeff = event = value = open = high = low = close = NULL
    dat[ , split_coeff := 1 ]

    if( is.null( splits ) ) return( dat[] )

    splits = splits[ event == 'SPLIT', .( split_date = date, split = value ) ]
    if( nrow( splits ) == 0 ) return( dat )

    splits[ , dat[ date < split_date, split_coeff := split_coeff * split ][ NULL ], by = 1:nrow( splits ) ]
    dat[ , ':='( open = open / split_coeff, high = high / split_coeff, low = low / split_coeff, close = close / split_coeff ) ]

  }

  # return downloaded data
  return( dat[] )

}
#' @rdname get_market_data
#' @export
get_yahoo_splits_and_dividends = function( symbol, from, to = from ) {

  # split dates into parts
  from = .extract_date_parts( from )
  to = .extract_date_parts( to )
  # construct download url
  url = paste0(
    'http://ichart.finance.yahoo.com/x?s=',
    symbol,'&a=',
    from[['m']] - 1, '&b=', from[['d']], '&c=', from[['Y']],'&d=',
    to[['m']]  - 1, '&e=', to[['d']] ,'&f=', to[['Y']] , '&g=v&y=0&z=30000'
  )
  # download data silently
  options( warn = -1 )

  dat = NULL
  try( { dat = read.delim( url, sep = ',', header = F, col.names = c( 'event', 'date', 'value' ) ); setDT( dat ) }, silent = T )
  if( is.null( dat ) ) return( dat )
  dat = dat[ apply( dat, 1, function( x ) !any( x == '' ) ) ]
  value = date = NULL

  dat[, value := sapply( parse( text = gsub( ':', '/', value ) ), eval ) ]
  dat[,  date := as.Date( date, '%Y%m%d' ) ]

  options( warn = 0 )
  # return downloaded data
  return( dat[] )

}
# download market data from Google server
#' @rdname get_market_data
#' @export
get_google_data = function( symbol, from, to = from ){

  from = as.Date( from )
  to = as.Date( to )

  url = paste0( 'http://finance.google.com/finance/historical?', 'q=', symbol,
                '&startdate=', format( from, '%b' ), '+', format( from, '%d' ), ',+', format( from, '%Y' ),
                '&enddate=', format( to, '%b' ), '+',format( to, '%d' ), ',+',format( to, '%Y' ), '&output=csv' )

  suppressWarnings( { x = fread( url, showProgress = FALSE ) } )
  setnames( x, c( 'date', 'open', 'high', 'low', 'close', 'volume' ) )
  if( x[, .N == 0 ] ) return( NULL )
  x[ , date := as.Date( date, '%d-%b-%y' ) ][ .N:1 ][]

}
# download market data from Finam server
finam_downloader_env <- new.env()
#' @rdname get_market_data
#' @export
get_finam_data = function( symbol, from, to = from, period = 'day', local = FALSE ) {

  if( local ){

    if( period != 'tick' ) stop( 'only ticks supported in local storage' )

    data = .get_local_data(  symbol, from, to, source = 'finam' )

    return( data )

  }
  # Finam host address
  host = '195.128.78.52'
  # referer to successfully download data from Finam server
  referer = 'http://www.finam.ru/analysis/profile041CA00007/default.asp'
  # urls of Finam instruments information files
  source_urls = c( 'http://www.finam.ru/scripts/export.js', 'http://www.finam.ru/cache/icharts/icharts.js' )
  # download available instruments info
  is_instruments_info_present_in_system = exists( 'instruments_info', envir = finam_downloader_env )
  #is_instruments_info_present_in_system = exists( 'finam_downloader_env', mode = 'environment' )
  if( !is_instruments_info_present_in_system ) {
    # define function to download available instruments information from Finam server
    get_finam_instruments_info = function( source_url ) {

      # source_url = 'http://www.finam.ru/cache/icharts/icharts.js'
      # source_url = 'http://www.finam.ru/scripts/export.js'

      # read file from url
      con <- file( source_url, 'r', blocking = FALSE )
      raw_lines <- readLines( con )
      close( con )
      # define function to extract data between brackets in text line
      extract_data_between_brackets = function( text_line ){
        # substitute everything before and after brackets with ''
        brackets = '.*\\s\\[|\\];.*|.*\\s\\(|\\);.*'
        csv = gsub( brackets , '', text_line )
        # read csv into vector
        x = strsplit( csv, ',', fixed = TRUE )[[1]]
        return( x )
      }

      needed_variables_names = c( 'aEmitentIds', 'aEmitentCodes', 'aEmitentMarkets' )
      # get index of lines of interest
      needed_lines = sapply( needed_variables_names, function( x ) which( grepl( x, raw_lines, fixed = TRUE ) ) )
      # extract data of lines of interes
      instruments_info = lapply( raw_lines[ needed_lines ], extract_data_between_brackets )
      # convert these data into data.table
      instruments_info = data.table::as.data.table( instruments_info )
      # set column names of extracted data
      data.table::setnames( instruments_info, needed_variables_names )
      instruments_info[ , aEmitentCodes := gsub( "'", '', aEmitentCodes, fixed = TRUE ) ]
      # return instruments information
      return( instruments_info )

    }
    aEmitentCodes = aEmitentMarkets = NULL
    # get instruments info from multiple sources
    instruments_info = lapply( source_urls, get_finam_instruments_info )
    # combine results into one table
    instruments_info = data.table::rbindlist( instruments_info )
    # remove duplicated entries
    instruments_info = unique( instruments_info )[ order( aEmitentCodes, aEmitentMarkets ) ]

    assign( 'instruments_info', instruments_info, envir = finam_downloader_env )

    # show message to inform user that next time data will not be downloaded again
    #message( 'all instruments info data downloaded and will be reused next time' )
  }
  # file name to be used in get query url
  file_name <- paste( symbol, format( as.Date( from ), '%Y%m%d' ), format( as.Date( to ), '%Y%m%d' ), period, sep = '_' )
  # split dates into parts
  from = .extract_date_parts( from )
  to = .extract_date_parts( to )
  # find information about desired symbol
  instrument_info = get( 'instruments_info', envir = finam_downloader_env )[ aEmitentCodes == symbol ][ 1 ]
  # throw absent instrument exception
  is_instrument_info_empty = instrument_info[, .N == 0 ]
  error_message = paste( symbol, 'not available on Finam server' )
  if( is_instrument_info_empty ) stop( error_message )

  url_parameters = data.table::data.table(
    fsp = 0, # fill periods without deals 0 - no, 1 - yes
    market = instrument_info[[ 'aEmitentMarkets' ]], # market code
    em = instrument_info[[ 'aEmitentIds' ]], # emitent code
    code = symbol, # ticker
    df = from[[ 'd' ]], # date from
    mf = from[[ 'm' ]] - 1,
    yf = from[[ 'Y' ]],
    dt = to[[ 'd' ]], # date to
    mt = to[[ 'm' ]] - 1,
    yt = to[[ 'Y' ]],
    p  = switch( period, "tick" = 1, "1min" = 2, "5min" = 3, "10min" = 4, "15min" = 5, "30min" = 6, "hour" = 7, "day" = 8 ), # period
    f = file_name, # file name
    e = '.txt', # file extention	.txt or .csv
    cn = symbol, # ticker
    dtf = 1, # date format
    tmf = 3, # time format
    MSOR = 0, # cnadle time 0 - candle start,1 - candle end
    mstimever = 0,
    sep = 1, # column separator    1 - ",", 2 - ".", 3 - ";", 4 - "<tab>", 5 - " "
    sep2 = 1, # thousands separator 1 - "" , 2 - ".", 3 - ",", 4 - " "    , 5 - "'"
    datf = switch( period, tick = 9, 5 ), # candle format
    at = 1 # header	0 - no, 1 - yes
  )
  # create get query url
  get_url = paste( paste0( 'http://', host, '/', file_name, '.txt' ), paste( names( url_parameters ), url_parameters, sep = '=', collapse = '&' ), sep = '?' )
  # download data
  downloaded_data = RCurl::getURL( get_url, Referer = referer )
  # empty data exception
  is_downloaded_data_present = grepl( ',', substr( downloaded_data, 1, 1000 ), fixed = TRUE )
  text_message = paste( symbol, 'no data available' )
  if( !is_downloaded_data_present ) {
    return( NULL )
  }
  # parse data as data.table
  column_names = unlist( strsplit( substr( downloaded_data, 1, 100 ), split = '<|>,<|>' ) )
  column_names = column_names[ -c( 1, length( column_names ) ) ]
  column_names = tolower( column_names )
  column_classes = rep( 'numeric', length( column_names ) )
  column_classes[ column_names %in% c( 'date', 'time' ) ] = 'character'

  downloaded_data = data.table::fread( downloaded_data, col.names = column_names, colClasses = column_classes )
  # convert date time
  # if period is greater or equal to day
  if( period %in% c( "day", "week", "month" ) ) {
    # date format is Date
    downloaded_data[ , ':='( date = as.Date( as.character( date ), format = '%Y%m%d' ), time = NULL ) ]
    setnames( downloaded_data, c( 'date', 'open', 'high', 'low', 'close', 'volume' ) )
    # set key for later use
    setkey( downloaded_data, date )

  } else {
    # else date column format is POSIXct timestamp
    downloaded_data[ , ':='( time = fasttime::fastPOSIXct( paste( substr( date, 1, 4 ), substr( date, 5, 6 ), substr( date, 7, 8 ), time ), 'UTC' ), date = NULL ) ]
    if( period != 'tick' ) { setnames( downloaded_data, c( 'time', 'open', 'high', 'low', 'close', 'volume' ) ) } else
      { setnames( downloaded_data, c( 'time', 'price', 'volume' ) ) }
    # set key for later use
    setkey( downloaded_data, time )
  }
  # return downloaded data
  return( downloaded_data[] )

}
#' @rdname get_market_data
#' @export
get_iqfeed_data = function( symbol, from, to = from, period = 'day', local = FALSE ) {

  if( local ){

    if( period != 'tick' ) stop( 'only ticks supported in local storage' )

    data = .get_local_data(  symbol, from, to, source = 'iqfeed' )

    return( data )

  }

  data = switch( period,
          'tick'  = .get_iqfeed_ticks( symbol, from, to ),
          'day'   = .get_iqfeed_daily_candles( symbol, from, to ),
          '1min'  = .get_iqfeed_candles( symbol, from, to, interval = 60 *  1 ),
          '5min'  = .get_iqfeed_candles( symbol, from, to, interval = 60 *  5 ),
          '10min' = .get_iqfeed_candles( symbol, from, to, interval = 60 * 10 ),
          '15min' = .get_iqfeed_candles( symbol, from, to, interval = 60 * 15 ),
          '30min' = .get_iqfeed_candles( symbol, from, to, interval = 60 * 30 ),
          'hour'  = .get_iqfeed_candles( symbol, from, to, interval = 60 * 60 )

          )
  return( data )

}

