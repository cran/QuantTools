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

#' Plot histogram of data.table by columns
#'
#' @param dt data.table
#' @param bin_width truncate data by this value
#' @param coeff group width in [0,1]
#' @param main plot title
#' @family graphical functions
#' @export
hist_dt = function( dt, bin_width = diff( range( dt, na.rm = TRUE ) ) / 10, coeff = 0.8, main = '' ) {

  data = floor( copy( dt ) / bin_width ) * bin_width

  hists = lapply( names( data ), function( x ) data[, .N, by = x ]  )
  hists = lapply( hists, setnames, c( 'x', 'y' ) )
  n = length( hists )
  lim = apply( Reduce( rbind, lapply( hists, apply, 2, range ) ), 2, range )
  xlim = lim[, 1 ] + 0:1 * bin_width / 2
  ylim = c( 0, lim[ 2, 2 ] )
  plot( 1, type = 'n', xlim = xlim, ylim = ylim, xlab = '', ylab = '', las = 1, main = main )
  grid()
  x = y = x_from = x_to = group_width = NULL
  for( i in 1:length( hists ) ) hists[[i]][ , {
    x_from = x + bin_width * coeff * ( ( 1 / coeff - 1 ) / 2 + 1 / n * ( i - 1 ) )
    x_to = x_from + group_width / n
    rect( x_from, 0, x_to, y, col = distinct_colors[i], border = NA )
  } ]
  add_legend( 'topleft', names( data ), distinct_colors[ 1:n ], lty = 0, pch = 15 )

}
