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

#' Add candles to active time series plot
#'
#' @param x location coordinates
#' @param ohlc time_series \code{data.frame} or \code{data.table} object with 4 columns \code{'open','high','low','close'}
#' @param width width of candles body
#' @param candle.col.up,candle.col.dn colors of up and down candles
#' @param ch use Chinese style?
#' @family graphical functions
#' @details Used in \code{\link{plot_ts}} internally.
#' @export
lines_ohlc <- function(x = 1:nrow(ohlc), ohlc ,width = 0.3, candle.col.up = 'blue', candle.col.dn = 'red', ch = TRUE ){

  if( !any(methods::is(ohlc) == 'data.frame') ) stop('argument ohlc must be data.frame or data.table')


  ind_up <- ohlc[[1]] < ohlc[[4]]
  ind_dn <- ohlc[[1]] >= ohlc[[4]]

  if( ch ) {

    #segments( x[ind_up] - width, ohlc[[2]][ind_up], x[ind_up] - width, ohlc[[3]][ind_up], col = candle.col.up )
    #segments( x[ind_dn] - width, ohlc[[2]][ind_dn], x[ind_dn] - width, ohlc[[3]][ind_dn], col = candle.col.dn )

    #segments( x[ind_up] - width * 2, ohlc[[1]][ind_up], x[ind_up] - width, ohlc[[1]][ind_up], col = candle.col.up )
    #segments( x[ind_dn] - width * 2, ohlc[[1]][ind_dn], x[ind_dn] - width, ohlc[[1]][ind_dn], col = candle.col.dn )

    #segments( x[ind_up] - width, ohlc[[4]][ind_up], x[ind_up], ohlc[[4]][ind_up], col = candle.col.up )
    #segments( x[ind_dn] - width, ohlc[[4]][ind_dn], x[ind_dn], ohlc[[4]][ind_dn], col = candle.col.dn )

    segments( x - width, ohlc[[2]], x - width, ohlc[[3]], col = candle.col.up )
    segments( x - width * 2, ohlc[[1]], x - width, ohlc[[1]], col = candle.col.up )
    segments( x - width, ohlc[[4]], x, ohlc[[4]], col = candle.col.up )

  } else {

    # draw HL bars
    segments(x[ind_up] - width, ohlc[[1]][ind_up], x[ind_up] - width, ohlc[[3]][ind_up], col = candle.col.up)
    segments(x[ind_up] - width, ohlc[[4]][ind_up], x[ind_up] - width, ohlc[[2]][ind_up], col = candle.col.up)
    segments(x[ind_dn] - width, ohlc[[3]][ind_dn], x[ind_dn] - width, ohlc[[4]][ind_dn], col = candle.col.dn)
    segments(x[ind_dn] - width, ohlc[[1]][ind_dn], x[ind_dn] - width, ohlc[[2]][ind_dn], col = candle.col.dn)
    # draw body
    rect(x[ind_up] - width * 2, ohlc[[1]][ind_up], x[ind_up], ohlc[[4]][ind_up], col = candle.col.up, border = candle.col.up)
    rect(x[ind_dn] - width * 2, ohlc[[1]][ind_dn], x[ind_dn], ohlc[[4]][ind_dn], col = candle.col.dn, border = candle.col.dn)

  }

}
