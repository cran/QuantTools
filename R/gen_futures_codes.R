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

#' Generate futures contract names between dates
#'
#' @param contract contract base name
#' @param from,to text dates in format YYYY-MM-DD
#' @param frequency expiration frequency, e.g. 3 for quarterly contracts
#'
#' @export
gen_futures_codes = function( contract, from, to, frequency ){

  months_codes = c( 'F','G', 'H', 'J', 'K', 'M', 'N', 'Q', 'U', 'V', 'X', 'Z' )

  from = as.POSIXlt.date( from )
  to = as.POSIXlt.date( to )

  month_exp = seq( 0, 12, frequency )[-1]
  years_exp = rep( from$year:to$year + 1900, each = length( month_exp ) )
  contracts = paste0( contract, months_codes[ month_exp ], substr( years_exp, 3, 4 ) )
  n = length( years_exp )
  dates_exp = years_exp * 100 + month_exp
  date_to = ( to$year + 1900 ) * 100 + ceiling( to$mon / frequency ) * frequency
  date_from = ( from$year + 1900 ) * 100 + ceiling( from$mon / frequency ) * frequency

  contracts[ dates_exp %bw% c( date_from, date_to ) ]

}
