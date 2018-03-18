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

#' Plot time series !PLEASE USE plot_dts!
#'
#' @param dt \code{data.table} with date/time index represented by first column. If OHLC detected then only candles plotted. Use \code{\link[graphics]{lines}} for the rest of data
#' @param resolution frequency of time marks on time axis. Supported resolutions are \code{'auto','minute','hour','day','month','year','years'}. Default is \code{'auto'}
#' @param col color vector or single value. Default is \code{'auto'} so colors generated automatically
#' @param type type vector or single value. Same as in \code{\link[graphics]{plot}} but \code{'candle'} supports. Default is \code{'l'}. \code{'h'} triggers adding zero to plot range
#' @param lty,lwd,pch parameters vectors or single values. Same as in \code{\link[graphics]{plot}}
#' @param legend position of plot legend. Supported positions are \code{'topright','topleft','bottomright','bottomleft'} or \code{'n'} to hide legend
#' @param last_values whether to add last values marks to the right of the plot. If vector specified marks added only for columns specified in vector
#' @param main title of the plot. Default is \code{''}
#' @param ylim y range of data to plot
#' @param xlim x range of data to plot
#' @param time_range time range in format \code{'HH:MM:SS/HH:MM:SS'}
#' @param log should y axis be in logarithmic scale?
#' @param add add to existing plot?
#' @param mar same as in \code{\link[graphics]{par}}
#' @param xaxt same as in \code{\link[graphics]{par}}
#' @param t date/time vector to be converted to plot x coordinates
#' @family graphical functions
#' @details Plots time series each represented by columns of \code{times_series} on single plot. \cr
#' As for OHLC series, only one can be plotted and should be passed as \code{times_series} with 4 columns \code{'open','high','low','close'}.
#' @examples
#' \donttest{
#'
#' data( ticks )
#'
#' time_series = to_candles( ticks, 60 * 10 )
#'
#' plot_ts( time_series[ time %bw% '2016-05-13', list( time, open, high, low, close ) ] )
#' plot_ts( time_series[ time %bw% '2016-05-13', list( time, volume = volume / 1e6 )  ] , type = 'h' )
#' plot_ts( time_series[ time %bw% '2016-05', list( time, close ) ] )
#' plot_ts( time_series[ , list( time, close ) ] )
#' }
#' \donttest{
#'
#' mar = par( 'mar' )
#' par( mar = c( 0, 4, 0, 4 ), xaxt = 'n' )
#' layout ( matrix( 1:(3 + 2) ), heights = c( 1, 4, 2, 2, 1 ) )
#'   empty_plot()
#'   plot_ts( time_series[ , list( time, open, high, low, close ) ] )
#'   plot_ts( time_series[ , list( time, close ) ] )
#'   par( xaxt = 's' )
#'   plot_ts( time_series[ , list( time, volume = volume / 1e6 ) ], type = 'h' )
#'   empty_plot()
#' par( mar = mar )
#' layout( matrix(1) )
#' }
#'
#'
#' @name plot_ts
#' @export
plot_ts = function( dt, type = 'auto', col = 'auto', lty = par( 'lty' ), lwd = par( 'lwd' ), pch = par( 'pch' ), legend = c( 'topright', 'topleft', 'bottomright', 'bottomleft' , 'n' ), last_values = TRUE, main = '', ylim = 'auto', xlim = 'auto', time_range = 'auto', resolution = 'auto', log = par( 'ylog' ), mar = par( 'mar' ), xaxt = par( 'xaxt' ), add = par( 'new' ) ){

  if( is.null( dt ) ) stop( "dt must be not NULL" )
  if( nrow( dt ) == 0 ) stop( "dt must contain rows" )
  if( !any( c( 'Date', 'POSIXct' ) %in% class( dt[[1]] ) ) ) stop( "dt`s first column must be Date or POSIXct" )

  legend <- match.arg( legend )

  times = dt[[1]]
  data = dt[ , -1, with = FALSE ]
  n_series = length( data )

  if( !add ){

    assign( 'plot_ts_basis', plot_ts_basis( times, time_range ), envir = plot_ts_env )

  }
  x = t_to_x( times )
  suppressWarnings ({
    x_step = min( diff( x[ !duplicated( x ) ] ), na.rm = TRUE )
  })
  if( is.infinite( x_step ) ) x_step = 1

  series_names = names( data )

  if( type[1] == 'auto' & all( substr( tolower( series_names ), 1, 1 )[1:4] == c( 'o', 'h', 'l', 'c' ) ) ) type[1] = 'candle'

  switch( type[1],
          n = { legend = 'n'; last_values = FALSE },
          auto = { type = 'l' },
          candle = { data = data[ , 1:4, with = FALSE ] },
          stacked_hist = { pch = 15; lty = 0; lwd = 3 }
  )

  if( col[ 1 ] == 'auto' ) col = if( n_series > 25 ) rainbow( n_series ) else distinct_colors[ 1:n_series ]

  series_pars = data.table( name = series_names, type, col, lty, lwd, pch, lend = 'round' )
  series_pars[ type == 'p', lty := 'blank' ]
  series_pars[ type == 'h', lend := 'square' ]
  series_pars[ !type %in% c( 'p', 'b', 'o', 'stacked_hist' ), pch := NA ]


  if( type[1] == 'candle' ) series_pars = series_pars[ 1:2 ]


  if( ylim[1] == 'auto' ) ylim = switch( type[ 1 ],
                                      candle = range( data[, 1:4, with = FALSE ], na.rm = TRUE ),
                                      stacked_hist = range( rowSums( data ), na.rm = TRUE ),
                                      range( data, na.rm = TRUE )
  )
  if( xlim[1] == 'auto' ) xlim = get( 'plot_ts_basis', envir = plot_ts_env )[, c( x_from[1] - x_step*0, x_to[.N] + x_step / 2 * 0 ) ]

  if( !add ) { curr_mar = par( 'mar' ); curr_xaxt = par( 'xaxt' ); par( mar = mar, xaxt = xaxt ) }
  if( !add ) plot_ts_frame( xlim, ylim, resolution, log )
  if( !add ) title( main )


  x_from = x_to = name = lend = NULL
  switch( type[ 1 ],
          stacked_hist = { series_pars[, lines_stacked_hist( x, data = data, col = col, width = x_step / 2 * 0.8 ) ]; last_values = FALSE },
          candle = { series_pars[, lines_ohlc( x, ohlc = data, candle.col.up = col[2], candle.col.dn = col[2], width = x_step / 2 * 1.0 ) ]; legend = 'n' },
          for( i in 1:n_series ) series_pars[ i, lines( x, y = data[[ i ]] , col = col, type = type, lty = lty, lwd = lwd, pch = pch, lend = lend ) ]
  )

  if( legend != 'n' ) series_pars[, add_legend( legend, name, col, lty, lwd, pch ) ]


  if( last_values ) {
    if( type[ 1 ] != 'candle' ) {
      series_pars[, add_last_values( data, ylim, col ) ]
    } else {
      add_last_values( data.table( data[[ 4 ]] ), ylim, 'black' )
    }
  }

  if( !add ) par( mar = curr_mar, xaxt = curr_xaxt )

}
#' @name plot_ts
#' @export
t_to_x = function( t ) {

  . = x = x_to = t_to = t_from = x_from = NULL
  basis = get( 'plot_ts_basis', envir = plot_ts_env )
  if( basis[ 1, class( t_from )[1] == 'Date' ] ) return( basis[ match( t, t_from ), x_from ] )
  # interpolate between from and to matched by date
  basis[ match_between( t, t_from, t_to ), .( x_to, x = x_from + as.numeric( t - t_from, units = 'mins' ) ) ][ x > x_to, x := NA ][, x ][]

}
x_to_t = function( x ) {

  . = x_to = t_to = t_from = x_from = NULL
  basis = get( 'plot_ts_basis', envir = plot_ts_env )
  if( basis[ 1, class( t_from )[1] == 'Date' ] ) return( basis[ match( x, x_from ), t_from ] )
  # interpolate between from and to matched by date
  basis[ match_between( x, x_from, x_to ), .( t_to, t = t_from + as.difftime( x - x_from, units = 'mins' ) ) ][ t > t_to, t := NA ][, t ][]

}
match_between = function( x, from, to ) {

  if( length( from ) > 1 && from[2] == to[1] ) {
    # connected intervals
    breaks = c( from, to[ length( to ) ] )
    return( cut( x, breaks, labels = F, include.lowest = T ) )
  }

  epsilon = +1e-6
  breaks = c( from - epsilon, to + epsilon )
  intervals = cut( x, breaks, labels = F )
  intervals[ intervals %% 2 == 0 ] = NA

  ( intervals + 1 ) / 2

}
plot_ts_basis = function( times, time_range = 'auto' ){

  if( class( times[1] )[1] == 'Date' ) return( data.table( date = times, t_from = times, t_to = times, x_from = 1:length( times ), x_to = 1:length( times ) )[] )

  basis = data.table( date = format( times, '%F' ), time = times )

  . = date = x_to = x_from = t_from = t_to = NULL
  if( time_range != 'auto' ){

    tz = attr( times, 'tzone' )
    if( is.null( tz ) ) tz = ''

    t_from = strsplit( time_range, '/' )[[1]][1]
    t_to = strsplit( time_range, '/' )[[1]][2]
    basis = basis[, .( t_from = paste( date, t_from ), t_to = paste( date, t_to ) ), by = date ]
    basis[, ':='( t_from = as.POSIXct( t_from, tz = tz ), t_to = as.POSIXct( t_to, tz = tz ) ) ]

  } else {

    time_step = if( length( times ) > 1 ) min( diff( times ) ) else 0

    basis = basis[, .( t_from = time[1] - time_step, t_to = time[.N] ), by = date ]

    #if( basis[, .N == 1 && as.numeric( t_to - t_from, units = 'mins' ) < 10  ] ) basis[, t_to := t_from + as.difftime( 10, units = 'mins' ) ]

  }

  #basis[, t_to := t_to + min( diff( times ) ) ]
  basis[, ':='( x_from = 0, x_to = as.numeric( t_to - t_from, units = 'mins' ) ) ]
  basis[, x_to := cumsum( x_to ) ]
  basis[, x_from := c( 0, x_to[ -.N ] ) ][]

}
plot_ts_frame = function( xlim, ylim, resolution = 'auto', log = par( 'ylog' ), basis = get( 'plot_ts_basis', envir = plot_ts_env ) ) {

  lwd = par( 'lwd' )
  par( lwd = 1 )
  x_from = x_to = t_from = t_to =  NULL
  period = basis[, t_to[.N] - t_from[1] ]
  n_days = basis[, .N ]
  day_step = if( basis[,.N] != 1 ) as.numeric( basis[, min( diff( t_from ) ) ], units = 'days' ) else 1


  if( resolution == 'auto' )
    resolution =
    if( n_days > 500 / day_step ) 'years' else
      if( n_days > 100 / day_step ) 'year' else
        if( n_days > 30 / day_step ) 'month' else
          if( n_days > 8 / day_step ) 'day' else
            if( period > as.difftime( 12, units = 'hours' ) ) 'hour' else
              'minute'

  mins_grid = resolution == 'minute' & basis[ 1, class( t_from )[1] != 'Date' ]
  mins_labs = resolution == 'minute' & basis[ 1, class( t_from )[1] != 'Date' ] & par( 'xaxt' ) != 'n' & period %bw% as.difftime( c( 10, 120 ), units = 'mins' )
  hour_labs = resolution == 'minute' & basis[ 1, class( t_from )[1] != 'Date' ]
  hour_grid = resolution %in% c( 'minute', 'hour' ) & basis[ 1, class( t_from )[1] != 'Date' ]
  days_labs = resolution %in% c( 'minute', 'hour', 'day' ) & par( 'xaxt' ) != 'n'
  days_grid = resolution %in% c( 'minute', 'hour', 'day', 'month' )
  mons_labs = resolution %in% c( 'minute', 'hour', 'day', 'month', 'year' ) & par( 'xaxt' ) != 'n'
  mons_grid = resolution %in% c( 'minute', 'hour', 'day', 'month', 'year' )
  year_labs = resolution %in% c( 'minute', 'hour', 'day', 'month', 'year', 'years' ) & par( 'xaxt' ) != 'n'
  year_grid = resolution %in% c( 'minute', 'hour', 'day', 'month', 'year', 'years' )

  grid = list(
    col_mins = 'grey95',
    col_hour = 'grey90',
    col_days = 'grey80',
    col_mons = 'grey70',
    col_year = 'grey0',
    col_zero = 'red',
    lty = 3
  )

  plot( 1, type = 'n', xlim = xlim, ylim = ylim, xaxt = 'n', yaxt = 'n', xaxs = 'i', bty = 'n', xlab = '', ylab = '', main = '', ylog = log )

  abline( h = axTicks(2), col = if( hour_grid ) grid$'col_hour' else grid$'col_days', lty = grid$'lty' )
  abline( h = 0, lty = grid$'lty', col = grid$'col_zero' )
  ax_ticks <- round( axTicks(2), 10 )
  axis( 2, at = ax_ticks, labels = prettyNum( ax_ticks, ' ' ), las = 1, tick = FALSE )

  x_d = basis[, x_from ]
  t_d = basis[, t_to   ]

  id_month = !duplicated( format( t_d, '%Y-%m' ) )
  id_years = !duplicated( format( t_d, '%Y' ) )

  V1 = NULL
  if( mins_grid ){

    t_m = basis[, seq( round_POSIXct( t_from, 10, 'min', floor ), round_POSIXct( t_to, 10, 'min', ceiling ), as.difftime( 10, units = 'mins' ) ), by = 1:nrow( basis )  ][, V1]
    x_m = t_to_x( t_m )
    if( is.na( x_m[1] ) ) {
      t_m[1] = basis[ 1, t_from ]
      x_m[1] = basis[ 1, x_from ]
    }
    abline( v = x_m, lty = grid$'lty', col = grid$'col_mins' )

  }
  if( hour_grid ){

    t_h = basis[, seq( round_POSIXct( t_from, 1, 'hour', floor ), round_POSIXct( t_to, 1, 'hour', ceiling ), as.difftime( 1, units = 'hours' ) ), by = 1:nrow( basis )  ][, V1]
    x_h = t_to_x( t_h )
    if( is.na( x_h[1] ) ) {
      t_h[1] = basis[ 1, t_from ]
      x_h[1] = basis[ 1, x_from ]
    }
    abline( v = x_h, lty = grid$'lty', col = grid$'col_hour' )

  }

  if( days_grid ){

    abline( v = x_d, lty = grid$'lty', col = grid$'col_days' )

  }

  if( mons_grid ) {

    t_M = t_d[ id_month ]
    x_M = x_d[ id_month ]

    abline( v = x_M, lty = grid$'lty', col = grid$'col_mons' )

  }
  if( year_grid ) {

    t_Y = t_d[ id_years ]
    x_Y = x_d[ id_years ]
    abline( v = x_Y, lty = grid$'lty', col = grid$'col_year' )

  }
  if( mins_labs ) axis( 1, at = x_m[ !t_m %in% t_h ], labels = format( t_m[ !t_m %in% t_h ], ':%M' ), line = -1, tick = FALSE ) #, col.axis = grid$'col_mins' )
  if( hour_labs ) axis( 1, at = x_h, labels = format( t_h, '%H:%M' ), line = -1, tick = FALSE )
  if( days_labs ) axis( 1, at = x_d, labels = format( t_d, '%d' ), line = -1 + hour_labs, tick = FALSE )
  if( mons_labs ) axis( 1, at = x_M, labels = substr( format( t_M, '%b' ), 1, if( sum( id_month ) < 10 ) 100 else 1 ), line = -1 + hour_labs + days_labs, tick = FALSE )
  if( year_labs ) axis( 1, at = x_Y, labels = format( t_Y, '%Y' ), line =  -1 + hour_labs + days_labs + mons_labs, tick = FALSE )
  par( lwd = lwd )

}

plot_ts_env <- new.env()
