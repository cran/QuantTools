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

#' Generate futures contract codes and schedule between dates
#'
#' @param contract contract base name
#' @param from,to text dates in format \code{"YYYY-MM-DD"}
#' @param frequency expiration frequency, e.g. 3 for quarterly contracts
#' @param day_exp expiration day number, e.g. 15 for middle of month
#' @param year_last_digit should only last digit of year present in code?
#' @return returns \code{data.table} with columns \code{code, from, to, contract_id}.
#' @export
gen_futures_codes = function( contract, from, to, frequency, day_exp, year_last_digit = FALSE ){

  months_codes = c( 'F','G', 'H', 'J', 'K', 'M', 'N', 'Q', 'U', 'V', 'X', 'Z' )

  years = as.numeric( substr( c( from, to ), 1, 4 ) )

  month_exp = seq( 0, 12, frequency )[-1]
  years_exp = rep( years[1]:years[2], each = length( month_exp ) )
  contracts = paste0( contract, months_codes[ month_exp ], substr( years_exp, 3 + year_last_digit, 4 ) )

  dates_exp = as.Date( paste( years_exp, month_exp, day_exp, sep = '-' ) )

  tos   = dates_exp
  froms = c( tos[1] - 31 * frequency, tos[ -length( tos ) ] + 1 )

  from_ = as.Date( from )
  to_   = as.Date( to )
  schedule = data.table( code = contracts, from = froms, to = tos )[ to >= from_ & from <= to_ ]
  schedule[ 1, from := from_ ]
  schedule[ .N, to := to_ ]
  contract_id = NULL
  schedule[ , contract_id := 1:.N ]

  return( schedule[] )

}
