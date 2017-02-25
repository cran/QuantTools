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

#' Add stacked histogram to active time series plot
#'
#' @param x location coordinates
#' @param data time_series \code{data.frame} or \code{data.table} object with 4 columns \code{'open','high','low','close'}
#' @param width width of histogram segment
#' @param col colors of segments
#' @param ordered should stacked bars be in order?
#' @family graphical functions
#' @details Used in \code{\link{plot_ts}} internally.
#' @export
lines_stacked_hist <- function(x = 1:nrow(data),data,width = 'auto',col = 'auto',ordered = TRUE)  {

  data[is.na(data)] <- 0

  if( !any( methods::is(data) == 'data.frame') ) stop('argument data must be data.frame or data.table')

  n_series <- ncol(data)
  n_index <- nrow(data)

  x_ind <- 1:n_index
  if(col[1] == 'auto') col <- rainbow(n_series)


  data_positive <- data * ( data < 0 )
  data_negative <- data * ( data > 0 )

  if(width[1] == 'auto') width = 0.2

  if(ordered) {
    ## positive values
    for(i in x_ind){
      current_row <- unlist(data_positive[i])
      curr_order <- order(current_row)
      ordered_row <- current_row[curr_order]
	  ordered_col <- col[curr_order]

	  current_bottom = 0
	  for(j in 1:n_series){
	    current_top <- current_bottom + ordered_row[j]
	    rect(x[i] - width, current_bottom, x[i] + width, current_top, col = ordered_col[j], border = ordered_col[j] )
	    current_bottom <- current_top
	  }
    }
    #negative values
    for(i in x_ind){
      current_row <- unlist(data_negative[i])
      curr_order <- order(-current_row)
      ordered_row <- current_row[curr_order]
	  ordered_col <- col[curr_order]

	  current_bottom = 0
	  for(j in 1:n_series){
	    current_top <- current_bottom + ordered_row[j]
	    rect(x[i] - width, current_bottom, x[i] + width, current_top, col = ordered_col[j], border = ordered_col[j] )
	    current_bottom <- current_top
	  }
    }
  }
  if(!ordered) {
    ## positive values
    current_bottom <- rep(0,n_index)
    for(i in 1:n_series ){
      current_top <- current_bottom + data_positive[[i]]
      rect(x - width, current_bottom, x + width, current_top, col = col[i], border = ordered_col[j] )
      current_bottom = current_top
    }
	## negative values
    current_bottom <- rep(0,n_index)
    for(i in 1:n_series ){
      current_top <- current_bottom + data_negative[[i]]
      rect(x - width, current_bottom, x + width, current_top, col = col[i], border = ordered_col[j] )
      current_bottom = current_top
    }
  }
}
