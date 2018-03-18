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

#' Do calculation on data.table excluding first column
#'
#' @param x data.table
#' @param fun function or text formula where x represents argument
#' @param ... additional parameters to function if \code{action} is function
#' @details DO Function ( Column-wise/Row-wise )
#' @name dof
#' @export
dof = function( x, fun, ... ) {

  if( is.character( fun ) ) fun = eval( parse( text = paste( 'function( x ) {', fun, '}' ) ) )
  if( inherits( x[[1]], c( 'Date', 'POSIXct' ) ) ) {

    data.table( x[, 1], fun( x[, -1], ... ) )

  } else {

    fun( x, ... )

  }

}
#' @rdname dof
#' @export
dofc = function( x, fun, ... ) {

  x = copy( x )
  if( is.character( fun ) ) fun = eval( parse( text = paste( 'function( x ) {', fun, '}' ) ) )
  # skip first column if it is date or time
  if( inherits( x[[1]], c( 'Date', 'POSIXct' ) ) ) {

    for( j in seq_along( x )[-1] ) set( x , j = j, value = fun( x[[j]], ... ) )

  } else {

    for( j in seq_along( x ) ) set( x , j = j, value = fun( x[[j]], ... ) )

  }

  return( x )

}
#' @rdname dof
#' @export
'%dof%' = function( x, fun ) dof( x, fun )
#' @rdname dof
#' @export
'%dofc%' = function( x, fun ) dofc( x, fun )


