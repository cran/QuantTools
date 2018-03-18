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


#' Round POSIXct timestamps
#'
#' @param x POSIXct vector
#' @param n number of units to round off
#' @param units to round off to
#' @param method round method, see \link[base]{Round}
#' @details Rounds POSIXct vector with specified method.
#' @name round_POSIXct
#' @export
round_POSIXct = function( x, n = 1, units = c( 'secs','mins', 'hours', 'days' ), method = round ) {

  if( n == 0 ) return( x )
  units <- match.arg( units )
  r = n * switch( units, 'secs'  = 1, 'mins'  = 60, 'hours'  = 60 * 60, 'days' = 60 * 60 * 24 )
  as.POSIXct( method( as.numeric( x ) / r ) * r, tz = attr( x, 'tzone' ), origin = '1970-01-01' )

}
#' @rdname round_POSIXct
#' @export
ceiling_POSIXct = function( x, n = 1, units = c( 'secs','mins', 'hours', 'days' ) ) round_POSIXct( x, n, units, method = ceiling )
#' @rdname round_POSIXct
#' @export
trunc_POSIXct = function( x, n = 1, units = c( 'secs','mins', 'hours', 'days' ) ) round_POSIXct( x, n, units, method = trunc )

