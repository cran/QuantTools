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

#' Plot data.frame as table with histogram in background
#'
#' @param x data
#' @param hist histogram background type, \code{'bycol', 'total', 'n'}
#' @param col only auto colors available
#' @param srt column names rotation
#' @param ... further graphical parameters as in \code{\link[graphics]{par}}
#' @family graphical functions
#'
#' @export
plot_table = function( x, hist = 'n', col = 'auto', srt = 0, ... ){

  xlim = 0:1
  ylim = 0:1
  plot( 0, type = 'n', xlim = xlim, ylim = ylim, xaxt = 'n', yaxt = 'n', xlab = '', ylab = '', bty = 'n', xaxs = 'i', ... )

  n_col = ncol( x )
  n_row = nrow( x )

  row_names_width = max( strwidth( rownames( x ) ) )
  col_names_width = max( strwidth( colnames( x ) ) )
  col_names_height = max( col_names_width * sin( pi * srt / 180 ), strheight( 'A' ) ) * 2

  y_step = min( strheight( 'A' ) * 2, ( diff( ylim ) - col_names_height ) / ( n_row + 1 )  )



  x_step = ( diff( xlim ) - row_names_width ) / ( n_col + 1 )

  x_rn = rep( xlim[1] + row_names_width, n_row )
  y_rn = ylim[2] - col_names_height - 1:n_row * y_step

  y_cn = rep( ylim[2] - col_names_height, n_col )
  x_cn = xlim[1] + row_names_width  + 1:n_col * x_step

  x_val = rep( x_cn, each = n_row )
  y_val = rep( y_rn, n_col )

  v = switch( hist,
              bycol = t( apply( x, 1, `/`, apply( abs( x ), 2, max ) ) ),
              total = x / max( x )
  )

  if( !is.null( v ) ) {
    v_pos = v; v_pos[ v < 0 ] = 0
    v_neg = -v; v_neg[ v > 0 ] = 0

    rect( x_val - x_step * 0.5 , y_val - y_step / 2, x_val - x_step * 0.5 + x_step * v_pos * 0.9, y_val - y_step / 2 + y_step, col = distinct_colors[1], border = 'white', ... )
    rect( x_val - x_step * 0.5 , y_val - y_step / 2, x_val - x_step * 0.5 + x_step * v_neg * 0.9, y_val - y_step / 2 + y_step, col = distinct_colors[2], border = 'white', ... )
  }

  if( hist == '3d' ) {

    v = x / max( x )
    colors_loss <- colorRampPalette( c( "white", distinct_colors[2] ) )( 100 )
    colors_gain <- colorRampPalette( c( "white", distinct_colors[1] ) )( 100 )

    col = v * NA
    col[ v > 0 ] = colors_gain[ ceiling( +v[ v > 0 ] * 100 ) ]
    col[ v < 0 ] = colors_loss[ ceiling( -v[ v < 0 ] * 100 ) ]


    rect( x_val - x_step * 0.5 , y_val - y_step / 2, x_val - x_step * 0.5 + x_step, y_val - y_step / 2 + y_step, col = col, border = 'white', ... )
  }

  text( x_rn - row_names_width * if( srt == 0 ) 1.0 else 0.0, y_rn, rownames( x ), adj = c( if( srt == 0 ) 0.0 else 1.0, 0.5 ), font = 2, ... )
  text( x_cn, y_cn, colnames( x ), adj = c( if( srt == 0 ) 0.5 else 0.0, 0.5 ), font = 2, srt = srt, ... )
  text( x_val, y_val, format( x ), adj = c( 0.5, 0.5 ), ... )

}

