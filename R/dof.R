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
#' @param obj data.table
#' @param action function or text string with actions to perform
#' @param ... additional parameters to function if \code{action} is function
#' @name dof
#' @export
dof <- function( obj, action, ... ){
  set_columns = FALSE
  data <- obj[ , -1, with = FALSE ]
  if( !any( methods::is( action ) == 'function' ) ){
    expr <- parse( text = ( paste( 'data', action ) ) )
    data <- eval( expr )
  } else {
    data <- action( data, ... )
    if( methods::is( data )[1] != 'data.table' ){
      if( ( length( data ) != nrow( obj ) ) | nrow(obj) <= 2 )  return( data )
	  set_columns = TRUE
	}

  }
  ret <- data.table( obj[ , 1, with = FALSE ], data )
  new_names <- deparse( substitute( action ) )
  if( set_columns ) setnames( ret, 2, gsub( '[\\(, ]|=.*', '', new_names ) )
  return( ret )
}
#' @rdname dof
#' @export
'%dof%' <- function( obj, action ) dof( obj, action )
