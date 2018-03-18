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

#' Multi Dimensional Heat Map
#'
#' @param x \code{data.table} object
#' @param pars names of parameters. Parameters combinations must be unique. To specify x and y axes use \code{list( x = ..., y = ... )}.
#' @param value name of value parameter
#' @param col_pos,col_neg used to generate gradient
#' @param peak_value normalization value
#' @family graphical functions
#' @details Plots multi dimensional heatmap. Axes drawn automatically by layers.
#' Inner axes are most frequent and outer axes are less frequent.
#' @export
multi_heatmap = function( x, pars, value, col_neg = c( 'darkblue', 'lightblue' ), col_pos = c( 'yellow', 'darkgreen' ), peak_value = x[ , max( abs( get( value ) ), na.rm = T ) ] ) {

  x = copy( x )
  setorderv( x, unlist( pars ) )
  if( is.list( pars ) ) {

    axes = lapply_named( unlist( pars ), function( par ) x[, unique( get( par ) ) ] )

    n_axes   = length( axes )
    n_axes_y = length( pars[[2]] )
    n_axes_x = length( pars[[1]] )

    axes_y_id = 1:n_axes_y + n_axes_x
    axes_x_id = 1:n_axes_x


  } else {

    axes = lapply_named( pars, function( par ) x[, unique( get( par ) ) ] )
    n_axes   = length( pars )
    n_axes_y = floor( n_axes / 2 )
    n_axes_x = ceiling( n_axes / 2 )

    # order by decreasing parameters length
    axes = axes[ order( -sapply( axes, length ) ) ]
    axes_y_id = c( 1:n_axes_y + 1 )
    axes_x_id = c( 1, if( n_axes > 2 ) 2:n_axes_x + n_axes_y )

  }




  axes_y = axes[ axes_y_id ]
  axes_x = axes[ axes_x_id ]

  axes_y_len = sapply( axes_y, length )
  axes_x_len = sapply( axes_x, length )

  yy = 1:prod( axes_y_len )
  xx = 1:prod( axes_x_len )
  axes_x_at = lapply( cumprod( c( 1, axes_x_len[ -n_axes_x ] ) ), seq, from = 1, to = prod( axes_x_len ) )
  names( axes_x_at ) = names( axes_x )
  axes_y_at = lapply_named( cumprod( c( 1, axes_y_len[ -n_axes_y ] ) ), seq, from = 1, to = prod( axes_y_len ) )
  names( axes_y_at ) = names( axes_y )

  #order data according to axes
  values = x[ do.call( 'order', x[ , names( axes )[ rev( c( axes_y_id, axes_x_id ) ) ], with = F ] ), get( value ) ]

  values = matrix( values, ncol = length( yy ), byrow = T )

  abs_max = peak_value
  # normalize values
  z = ceiling( values / abs_max * 100 )
  z[ values == 0 ] = NA

  breaks = c( -100:-1, 0:100 )

  colors_loss = colorRampPalette( col_neg )( 100 )
  colors_gain = colorRampPalette( col_pos )( 100 )
  colors = c( colors_loss, colors_gain )

  n_legend = 4
  mar = par( 'mar' )
  par( mar = c(
    n_axes_x,
    max( nchar( names( axes ) ) ) / 2,
    n_axes_x,
    n_axes_y + n_legend

  ) + 0.1 )
  image( xx, yy, z, col = colors, breaks = breaks, xaxt = 'n', yaxt = 'n', xlab = '', ylab = '', main = '', frame.plot = F )

  for( i in 1:n_axes_x ) {

    offset = diff( axes_x_at[[i]][1:2] ) / 2 - 0.5
    axis( at = axes_x_at[[i]][-1] - 0.5, labels = F, side = 1, line = i - 1, tick = ( i > 1 ) )
    axis( at = axes_x_at[[i]] + offset * ( i > 1 ),
          labels = rep( axes_x[[i]] , length( axes_x_at[[i]] ) / axes_x_len[[i]] ),
          side = 1, line = i - 2, tick = F )

  }

  for( i in 1:n_axes_y ) {

    offset = diff( axes_y_at[[i]][1:2] ) / 2 - 0.5
    axis( at = axes_y_at[[i]][-1] - 0.5, labels = F, side = 2, line = i - 1, tick = ( i > 1 ) )
    axis( at = axes_y_at[[i]] + offset * ( i > 1 ),
          labels = rep( axes_y[[i]] , length( axes_y_at[[i]] ) / axes_y_len[[i]] ),
          side = 2, line = i - 2, tick = F )

  }

  # http://stackoverflow.com/questions/30765866/get-margin-line-locations-in-log-space/30835971#30835971
  line2user <- function( line, side ) {
    lh <- par( 'cin' )[ 2 ] * par( 'cex' ) * par( 'lheight' )
    x_off <- diff( grconvertX( c( 0, lh ), 'inches', 'npc' ) )
    y_off <- diff( grconvertY( c( 0, lh ), 'inches', 'npc' ) )
    switch( side,
           `1` = grconvertY( -line * y_off, 'npc', 'user' ),
           `2` = grconvertX( -line * x_off, 'npc', 'user' ),
           `3` = grconvertY( 1 + line * y_off, 'npc', 'user' ),
           `4` = grconvertX( 1 + line * x_off, 'npc', 'user' ),
           stop( "Side must be 1, 2, 3, or 4", call. = FALSE ) )
  }
  # color legend
  rect(
    line2user( n_axes_y, 4 ),
    line2user( 0, 1 ) + ( line2user( 0, 3 ) - line2user( 0, 1 ) ) * 0:98 / 99,
    line2user( n_axes_y + 1, 4 ),
    line2user( 0, 1 ) + ( line2user( 0, 3 ) - line2user( 0, 1 ) ) * 1:99 / 99,
    col = colors_gain, border = NA,
    xpd = T )

  rect(
    line2user( n_axes_y + 1, 4 ),
    line2user( 0, 1 ) + ( line2user( 0, 3 ) - line2user( 0, 1 ) ) * 0:98 / 99,
    line2user( n_axes_y + 2, 4 ),
    line2user( 0, 1 ) + ( line2user( 0, 3 ) - line2user( 0, 1 ) ) * 1:99 / 99,
    col = rev( colors_loss ), border = NA,
    xpd = T )

  rect(
    line2user( n_axes_y, 4 ),
    line2user( 0, 1 ),
    line2user( n_axes_y + 2, 4 ),
    line2user( 0, 3 ),
    xpd = T
  )

  legend_ticks = pretty( c( 0, abs_max ) )
  legend_ticks_at = line2user( 0, 1 ) + ( line2user( 0, 3 ) - line2user( 0, 1 ) ) * legend_ticks / abs_max
  axis( 4, line = n_axes_y + 2, at = legend_ticks_at, labels = legend_ticks, tick = T, las = 1 )
  text( labels = c( '+', '-' ), x = line2user( n_axes_x + 1:2 - 0.5, 4 ), y = line2user( 0.5, 1 ), xpd = T )

  # axes_y_lab topleft
  axes_y_lab_x = line2user( 1:n_axes_y - 1, 2 )
  axes_y_lab_y = line2user( n_axes_y:1 - 0.5, 3 )
  text    ( axes_y_lab_x, axes_y_lab_y, xpd = T, labels = names( axes_y ), adj = 1, pos = 2 )
  segments( axes_y_lab_x, par( 'usr' )[1], axes_y_lab_x, axes_y_lab_y, xpd = T )

  # axes_x_lab bottomleft
  axes_x_lab_y = line2user( 1:n_axes_x - 1, 1 )
  axes_x_lab_x = line2user( rep( 1, n_axes_x ) - 1, 2 )
  for( i in 1:n_axes_x )  axis( side = 1, line = i - 2, at = line2user( 0.5, 1 ), tick = F,
                                labels = names( axes_x )[i], hadj = 1, xpd = T )
  segments( par( 'usr' )[1], axes_x_lab_y, par( 'usr' )[2],axes_x_lab_y, xpd = T )

  par( mar = mar )

}
