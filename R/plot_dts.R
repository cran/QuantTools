# Copyright (C) 2017 Stanislav Kovalevsky
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

#' Plot data.table time series
#' @section Methods:
#' \describe{
#'  \item{\bold{\code{plot_dts}}}{
#'  Add data to be plotted.
#'  }

#'  \item{\bold{\code{$lines}}}{
#'  Add lines with following arguments:
#'  \tabular{ll}{
#'     \code{names}                        \tab vector of column names to plot                        \cr
#'     \code{labels}                       \tab vector of labels if different from column names       \cr
#'     \code{type}                         \tab vector or single value, see \link[graphics]{lines}    \cr
#'     \code{lty,pch,col,lwd,lend}         \tab vector or single value, see \link[graphics]{par}      \cr
#'     \code{bg}                           \tab vector or single value, see \link[graphics]{points}   \cr
#'  }
#'  }
#'  \item{\bold{\code{$candles}}}{
#'  Add candles with following arguments:
#'     \tabular{ll}{
#'     \code{ohlc}                         \tab vector of open, high, low and close names             \cr
#'     \code{timeframe}                    \tab candle timeframe in minutes for intraday candles      \cr
#'     \code{position}                     \tab relative to time position only \code{'end'} supported \cr
#'     \code{type}                         \tab \code{'barchart'} or \code{'candlestick'}             \cr
#'     \code{gap}                          \tab gap between candles in fraction of \code{width}       \cr
#'     \code{mono}                         \tab should all candles have same color?                   \cr
#'     \code{col,col_up,col_flat,col_down} \tab colors                                                \cr
#'  }
#'  }
#'  \item{\bold{\code{$limits}}}{
#'  \tabular{ll}{
#'     \code{xlim}                         \tab vector of length two to limit plot area horizontally  \cr
#'     \code{ylim}                         \tab vector of length two to limit plot area vertically    \cr
#'     \code{tlim}                         \tab date or time vector of length two                     \cr
#'     \code{time_range}                   \tab intraday time limit in format 'H:M:S/H:M:S'           \cr
#'  }
#'  }
#'  \item{\bold{\code{$style}}}{
#'  Change default plot options. Available options are:
#'  \tabular{lll}{
#'     \bold{\code{grid}}\cr
#'     \code{minute}      \tab \code{list(col,lty)} \tab minute vertical gridline color and line type \cr
#'     \code{hour}        \tab \code{list(col,lty)} \tab hour vertical gridline color and line type   \cr
#'     \code{day}         \tab \code{list(col,lty)} \tab day vertical gridline color and line type    \cr
#'     \code{month}       \tab \code{list(col,lty)} \tab month vertical gridline color and line type  \cr
#'     \code{year}        \tab \code{list(col,lty)} \tab year vertical gridline color and line type   \cr
#'     \code{zero}        \tab \code{list(col,lty)} \tab zero horizontal gridline color and line type \cr
#'     \bold{\code{time}}\cr
#'     \code{grid}        \tab \code{logical}   \tab should vertical gridlines be plotted?                 \cr
#'     \code{resolution}  \tab \code{character} \tab auto, minute, hour, day, month, year or years         \cr
#'     \code{round}       \tab \code{numeric}   \tab time axis rounding in minutes                         \cr
#'     \code{visible}     \tab \code{logical}   \tab should time axis be plotted?                          \cr
#'     \bold{\code{value}}\cr
#'     \code{grid}        \tab \code{logical}  \tab should horizontal gridlines be plotted? \cr
#'     \code{last}        \tab \code{logical}  \tab should last values be plotted?          \cr
#'     \code{log}         \tab \code{logical}  \tab should y axis be in logarithmic scale?  \cr
#'     \code{visible}     \tab \code{logical}  \tab should y axis be plotted?               \cr
#'     \bold{\code{candle}}\cr
#'     \code{auto}          \tab \code{logical}                 \tab shoud candles be automatically detected and plotted?  \cr
#'     \code{col}           \tab \code{list(mono,up,flat,down)} \tab colors                                                \cr
#'     \code{gap}           \tab \code{numeric}                 \tab gap between candles in fraction of \code{width}       \cr
#'     \code{mono}          \tab \code{logical}                 \tab should all candles have same color?                   \cr
#'     \code{position}      \tab \code{character}               \tab relative to time position only \code{'end'} supported \cr
#'     \code{type}          \tab \code{character}               \tab \code{'candlestick'} or \code{'barchart'}             \cr
#'     \bold{\code{line}}\cr
#'     \code{auto}          \tab \code{logical}                 \tab shoud lines be automatically detected and plotted?    \cr
#'     \bold{\code{legend}}\cr
#'     \code{col}           \tab \code{list(background,frame)} \tab colors                       \cr
#'     \code{horizontal}    \tab \code{logical}                \tab should legend be horizontal? \cr
#'     \code{inset}         \tab \code{numeric}                \tab see \link[graphics]{legend}  \cr
#'     \code{position}      \tab \code{character}              \tab see \link[graphics]{legend}  \cr
#'     \code{visible}       \tab \code{logical}                \tab should legend be plotted?    \cr
#'  }
#'  }
#' }
#'
#' @usage NULL
#' @export
plot_dts = function( ... ) {

  x = PlotTs$new()
  lapply( list( ... ), x$add_data )
  x

}

plot.PlotTs = function( x ) x$plot()


PlotTs <- R6Class( 'PlotTs', lock_objects = F )

PlotTs$set( 'public', 'initialize', function() {

  self$style_info = list(

    grid = list(

      minute = list( col = 'grey95', lty = 3 ),
      hour   = list( col = 'grey90', lty = 3 ),
      day    = list( col = 'grey80', lty = 3 ),
      month  = list( col = 'grey70', lty = 3 ),
      year   = list( col = 'grey0' , lty = 3 ),
      zero   = list( col = 'red'   , lty = 3 )

    ),

    time = list(

      round      = 15,
      resolution = 'auto',
      visible    = TRUE,
      grid       = TRUE

    ),

    value = list(

      log     = FALSE,
      visible = TRUE,
      grid    = TRUE,
      last    = TRUE

    ),

    candle = list(

      auto     = TRUE,
      position = 'end', # 'middle', 'start'
      type     = 'barchart', # candlestick
      gap      = 0,
      mono     = TRUE,
      col      = list(

        mono = 'steelblue',
        up   = 'steelblue',
        flat = 'yellowgreen',
        down = 'tomato'

      )

    ),

    line = list(

      auto = TRUE

    ),

    legend = list(

      position = 'topleft',
      visible  = TRUE,
      inset    = 0.01,
      col      = list(

        background = rgb( 1, 1, 1, 0.8 ),
        frame      = rgb( 1, 1, 1, 0.0 )

      ),
      horizontal = FALSE

    )
  )
  invisible( self )
} )

PlotTs$set( 'public', 'style', function( ... ) {

  args = list(...)
  #if( is.null( names( args ) ) ) args = args[[1]]
  self$style_info = modifyList( self$style_info, args )
  self

} )

PlotTs$set( 'public', 'add_data', function( data ) {

  if( !is.data.table( data ) ) stop( 'only data.table supported' )

  self$data[[ length( self$data ) + 1 ]] = data

  x_type =
    if( inherits( data[[1]], 'Date'    ) ) 'date' else
    if( inherits( data[[1]], 'POSIXct' ) ) 'time' else
    stop( 'only Date and POSIXct index supported' )

  if( !is.null( self$x_type ) && self$x_type != x_type ) stop( 'data sets index type mismatch' )
  self$x_type = x_type

  tzone = attr( data[[1]], 'tzone' )
  self$tzone = if( is.null( tzone ) ) '' else tzone

  self

} )

PlotTs$set( 'public', 'set_time_range', function( text_time_range ) {

  seconds_in_day = 24 * 60 * 60

  range = unlist( strsplit( text_time_range, '/', fixed = TRUE ) )
  if( length( range ) != 2 ) stop( 'time must be in \'H[:M][:S]/H[:M][:S]\' format' )

  from = .text_time_to_seconds( range[1] )
  to   = .text_time_to_seconds( range[2] )

  if( from < 0 | from > seconds_in_day ) stop( 'time must be in \'H[:M][:S]/H[:M][:S]\' format' )
  if( to   < 0 | to   > seconds_in_day ) stop( 'time must be in \'H[:M][:S]/H[:M][:S]\' format' )

  if( to == 0 ) to = seconds_in_day
  if( !to > from ) stop( 'time range must be positive ( to > from )' )

  self$time_range = c( from, to )
  self

} )


PlotTs$set( 'public', 'limits', function( xlim = NULL, ylim = NULL, tlim = NULL, time_range = NULL ) {

  if( is.null( self$candles_info ) ) self$candles()
  if( is.null( self$lines_info   ) ) self$lines()
  if( !is.null( time_range ) ) self$set_time_range( time_range )

  self$frame$limited = !is.null( xlim ) | !is.null( ylim ) | !is.null( tlim )

  #if( !self$frame$limited ) return( invisible( self ) )

  if( is.null( self$basis ) ) self$calc_basis() else self$basis_limited = self$basis

  if( !is.null( tlim ) ) {

    if( is.character( tlim ) ) {
      tlim = .text_to_time_interval( tlim )
      if( self$x_type == 'date' ) tlim = as.Date( tlim )
    } else {
        if( length( tlim ) != 2 ) stop( 'tlim must have two elements' )
    }

    if( tlim[1] < self$basis[1,  t_from ] ) tlim[1] = self$basis[1 , t_from ]
    if( tlim[1] > self$basis[.N, t_to   ] ) tlim[1] = self$basis[1 , t_from ]
    if( tlim[2] > self$basis[.N, t_to   ] ) tlim[2] = self$basis[.N, t_to   ]
    if( tlim[2] < self$basis[1,  t_from ] ) tlim[2] = self$basis[.N, t_to   ]
    if( tlim[2] <= tlim[1] ) tlim[2] = self$basis[.N, t_to   ]

    xlim = self$t_to_x( tlim )
    tlim2 = c( self$basis[ t_from >= tlim[1], t_from[1] ], self$basis[ t_to <= tlim[2], t_to[.N] ] )
    xlim[ is.na( xlim ) ] = self$t_to_x( tlim2[ is.na( xlim ) ] )
    #if( any( is.na( xlim ) ) ) xlim = NULL

  }

  if( is.null( xlim ) ) {

    xlim = self$basis[, c( x_from[1], x_to[.N] ) ]
    self$basis_limited = self$basis
    #tlim = xlim

  }

  if( is.null( ylim ) ) {

    if( length( xlim ) != 2 ) stop( 'xlim must have two elements' )

    xlim = round( xlim )

    if( xlim[2] - xlim[1] < 1 ) xlim[2] = xlim[1] + 1

    if( xlim[1] < self$basis[  1, x_from ] ) xlim[1] = self$basis[  1, x_from ]
    if( xlim[2] > self$basis[ .N, x_to   ] ) xlim[2] = self$basis[ .N, x_to   ]

    if( xlim[2] <= self$basis[  1, x_from ] ) xlim[2] = self$basis[ .N, x_to   ]
    if( xlim[1] >= self$basis[ .N, x_to   ] ) xlim[1] = self$basis[  1, x_from ]

    tlim = self$x_to_t( xlim )

    selection = rbind(

      self$lines_info,
      as.data.table( self$candles_info ), fill = T

    )[, .( name, data_id ) ]


    ylim = selection[, {

      y = self$data[[ data_id ]][ self$data_x[[ data_id ]] >= xlim[1] & self$data_x[[ data_id ]] <= xlim[2], name, with = FALSE ]
      if( nrow( y ) == 0 ) Inf else suppressWarnings( range( y, na.rm = TRUE ) )

    }, by = data_id ][[2]]

    ylim = suppressWarnings( range( ylim, na.rm = TRUE, finite = TRUE ) )
    if( any( is.infinite( ylim ) ) ) ylim = c( 0, 1 )

    basis_limited = self$basis[ { x = match_between( xlim, x_from, x_to ); x[1]:x[2] } ]

    basis_limited[ 1 , ':='( x_from = xlim[1], t_from = tlim[1] ) ]
    basis_limited[ .N, ':='( x_to   = xlim[2], t_to   = tlim[2] ) ]
    if( self$x_type == 'time' ) basis_limited = basis_limited[ x_from != x_to ]


    self$basis_limited = basis_limited

  }

  self$frame$xlim = xlim
  self$frame$ylim = ylim
  self$frame$tlim = tlim

  self

} )

PlotTs$set( 'public', 'calc_basis', function() {

  if( is.null( self$x_type ) ) stop( 'add data first' )

  t = sort( do.call( 'c', lapply( self$data, '[[', 1 ) ) )

  switch(
    self$x_type,
    time = {

      setattr( t, 'tzone', self$tzone )

      # calculate daily intervals

      basis = data.table( time = t )[, .( t_from = time[1 ], t_to = time[.N] ), by = .( date = as.Date( time ) ) ]
      if( !is.null( self$time_range ) ) {

        basis[, t_from := fasttime::fastPOSIXct( date, self$tzone ) + self$time_range[1] ]
        basis[, t_to   := fasttime::fastPOSIXct( date, self$tzone ) + self$time_range[2] ]

      } else {

        basis[, t_from := round_POSIXct( t_from, self$style_info$time$round, 'mins', floor ) - as.difftime( self$style_info$time$round, units = 'mins' ) ]
        basis[, t_to   := round_POSIXct( t_to  , self$style_info$time$round, 'mins', floor ) + as.difftime( self$style_info$time$round, units = 'mins' ) ]

      }

      lag = function( x, first = NA ) { c( first, x[ -length( x ) ] ) }
      # merge overlapping intervals
      basis[, not_overlap_previous := lag( t_to, first = -Inf ) < t_from ]
      basis[, interval_id := cumsum( not_overlap_previous ) ]
      basis = basis[ , .( date_from = date[1], date_to = date[.N], t_from = t_from[1], t_to = t_to[.N] ), by = interval_id ]

      # set continuous x intervals
      basis[, x_to   := cumsum( as.numeric( t_to - t_from, units = 'mins' ) ) ]
      basis[, x_from := lag( x_to, first = 0 ) ]

    },
    date = {

      basis = data.table( date = t )[ , .( interval_id = 1:.N, date_from = date, date_to = date, t_from = date, t_to = date, x_from = 1:.N, x_to = 1:.N ) ]

    }
  )

  self$basis = basis
  self$basis_limited = self$basis
  self$calc_data_x()


  invisible( self )

} )

PlotTs$set( 'public', 'calc_data_x', function() {

  self$data_x = lapply( self$data, function( x ) self$t_to_x( x[[1]] ) )

  invisible( self )

} )

PlotTs$set( 'public', 'plot_frame', function() {

  plot( 1, 1, type = 'n', xlab = '', ylab = '', main = '', xaxt = 'n', yaxt = 'n', xlim = self$frame$xlim, ylim = self$frame$ylim, xaxs = 'i', bty = 'n', log = if( self$style_info$value$log ) 'y' else ''  )

  ax_ticks = round( axTicks( 2 ), 10 )
  if( self$style_info$value$visible ) axis( 2, at = ax_ticks, labels = format( ax_ticks ), las = 1, tick = FALSE )

  if( self$style_info$value$grid )
    if( self$x_grid$hours ) abline( h = ax_ticks, col = self$style_info$grid$hour$col, lty = self$style_info$grid$hour$lty ) else
    if( self$x_grid$dates ) abline( h = ax_ticks, col = self$style_info$grid$day $col, lty = self$style_info$grid$day $lty ) else
     abline( h = ax_ticks, col = self$style_info$grid$month$col, lty = self$style_info$grid$month$lty )

  abline( h = 0, col = self$style_info$grid$zero$col, lty = self$style_info$grid$zero$lty )

  invisible( self )

} )

PlotTs$set( 'public', 't_to_x', function( t ) {

  if( is.null( self$x_type ) ) stop( 'add data first' )

  switch( self$x_type,
    time = self$basis_limited[ match_between( t, t_from, t_to ), .( x_to, x = x_from + as.numeric( t - t_from, units = 'mins' ) ) ][ x > x_to, x := NA ][, x ],
    date = self$basis_limited[ match( t, t_from ), x_from ]
  )

} )

PlotTs$set( 'public', 'x_to_t', function( x ) {

  if( is.null( self$x_type ) ) stop( 'add data first' )

  switch( self$x_type,
    time = self$basis_limited[ match_between( x, x_from, x_to ), .( t_to, t = t_from + as.difftime( x - x_from, units = 'mins' ) ) ][ t > t_to, t := NA ][, t ],
    date = self$basis_limited[ match_between( x, x_from, x_to ), t_from ]
  )

} )

PlotTs$set( 'public', 'calc_time_grid_and_labels', function() {

  if( is.null( self$x_type ) ) stop( 'add data first' )
  if( is.null( self$basis ) ) self$calc_basis()

  resolution = match.arg( self$style_info$time$resolution, choices = c( 'auto', 'minute', 'hour', 'day', 'month', 'year', 'years' ) )

  if( resolution == 'auto' ) resolution =

      switch(
        self$x_type,

        time = {

          time_span_hours = self$basis_limited[, sum( x_to - x_from ) / 60 ]
          time_span_dates = self$basis_limited[, sum( date_to - date_from + 1 ) ]

          if( time_span_dates      > 1500 ) 'years' else
          if( time_span_dates      > 100  ) 'year'  else
          if( time_span_dates      > 50   ) 'month' else
          if( time_span_dates      > 8    ) 'day'   else
          if( time_span_hours      > 4    ) 'hour'  else
          'minute'

        },

        date = {

          time_span_dates = self$basis_limited[, .N ]

          if( time_span_dates > 1500 ) 'years' else
          if( time_span_dates > 100  ) 'year'  else
          if( time_span_dates > 50   ) 'month' else
          'day'

        }
      )


  self$x_grid = list(

    '10min' = resolution %in% c( 'minute' ),
    'hours' = resolution %in% c( 'minute', 'hour' ),
    'dates' = resolution %in% c( 'minute', 'hour', 'day', 'month' ),
    'month' = resolution %in% c( 'minute', 'hour', 'day', 'month', 'year' ),
    'years' = resolution %in% c( 'minute', 'hour', 'day', 'month', 'year', 'years' )

  )

  self$x_labs = list(

    '10min' = par( 'xaxt' ) != 'n' & resolution %in% c( 'minute' ),
    'hours' = par( 'xaxt' ) != 'n' & resolution %in% c( 'minute', 'hour' ),
    'dates' = par( 'xaxt' ) != 'n' & resolution %in% c( 'minute', 'hour', 'day'  ),
    'month' = par( 'xaxt' ) != 'n' & resolution %in% c( 'minute', 'hour', 'day', 'month', 'year' ),
    'years' = par( 'xaxt' ) != 'n' & resolution %in% c( 'minute', 'hour', 'day', 'month', 'year', 'years' )

  )

  dates = data.table(
    t = switch(
      self$x_type,
      time = {

        t = self$basis_limited[, {
          t = c( t_from, seq( round_POSIXct( t_from, 1, units = 'days' ), round_POSIXct( t_to, 1, units = 'days' ), as.difftime( 1, units = 'days' ) ) )
          t[ t >= t_from & t <= t_to ]
        }, by = interval_id ][[2]]
        setattr( t, 'tzone', self$tzone )

      },

      date = {

        self$basis_limited[, date_from ]

      } )
  )
  dates[, x := self$t_to_x( t ) ]
  dates[, l := format( t, '%d' ) ]
  dates = dates[, .SD[.N], by = x ]

  month = dates[ !duplicated( format( t, '%Y-%m' ) ) ]
  month[, l := format( t, '%b' ) ]
  if( month[, .N] > 12 ) month[, l := substr( l, 1, 1 ) ]

  years = month[ !duplicated( format( t, '%Y' ) ) ]
  years[, l := format( t, '%Y' ) ]


  hours = NULL
  if( self$x_labs$'hours' | self$x_grid$'hours' ) {

    hours = data.table( t = {
      t = self$basis_limited[, c( t_from, seq( round_POSIXct( t_from, 1, units = 'hours' ), round_POSIXct( t_to, 1, units = 'hours' ), as.difftime( 1 , units = 'hours' ) ) ), by = interval_id ][[2]]
      setattr( t, 'tzone', self$tzone )

    } )
    hours[, x := self$t_to_x( t ) ]
    hours[ 1, t := if( is.na( x ) ) self$basis_limited[ 1, t_from ] else t ][ 1, x := self$t_to_x( t ) ]
    hours[, l := format( t, '%H:%M' ) ]
    hours = hours[, .SD[.N], by = x ]

  }

  min10 = NULL
  if( self$x_labs$'10min' | self$x_grid$'10min' ) {

    min10 = data.table(
      t = self$basis_limited[, seq( round_POSIXct( t_from, 10, units = 'mins' ), round_POSIXct( t_to, 10, units = 'mins' ), as.difftime( 10, units = 'mins'  ) ), by = interval_id ][[2]]
    )[ !t %in% hours$t ]
    min10[, x := self$t_to_x( t ) ]
    min10[, l := format( t, ':%M' ) ]

  }

  self$x_grid_coord = list( min10 = min10, hours = hours, dates = dates, month = month, years = years )

  invisible( self )

} )

PlotTs$set( 'public', 'plot_time_grid', function() {

  if( !self$style_info$time$grid ) return( invisible( self ) )

  if( self$x_grid$'10min' ) abline( v = self$x_grid_coord$min10$x, lty = self$style_info$grid$minute$lty, col = self$style_info$grid$minute$col )
  if( self$x_grid$'hours' ) abline( v = self$x_grid_coord$hours$x, lty = self$style_info$grid$hour  $lty, col = self$style_info$grid$hour  $col )
  if( self$x_grid$'dates' ) abline( v = self$x_grid_coord$dates$x, lty = self$style_info$grid$day   $lty, col = self$style_info$grid$day   $col )
  if( self$x_grid$'month' ) abline( v = self$x_grid_coord$month$x, lty = self$style_info$grid$month $lty, col = self$style_info$grid$month $col )
  if( self$x_grid$'years' ) abline( v = self$x_grid_coord$years$x, lty = self$style_info$grid$year  $lty, col = self$style_info$grid$year  $col )

  invisible( self )

} )

PlotTs$set( 'public', 'plot_time', function() {

  if( !self$style_info$time$visible ) return( invisible( self ) )

  if( self$x_labs$'10min' ) {

    min10_hours = rbind( self$x_grid_coord$hours, self$x_grid_coord$min10 )[ !is.na( x ) ]
    setorder( min10_hours, x )
    min10_hours[ 1, l := format( t, '%H:%M' ) ]


    min10_hours[ , axis( at = x, labels = l, side = 1, tick = FALSE, line = -1 ) ]

  } else
  if( self$x_labs$'hours' ) self$x_grid_coord$hours[, axis( at = x, labels = l, side = 1, tick = FALSE, line = -1 ) ]
  if( self$x_labs$'dates' ) self$x_grid_coord$dates[, axis( at = x, labels = l, side = 1, tick = FALSE, line = -1 + self$x_labs$'hours' ) ]
  if( self$x_labs$'month' ) self$x_grid_coord$month[, axis( at = x, labels = l, side = 1, tick = FALSE, line = -1 + self$x_labs$'hours' + self$x_labs$'dates' ) ]
  if( self$x_labs$'years' ) self$x_grid_coord$years[, axis( at = x, labels = l, side = 1, tick = FALSE, line = -1 + self$x_labs$'hours' + self$x_labs$'dates' + self$x_labs$'month' ) ]

  invisible( self )

} )

PlotTs$set( 'public', 'print', function(...) {

  self$plot()

} )


PlotTs$set( 'public', 'stack', function( names = NULL, labels = names, col = 'auto', timeframe = 'auto', position, type, gap ) {

  if( !missing( position ) ) self$style_info$stack$position = position
  if( !missing( type     ) ) self$style_info$stack$type     = type
  if( !missing( gap      ) ) self$style_info$stack$gap      = gap

  if( !is.null( self$stack_info ) ) stop( 'only single stack trace supported' )

  # scan data for stack
  data_id = which( sapply( self$data, function( x ) all( names %in% names( x ) ) ) )
  if( length( data_id ) > 1 ) {

    data_id = data_id[1]
    warning( 'multiple data sets found having specified stack names: using first data set' )

  }
  if( length( data_id ) == 0 ) return( self )#stop( 'no data sets found having specified ohlc names' )

  self$stack_info = list(
    data_id   = data_id,
    name      = names,
    label     = labels,
    col       = col,
    timeframe = timeframe
  )

  self

} )

PlotTs$set( 'public', 'lines',
            function( names = NULL, labels = names, type = 'l', lty = 1, pch = 19, col = 'auto', bg = NA, lwd = 1, lend = 'round' ) {

    # names = 'auto'; type = 'l'; lty = 1; pch = 19; col = 'auto'; lwd = 1; lend = 'round'

    if( !is.null( names ) && length( names ) == 0 ) return( self )
    auto_lines = is.null( names )

    if( auto_lines ) {

      names = unique( unlist( lapply( self$data, function( x ) names( x )[ -1 ] ) ) )
      if( !is.null( self$candles_info ) ) names = names %w/o% self$candles_info$name
      if( !is.null( self$lines_info   ) ) names = names %w/o% self$lines_info$name
      labels = names

    }

    n_lines = length( names )
    if( !length( type   ) %in% c( 1, n_lines ) ) stop( 'type must be same size as names or single value' )
    if( !length( lty    ) %in% c( 1, n_lines ) ) stop( 'lty must be same size as names or single value'  )
    if( !length( pch    ) %in% c( 1, n_lines ) ) stop( 'pch must be same size as names or single value'  )
    if( !length( col    ) %in% c( 1, n_lines ) ) stop( 'col must be same size as names or single value'  )
    if( !length( bg     ) %in% c( 1, n_lines ) ) stop( 'bg must be same size as names or single value'   )
    if( !length( lwd    ) %in% c( 1, n_lines ) ) stop( 'lwd must be same size as names or single value'  )
    if( !length( lend   ) %in% c( 1, n_lines ) ) stop( 'lend must be same size as names or single value' )
    if( !length( labels ) %in% n_lines         ) stop( 'labels must be same size as names'               )

    lines_info = data.table( data_id = 1:length( self$data ) )[, {
      data_names = names( self$data[[data_id]] )
      name_id = match( names, data_names )
      name = data_names[ name_id ]
      list( name_id = name_id, name = name )
    }, by = data_id ][ !is.na( name ) ]
    if( nrow( lines_info ) == 0 & !is.null( names ) ) if( auto_lines ) return( self ) else stop( 'no data sets found having specified lines names' )


    lines_info[, ':='( type = type, lty = lty, pch = pch, col = col, bg = bg, lwd = lwd, lend = lend, label = labels ) ]

    if( lines_info[ , .N != uniqueN( name ) ] ) warning( 'multiple data sets found having specified names: using first data set' )

    self$lines_info = rbind( self$lines_info, lines_info )

    self

} )

PlotTs$set( 'public', 'candles', function( ohlc = c( 'open', 'high', 'low', 'close' ), timeframe = 'auto', position, type, gap, mono, col, col_up, col_flat, col_down ) {

  if( !missing( position ) ) self$style_info$candle$position = position
  if( !missing( type     ) ) self$style_info$candle$type     = type
  if( !missing( gap      ) ) self$style_info$candle$gap      = gap
  if( !missing( mono     ) ) self$style_info$candle$mono     = mono
  if( !missing( col      ) ) self$style_info$candle$col$mono = col
  if( !missing( col_up   ) ) self$style_info$candle$col$up   = col_up
  if( !missing( col_down ) ) self$style_info$candle$col$down = col_down
  if( !missing( col_flat ) ) self$style_info$candle$col$flat = col_flat

  if( !is.null( self$candles_info ) ) stop( 'only single candles trace supported' )

  # scan data for ohlc
  data_id = which( sapply( self$data, function( x ) all( ohlc %in% names( x ) ) ) )
  if( length( data_id ) > 1 ) {

    data_id = data_id[1]
    warning( 'multiple data sets found having specified ohlc names: using first data set' )

  }
  if( length( data_id ) == 0 ) return( self )#stop( 'no data sets found having specified ohlc names' )

  self$candles_info = list(
    data_id   = data_id,
    name      = ohlc,
    timeframe = timeframe
  )

  self

} )
PlotTs$set( 'public', 'plot_stack', function() {

  if( is.null( self$stack_info ) ) return( invisible( self ) )

  info = as.data.table( self$stack_info[ c( 'name', 'label', 'col' ) ] )
  info[ col == 'auto', col := distinct_colors[ 1:.N ] ]

  x = self$data_x[[ self$stack_info$data_id ]]

  timeframe = if( self$stack_info$timeframe == 'auto' ) min( diff( x ), na.rm = T ) else self$stack_info$timeframe
  width = timeframe * ( 1 - self$style_info$stack$gap ) / 2

  y = self$data[[ self$stack_info$data_id ]][ x >= self$frame$xlim[1] & x <= self$frame$xlim[2] & !is.na( x ) ][, info$name, with = F ]
  x = x[ x >= self$frame$xlim[1] & x <= self$frame$xlim[2] & !is.na( x ) ]

  y_positive = y * ( y > 0 )
  y_negative = y * ( y < 0 )

  yy = y_positive
  yy[, {

    y = as.vector( .SD )
    col = info[ order( y ) ]
    y = cumsum( y[ order( y ) ] )



  }, by = .( 1:nrow( yy ) ) ]
  apply( yy, 1, order )



  rect( x - width * 2, y[[ open ]], x        , y[[ close ]], col = col, border = col )

  switch(
    self$style_info$candle$type,
    barchart = {

      segments( x - width    , y[[ high  ]], x - width, y[[ low   ]], col = col )
      segments( x - width * 2, y[[ open  ]], x - width, y[[ open  ]], col = col )
      segments( x - width    , y[[ close ]], x        , y[[ close ]], col = col )

    },
    candlestick = {

      segments( x - width    , y[[ high ]], x - width, y[[ low   ]], col = col )
      rect    ( x - width * 2, y[[ open ]], x        , y[[ close ]], col = col, border = col )

    }
  )

  self$candles_info$last = tail( y[[ close ]], 1 )
  self$candles_info$col  = tail( col, 1 )

  invisible( self )

} )

PlotTs$set( 'public', 'plot_candles', function() {

  if( is.null( self$candles_info ) ) return( invisible( self ) )

  open  = self$candles_info$name[1]
  high  = self$candles_info$name[2]
  low   = self$candles_info$name[3]
  close = self$candles_info$name[4]

  x = self$data_x[[ self$candles_info$data_id ]]

  timeframe = if( self$candles_info$timeframe == 'auto' ) min( diff( x ), na.rm = T ) else self$candles_info$timeframe
  width = timeframe * ( 1 - self$style_info$candle$gap ) / 2

  y = self$data[[ self$candles_info$data_id ]][ x >= self$frame$xlim[1] & x <= self$frame$xlim[2] & !is.na( x ) ]
  x = x[ x >= self$frame$xlim[1] & x <= self$frame$xlim[2] & !is.na( x ) ]

  col = if( !self$style_info$candle$mono ) {

    ifelse( y[[ open  ]] < y[[ close ]], self$style_info$candle$col$up,
            ifelse( y[[ open  ]] > y[[ close ]], self$style_info$candle$col$down,
                    self$style_info$candle$col$flat ) )

  } else self$style_info$candle$col$mono

  switch(
    self$style_info$candle$type,
    barchart = {

      segments( x - width    , y[[ high  ]], x - width, y[[ low   ]], col = col )
      segments( x - width * 2, y[[ open  ]], x - width, y[[ open  ]], col = col )
      segments( x - width    , y[[ close ]], x        , y[[ close ]], col = col )

    },
    candlestick = {

      segments( x - width    , y[[ high ]], x - width, y[[ low   ]], col = col )
      rect    ( x - width * 2, y[[ open ]], x        , y[[ close ]], col = col, border = col )

    }
  )

  self$candles_info$last = tail( y[[ close ]], 1 )
  self$candles_info$col  = tail( col, 1 )

  invisible( self )

} )

PlotTs$set( 'public', 'plot_lines', function() {

  if( is.null( self$lines_info ) ) return( invisible( self ) )

  self$lines_info = self$lines_info[ !duplicated( name ) ]

  self$lines_info[ type == 'p', lty := 0 ]
  self$lines_info[ type == 'h', lend := 'square' ]
  self$lines_info[ !type %in% c( 'p', 'b', 'o' ), pch := NA ]

  self$lines_info[ col == 'auto', col := distinct_colors[ 1:.N ] ]

  self$lines_info[, last := {

    x = self$data_x[[ data_id ]]
    y = self$data[[ data_id ]][[ name_id ]]#[ x >= self$frame$xlim[1] & x <= self$frame$xlim[2] ]
    #x = x[ x >= self$frame$xlim[1] & x <= self$frame$xlim[2] ]

    lines( x, y, type = type[1], lty = lty[1], pch = pch[1], col = col[1], lwd = lwd[1], lend = lend[1], bg = bg[1] )
    as.double( tail( y[ x <= self$frame$xlim[2] ], 1 ) )


  } , by = list( data_id, name_id ) ]

  invisible( self )

} )

PlotTs$set( 'public', 'plot_legend', function() {

  if( !self$style_info$legend$visible ) return( invisible( self ) )

  legend_info = self$lines_info

  if( !is.null( legend_info ) )
    legend_info[, {

      legend( legend = label, col = col, pt.bg = bg, lty = lty, pch = pch, lwd = lwd,
              x = self$style_info$legend$position,
              bg = self$style_info$legend$col$background,
              box.col = self$style_info$legend$col$frame,
              inset = self$style_info$legend$inset,
              xpd = TRUE,
              horiz = self$style_info$legend$horizontal )

    } ]

  invisible( self )

} )

PlotTs$set( 'public', 'plot', function() {

  if( all( sapply( self$data, ncol ) == 1 ) ) stop( 'at least one data set must have data columns' )
  if( is.null( self$basis        ) ) self$limits()
  self$calc_time_grid_and_labels()
  self$plot_frame()
  self$plot_time()
  self$plot_time_grid()
  self$plot_candles()
  self$plot_lines()
  self$plot_legend()
  self$plot_last_values()

  invisible( self )

} )

PlotTs$set( 'public', 'plot_last_values', function() {

  if( !self$style_info$value$last ) return( invisible( self ) )

  if( !is.null( self$lines_info ) ){

    self$lines_info[ type == 'p', last := NA ]

  }
  if( is.null( self$lines_info ) & is.null( self$candles_info ) ) return( invisible( self ) )

  lines_info = rbind( self$lines_info[, c( 'last', 'col' ) ], setDT( self$candles_info[ c( 'last', 'col' ) ] ) )

  setorder( lines_info, last )
  lines_info = lines_info[ !is.na( last ) ]
  if( nrow( lines_info ) == 0 ) return( invisible( self ) )


  last_values <- round( lines_info$last, calc_decimal_resolution( axTicks( 2 ) ) )

  at  = last_values

  steps = c( Inf, diff( at ) )

  str_height = strheight( 'X' ) * 1.1

  overlaps = steps < str_height

  overlaps[ which( overlaps ) - 1 ] = TRUE

  rle <- rle( overlaps )

  group_lengths = rle$length
  group_values  = rle$values
  n_groups      = length( group_lengths )

  m = cumsum( group_lengths )

  n = c( 1, m[-n_groups] + 1 )

  groups = mapply( ':', n, m, SIMPLIFY = FALSE )


  last_values_shifted = lapply( 1:n_groups, function(i) if( group_values[i] ) {

    values = last_values[ groups[[i]] ]

    at_values = seq( from = values[1], by = str_height, length.out = group_lengths[i] )

    at_offset = mean( values ) - mean( at_values )

    at_values = at_values + at_offset

  } else at_values = last_values[ groups[[i]] ]  )

  last_values_shifted <- unlist( last_values_shifted )

  mtext( format( last_values ), at = last_values_shifted, side = 4, cex = par('cex'), line = 0.5, las = 1, col = lines_info$col )

  invisible( self )

} )
