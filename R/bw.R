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

#' Check if values in vector are between specified range
#'
#' @param x vector
#' @param rng range
#'
#'
#' @name bw
#' @export
bw = function( x, rng ) {


  if( any( class( x ) %in% "POSIXct" ) ) {

    if( length( rng ) == 1 ) {

      switch( as.character( nchar( rng ) ),
              '4' = { rng = as.POSIXct( paste0( c( rng, as.numeric( rng ) + 1 ), '-01-01 00:00:00' ) )  },
              '7' = {
                year = as.numeric( substr( rng, 1, 4 ) )
                month = as.numeric( substr( rng, 6, 7 ) )
                if( month == 12 ){
                  rng = as.POSIXct( paste0( c( year, year + 1 ), c( '-12-01 00:00:00', '-01-01 00:00:00' ) )  )
                } else {
                  rng = as.POSIXct( paste0( year, '-', c( month, month + 1 ), '-01 00:00:00' ) )
                }
              },
              '10' = { rng = as.POSIXct( paste0( rng, ' 00:00:00' ) ); rng[2] = rng[1] + as.difftime( 1, units = 'days' ) },
              '13' = { rng = as.POSIXct( paste0( rng, ':00:00' ) ); rng[2] = rng[1] + as.difftime( 1, units = 'hours' ) },
              '16' = { rng = as.POSIXct( paste0( rng, ':00' ) ); rng[2] = rng[1] + as.difftime( 1, units = 'minutes' ) },
              '16' = { rng = as.POSIXct( paste0( rng, '' ) ); rng[2] = rng[1] + as.difftime( 1, units = 'seconds' ) }
              )

    } else {

      switch( as.character( nchar( rng[1] ) ),
        '10' = { rng = paste( rng, '00:00:00' ) }
      )
      rng = as.POSIXct( rng )

    }
  }
  if( any( class( x ) %in% "Date" ) ) {

    rng = as.Date( rng )

  }


  if( rng[1] <= rng[2] & length(rng) == 2 ) x >= rng[1] & x <= rng[2] else stop('invalid range')

}
#' @name bw
#' @export
`%bw%` = bw
