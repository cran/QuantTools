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

#' Last Observation Carried Forward
#'
#' @param x list or vector to roll through
#' @param na leading NA substitution
#' @name na_locf
#' @export
na_locf = function( x, na = NA ) {

  if( is.list( x ) ) {

    if( inherits( x, 'data.table' ) ) return( setDT( na_locf_list( x, na ) ) )
    return( na_locf_list( x, na ) )

  }
  if( is.vector( x ) | inherits( x, c( 'POSIXct', 'Date' ) ) ) return( na_locf_vector( x, na ) )
  stop( 'x must be list or vector' )

}

na_locf_vector = function( x, na = NA ) {

  x = if( is.numeric( x ) ) na_locf_numeric( x ) else na_locf_nonnumeric( x )
  x[ is.na( x ) ] = na
  return( x )

}

na_locf_list = function( x, na = NA ) {

  attrs = attributes( x )
  x = lapply( x, na_locf_vector, na )
  attributes( x ) = attrs
  return( x )

}

na_locf_nonnumeric = function( x ) {

  x_id = seq_along( x )
  x_id[ is.na( x ) ] = NA
  x[ na_locf_numeric( x_id ) ]

}

