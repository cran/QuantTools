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

#' Calculate decimal resolution
#'
#' @param x numeric vector
#' @details Used in \code{\link{add_last_values}} internally.
#' @export
calc_decimal_resolution <- function(x){

  x <- abs(x)
  x <- round(x,16)

  x = format( x )

  is_decimal = any( grepl( '\\.', x ) )

  decimal_part = if( is_decimal ) gsub( '.*\\.', '', x ) else ''
  integer_part = gsub( '\\..*| ', '', x )

  n_decimals = nchar( decimal_part )
  n_integers = nchar( integer_part )

  max_n_decimals <- max(n_decimals)
  max_n_integers <- max(n_integers)
  min_n_integers <- min(n_integers)

  resolution =  if(max_n_decimals == 0 & max_n_integers - min_n_integers > 0 ) 0 else max_n_decimals + 1

  return(resolution)
}
