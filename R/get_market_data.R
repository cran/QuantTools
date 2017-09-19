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
#'
#' @param symbol symbol name
#' @param from,to text dates in format \code{"YYYY-mm-dd"}
#' @param period candle period \code{tick, 1min, 5min, 10min, 15min, 30min, hour, day, week, month}
#' @param split.adjusted should data be split adjusted?
#' @param local should data be loaded from local storage? See 'Details' section
#' @param code futures or option code name, e.g. \code{"RIU6"}
#' @param contract,frequency,day_exp same as in \code{\link{gen_futures_codes}}
#' @name get_market_data
#' @details Use external websites to get desired symbol name for
#' \href{https://www.finam.ru/profile/moex-akcii/sberbank/export/}{Finam},
#' \href{https://www.moex.com/en/derivatives/contracts.aspx}{MOEX},
#' \href{https://www.iqfeed.net/symbolguide/index.cfm?symbolguide=lookup}{IQFeed},
#' \href{https://finance.yahoo.com/}{Yahoo} and
#' \href{https://www.google.com/finance}{Google} sources. \cr
#' Note: Timestamps timezones set to UTC. \cr
#' It is recommended to store tick market data locally.
#' Load time is reduced dramatically. It is a good way to collect market data as
#' e.g. IQFeed gives only 180 days of tick data if you would need more it will
#' cost you a lot. See \code{\link{store_market_data}} for details. \cr
#' See \link{iqfeed} return format specification. \cr
#' MOEX data can be retrieved from local storage only in order to minimize load on MOEX data servers. Read \code{\link{store_market_data}} for information on how to store data locally. \cr
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
#' get_moex_futures_data( 'RIH9', '2009-01-01', '2009-02-01', 'tick', local = T )
#' get_moex_options_data( 'RI55000C9', '2009-01-01', '2009-02-01', 'tick', local = T )
#' get_moex_continuous_futures_data( 'RI', '2016-01-01', '2016-11-01', frequency = 3, day_exp = 15 )
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

yahoo_downloader_env <- new.env()

.get_yahoo_curl = function() {
  curl = RCurl::getCurlHandle( cookiejar = '' )
  html = RCurl::getURL( 'https://finance.yahoo.com/quote/AAPL', curl = curl )
  crumb = gsub( '^.*crumb":"\\s*|".*', '', html )
  assign( 'crumb', crumb, envir = yahoo_downloader_env )
  assign( 'curl' , curl , envir = yahoo_downloader_env )
}

.get_yahoo_data = function( symbol, from, to, events ) {

  if( is.null( yahoo_downloader_env$crumb ) ) .get_yahoo_curl()
  url = paste0( 'https://query1.finance.yahoo.com/v7/finance/download/', symbol,
                '?period1=', as.numeric( as.POSIXct( from ) ),
                '&period2=', as.numeric( as.POSIXct( to ) ),
                '&interval=1d&events=', events, '&crumb=', yahoo_downloader_env$crumb )
  x = RCurl::getURL( url, curl = yahoo_downloader_env$curl )
  if( x == '' | grepl( 'Not Found|Bad Request', x ) ) return( NULL )
  if( grepl( 'Invalid cookie', x, fixed = T ) ) {
    .get_yahoo_curl()
    .get_yahoo_data( symbol, from, to, events )
  }
  x = gsub( 'null', '', x, fixed = T )
  x = fread( x )
  setnames( x, tolower( gsub( ' ', '_', names( x ) ) ) )
  . = stock_splits = date = NULL
  if( events == 'split' ) x[, stock_splits := sapply( parse( text = stock_splits ), eval ) ]
  x[, date := as.Date( date ) ]
  x[]

}

# download market data from Yahoo server
#' @rdname get_market_data
#' @export
get_yahoo_data = function( symbol, from, to, split.adjusted = TRUE ) {

  splits = .get_yahoo_data( symbol, from, to, events = 'split' )

  dat = .get_yahoo_data( symbol, from, to, events = 'history' )

  if( is.null( dat ) || nrow( dat ) == 0 ) return( dat )

  # return downloaded data
  return( dat[] )

}
#' @rdname get_market_data
#' @export
get_yahoo_splits_and_dividends = function( symbol, from, to = from ) {

  curr_date = format( Sys.Date() )
  if( from > curr_date ) from = to = curr_date
  if( to   > curr_date ) to = curr_date

  data      = .get_yahoo_data( symbol, from, to, events = 'history' )
  if( is.null( data ) ) return( NULL )
  dividends = .get_yahoo_data( symbol, from, to, events = 'div'     )
  splits    = .get_yahoo_data( symbol, from, to, events = 'split'   )

  . = event = NULL
  splits   [, event := rep( 'split'    , .N ) ]
  dividends[, event := rep( 'dividends', .N ) ]

  names = c( 'date', 'value', 'event' )
  setnames( splits   , names )
  setnames( dividends, names )

  rbind( splits, dividends )[ order( date ) ]

}

# download market data from Google server
#' @rdname get_market_data
#' @export
get_google_data = function( symbol, from, to = from ){

  curr_date = format( Sys.Date() )
  if( from > curr_date ) from = to = curr_date
  if( to   > curr_date ) to = curr_date

  from = as.Date( from )
  to = as.Date( to )

  url = paste0( 'https://finance.google.com/finance/historical?', 'q=', symbol,
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

    data = .get_local_data(  symbol, from, to, source = 'finam', period )

    return( data )

  }

  curr_date = format( Sys.Date() )
  if( from > curr_date ) from = to = curr_date
  if( to   > curr_date ) to = curr_date

  # Finam host address
  host = 'export.finam.ru'
  # referer to successfully download data from Finam server
  referer = 'https://www.finam.ru/analysis/profile041CA00007/default.asp'
  # urls of Finam instruments information files
  source_urls = c( 'https://www.finam.ru/scripts/export.js', 'https://www.finam.ru/cache/icharts/icharts.js' )
  # download available instruments info
  is_instruments_info_present_in_system = exists( 'instruments_info', envir = finam_downloader_env )
  #is_instruments_info_present_in_system = exists( 'finam_downloader_env', mode = 'environment' )
  if( !is_instruments_info_present_in_system ) {
    # define function to download available instruments information from Finam server
    get_finam_instruments_info = function( source_url ) {

      # source_url = 'https://www.finam.ru/cache/icharts/icharts.js'
      # source_url = 'https://www.finam.ru/scripts/export.js'

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
    MSOR = 1, # candle time 0 - candle start,1 - candle end
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

  curr_date = format( Sys.Date() )
  if( from > curr_date ) from = to = curr_date
  #if( to   > curr_date ) to = curr_date

  if( local ){

    if( period == 'tick' ) data = .get_local_data(  symbol, from, to, source = 'iqfeed', period = 'tick' )
    if( period != 'tick' ) {

      data = .get_local_data(  symbol, from, to, source = 'iqfeed', period = '1min' )
      if( is.null( data ) ) return( NULL )

      switch( period,
              '1min'  = { n =  1; units = 'mins' },
              '5min'  = { n =  5; units = 'mins' },
              '10min' = { n = 10; units = 'mins' },
              '15min' = { n = 15; units = 'mins' },
              '30min' = { n = 30; units = 'mins' },
              'hour'  = { n =  1; units = 'hour' },
              'day'   = { n =  1; units = 'days' }
      )

      open = high = low = close = volume = NULL
      data = data[ , list( open = open[1], high = max( high ), low = min( low ), close = close[.N], volume = sum( volume ) ), by = list( time = ceiling_POSIXct( time, n, units ) ) ]
      if( period == 'day' ) {

        data[, time := as.Date( time ) - 1 ]
        setnames( data, 'time', 'date' )


      }

    }

    return( data[] )

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
#' @rdname get_market_data
#' @export
get_moex_options_data = function( code, from, to = from, period = 'tick', local = TRUE ) {

  .get_moex_data( code = code, from = from, to = to, period = period, local = local, type = 'options' )

}
#' @rdname get_market_data
#' @export
get_moex_futures_data = function( code, from, to = from, period = 'tick', local = TRUE ) {

  .get_moex_data( code = code, from = from, to = to, period = period, local = local, type = 'futures' )

}
#' @rdname get_market_data
#' @export
get_moex_continuous_futures_data = function( contract, from, to, frequency, day_exp ) {

  schedule = gen_futures_codes( contract, from, to, frequency, day_exp, year_last_digit = T )

  trades = schedule[, get_moex_futures_data( code, from, to ), by = contract_id ][]
  setcolorder( trades, c( 'time', 'price', 'volume', 'id', 'contract_id' )  )
  code = contract_id = NULL
  trades[, code := schedule$code[ contract_id ] ][]
  gc()
  return( trades )

}

.get_moex_data = function( code, from, to = from, period = 'tick', local = TRUE, type = c( 'options', 'futures' ) ) {

  if( period != 'tick' ) stop( 'only \'tick\' data supported' )
  if( !local ) stop( 'only \'local = TRUE\' flag supported' )
  type = match.arg( type )

  dir_data = paste0( .settings$moex_storage, '/', type, '/' )

  files = list.files( dir_data, pattern = '.rds', full.names = T )
  dates = gsub( '.*/|\\..*', '', files )

  data = vector( length( dates[ from <= dates & dates <= to ] ), mode = 'list' )
  i = 1

  for( file in files[ from <= dates & dates <= to ] ) {

    code_ = code

    dat_time = price = amount = NULL

    Nosystem = 0
    data[[ i ]] = readRDS( file )[ code == code_ & Nosystem != 1, list( time = dat_time, price, volume = as.integer( amount ), id = 1:.N ) ]

    i = i + 1

  }

  data = rbindlist( data, use.names = T, fill = T )[]
  gc()
  return( data )

}
