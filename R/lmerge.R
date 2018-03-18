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

#' Merge list of data.frames into data.table by key column
#'
#' @param x named list of data.frames
#' @param key column name to merge by
#' @param value column name of value variable
#' @param na.omit should leading NA values be omitted?
#' @examples
#' \donttest{
#' from = '1990-01-01'
#' to = '2016-08-30'
#'
#' symbols = fread( '
#'                symbol, comment
#'                EFA, iShares MSCI EAFE Index Fund
#'                VTI, Vanguard Total Stock Market
#'                TLT, iShares 20+ Year Treasury Bond
#'                RWX, SPDR Dow Jones International RelEst
#'                IEV, iShares Europe
#'                IEF, iShares 7-10 Year Treasury Bond
#'                ICF, iShares Cohen & Steers Realty Maj.
#'                GLD, SPDR Gold Shares
#'                EWJ, iShares MSCI Japan
#'                EEM, iShares MSCI Emerging Markets
#'                DBC, PowerShares DB Commodity Tracking' )
#'
#' # download historical market data
#' prices_list = lapply_named( symbols$'symbol', get_yahoo_data, from, to )
#'
#' # table of close prices
#' prices = lmerge( prices_list, 'date' , 'close' )
#'
#' # calculate returns and performance
#' dates = prices[, date ]
#' prices[, date := NULL ]
#' returns = lapply( prices, returns ) %>% setDT
#' performance = lapply( returns + 1, cumprod ) %>% setDT
#'
#' # plot historical values
#' plot_ts( data.table( dates, returns ), legend = 'topleft' )
#' plot_ts( data.table( dates, prices ), legend = 'topleft' )
#' plot_ts( data.table( dates, performance ), legend = 'topleft' )
#'
#' }
#' @name lmerge
#' @export
lmerge = function( x, key, value, na.omit = T ){

  x = copy( x )
  x = Filter( Negate( is.null ), x )

  . = NULL

  x = lapply( seq_along( x ), function( i ) {

    setnames( setDT( x[[i]] ), c( key, value ), c( 'key', 'value' ) )
    x[[i]][ , .( key, value, name = names( x )[i] ) ]

  } )
  x = rbindlist( x )
  x = dcast( x, key ~ name, value.var = 'value' )
  x = na_locf( x )
  setDT( x )
  setnames( x, 'key', key )

  if( na.omit ) return( na.omit( x ) ) else return( x )

}
