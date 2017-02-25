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

#' QuantTools settings
#'
#' @name settings
#' @param settings named list of settings values or settings names vector
#'
#'
#' @examples
#' \donttest{
#'
#' # list all settings
#' QuantTools_settings()
#'
#' # set defaults
#' QuantTools_settings_defaults()
#'
#' # change a setting
#' QuantTools_settings( list( iqfeed_verbose = TRUE ) )
#'
#' # To make R remember your settings please add the following code
#' # to .Rprofile file stored in your home directory path.expand('~'):
#'
#' suppressMessages( library( QuantTools ) )
#'
#' QuantTools_settings( settings = list(#'
#'   iqfeed_storage = paste( path.expand('~') , 'Market Data', 'iqfeed', sep = '/' ),
#'   iqfeed_symbols = c( 'AAPL', '@ES#' ),
#'   iqfeed_storage_from = format( Sys.Date() - 3 )
#' ) )
#'
#'}
#' @details
#' Controls package settings.
#'
#'
#' List of available settings:
#' \tabular{lll}{
#' finam_storage      \tab Finam local storage path        \cr
#' iqfeed_storage     \tab IQFeed local storage path       \cr
#' moex_storage       \tab MOEX local storage path         \cr
#' moex_data_url      \tab MOEX data url                   \cr
#' finam_storage_from \tab Finam storage first date        \cr
#' iqfeed_storage_from\tab IQFeed storage first date       \cr
#' moex_storage_from  \tab MOEX storage first date         \cr
#' finam_symbols      \tab Finam  symbols to store         \cr
#' iqfeed_symbols     \tab IQFeed symbols to store         \cr
#' iqfeed_port        \tab IQFeed historical port number   \cr
#' iqfeed_host        \tab IQFeed host                     \cr
#' iqfeed_timeout     \tab IQFeed connection timeout       \cr
#' iqfeed_buffer      \tab IQFeed number of bytes buffer   \cr
#' iqfeed_verbose     \tab IQFeed verbose internals?       \cr
#' temp_directory     \tab temporary directory location    \cr
#'}
#' @rdname settings
#' @export
QuantTools_settings = function( settings = NULL ){

  if( is.list( settings ) ) {

    if( is.null( names( settings ) ) ) next
    x = lapply( seq_along( settings ), function( i ) assign( names( settings )[i], settings[[i]], envir = .settings ) )

    return( message('') )
  }
  if( is.vector( settings, mode = 'character' ) ) {

    return( mget( settings, envir = .settings ) )

  }
  if( is.null( settings ) ) {

    return( mget( ls( envir = .settings ), envir = .settings ) )

  }
  stop( 'settings can be NULL, named list or character vector' )

}
#' @rdname settings
#' @export
QuantTools_settings_defaults = function() {

  .settings$finam_storage = paste( path.expand('~') , 'Market Data', 'finam', sep = '/' )
  .settings$iqfeed_storage = paste( path.expand('~') , 'Market Data', 'iqfeed', sep = '/' )
  .settings$moex_storage = paste( path.expand('~') , 'Market Data', 'moex', sep = '/' )
  .settings$temp_directory = paste( path.expand('~') , 'Market Data', 'temp', sep = '/' )

  .settings$moex_data_url = ''

  .settings$finam_storage_from = '2016-01-01'
  .settings$iqfeed_storage_from = '2016-01-01'
  .settings$moex_storage_from = '2003-01-01'


  .settings$iqfeed_port = 9100
  .settings$iqfeed_host = 'localhost'
  .settings$iqfeed_timeout = 1
  .settings$iqfeed_buffer = 600000
  .settings$iqfeed_verbose = FALSE
  .settings$finam_symbols = c( 'GAZP', 'SBER', 'LKOH', 'MGNT' )
  .settings$iqfeed_symbols = c( 'AAPL', 'XAUUSD.FXCM', '@ES#' )

}
.settings <- new.env()

QuantTools_settings_defaults()

