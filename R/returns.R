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

#' Calculate returns
#'
#' @param x numeric vector
#' @param type \code{'r' = x[t] / x[t-n] - 1 }, \code{'l' = ln( x[t] / x[t-n] ) }
#' @param n lookback
#' @return Vector of same length as x with absent returns converted to 0 for relative and 1 for logarithmic.
#' @export
returns = function( x, type = 'r', n = 1 ) {
  if( !is.numeric( x ) ) return( x )
  N = length( x )
  if( n >= N ) stop( 'not enough data' )
  returns = switch( type,
                    r = c( rep( 0, n ), x[ -( 1:n ) ] / x[ -( N:( N - n + 1 ) ) ] - 1 ),
                    l = c( rep( 1, n ), log( x[ -( 1:n ) ] / x[ -( N:( N - n + 1 ) ) ] ) )
  )
}
