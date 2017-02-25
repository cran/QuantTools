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

#' Combine multiple futures market data into continuous contract
#'
#' @param prices_by_contract list of data.tables with futures market data
#' @param days_before_expiry number of dates before expiration to roll
#' @export
roll_futures = function( prices_by_contract, days_before_expiry ){

  #http://www.investopedia.com/university/intermediate-guide-to-trading-e-mini-futures/rollover-dates-and-expiration.asp

  prices_by_contract = Filter( Negate( is.null ), prices_by_contract )
  n = length( prices_by_contract )

  id = NULL
  switch( names( prices_by_contract[[1]] )[1] ,
    date = {
      expiration_dates = unlist( lapply( prices_by_contract, '[', .N, date ) )
      rollover_dates = expiration_dates - days_before_expiry
      rollover_dates[n] = expiration_dates[n]
      rollover_dates = c( as.Date( 0 ), rollover_dates )
      rollover = lapply( 1:n, function( i ) prices_by_contract[[i]][ rollover_dates[i] < date & date <= rollover_dates[i+1] ][ , id := i ] )

    },
    time = {
      expiration_dates = unlist( lapply( prices_by_contract, '[', .N, time ) )
      rollover_dates = expiration_dates - as.difftime( days_before_expiry, units = 'days' )
      rollover_dates[n] = expiration_dates[n]
      rollover_dates = c( as.POSIXct( '1970-01-01' ), rollover_dates )
      rollover = lapply( 1:n, function( i ) prices_by_contract[[i]][ rollover_dates[i] < time & time <= rollover_dates[i+1] ][ , id := i ] )

    },
    stop( 'date or time columns not available' )

  )

  rbindlist( rollover )[]

}
