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

#' Add last values marks to the right of active time series plot
#'
#' @param data \code{data.frame} or \code{data.table} object of plotted data
#' @param ylim user specified range of \code{data}
#' @param col same as in \code{\link{plot_ts}}
#' @family graphical functions
#' @details Used in \code{\link{plot_ts}} internally.
#' @export
add_last_values <- function(data,ylim,col){

  round <- calc_decimal_resolution( axTicks(2) )

  last_non_na_row <- tail(which(rowSums(!is.na(data)) == ncol(data)),1)

  if(length(last_non_na_row) == 0) return()
  if(last_non_na_row != nrow(data)) return()

  last_values <- round( unlist( data[last_non_na_row,] ) , round )
  names(last_values) <- NULL

  at <- last_values
  at2 <- at[order(at)]
  steps <- diff(at2)
  steps_perc <- steps/diff(ylim)

  rel_str_height <- strheight(12345)/diff(ylim) + 0.01
  abs_str_height <- diff(ylim) * rel_str_height


  overlaps <- steps_perc < rel_str_height

  overlap_groups <- c(FALSE,overlaps)
  overlap_groups[which(overlap_groups)-1] <- TRUE


  z <- rle(overlap_groups)

  group_lengths <- z$length
  group_values <- z$values
  n_groups <- length(group_lengths)

  m <- cumsum(group_lengths)

  n <- c(1,m[-n_groups] + 1)

  groups <- mapply(':',n,m,SIMPLIFY = FALSE)


  at2corrected <- lapply(1:n_groups,function(i) if(group_values[i]){

    values <- at2[ groups[[i]] ]

    at_values <- seq(from = values[1],by = abs_str_height , length.out = group_lengths[i])

    at_offset <- mean(values) - mean(at_values)

    at_values <- at_values + at_offset

  } else at_values <- at2[ groups[[i]] ]  )

  at2corrected <- unlist(at2corrected)

  mtext(prettyNum(last_values[order(at)],' '),at = at2corrected,side = 4,cex = par('cex'),line = 0.5,las = 1,col = col[order(at)])
}
