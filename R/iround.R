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

#' Round numbers to specified interval
#'
#' @param x numeric vector to be rounded
#' @param interval the interval the values should be rounded towards
#' @return A numeric vector with x rounded to the desired interval.
#' @name iround
#' @export
iround <- function(x, interval){

  interval[ifelse(x < min(interval), 1, findInterval(x, interval))]

}
