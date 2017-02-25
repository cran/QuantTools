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

#' Add legend to active time series plot
#'
#' @param position same as in \code{\link{plot_ts}} except \code{'n'}
#' @param names line labels
#' @param col same as in \code{\link{plot_ts}}
#' @param lty,lwd same as in \code{\link[graphics]{lines}}
#' @param pch same as in \code{\link[graphics]{points}}
#' @family graphical functions
#' @details Used in \code{\link{plot_ts}} internally.
#' @export
add_legend <- function(position = 'topright', names, col = 'auto', lty = 1, lwd = 1, pch = NA){

  if(col[1] == 'auto')col <- rainbow(length(names))
  legend(x = position,legend = names, col = col ,lty = lty,pch = pch,lwd = ifelse(lwd > 3,1,lwd),bg = rgb(1,1,1,0.8),box.col = rgb(1,1,1,0),inset = 0.01)
  return(NULL)
}
