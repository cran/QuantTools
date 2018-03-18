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

#' @title C++ Rolling Volume Profile class
#' @description C++ class documentation
#' @section Usage: \code{RollVolumeProfile( int timeFrame, double step, double alpha, double cut )}
#' @param timeFrame indicator period in seconds, when to apply alpha correction
#' @param step price round off value, bar width
#' @param alpha multiplication coefficient must be between (0,1]
#' @param cut threshold volume when to delete bar
#' @details R functions \link{roll_volume_profile}.
#' @family C++ indicators
#' @family C++ classes
#'
#' @section Public Members and Methods:
#' \tabular{lll}{
#' \strong{Name}                 \tab \strong{Return Type}          \tab \strong{Description}                                \cr
#' \code{Add( \link{Tick} tick )}\tab \code{void}                   \tab update indicator                                    \cr
#' \code{Reset()}                \tab \code{void}                   \tab reset to initial state                              \cr
#' \code{IsFormed()}             \tab \code{bool}                   \tab is indicator value valid?                           \cr
#' \code{GetValue()}             \tab \code{std::map<double,double>}\tab histogram where first is price and second is volume \cr
#' \code{GetHistory()}           \tab \code{List}                   \tab return values history data.table with columns \code{time, profile} where profile is data.table with columns \code{time, price, volume}
#' }
#'
#' @name RollVolumeProfile
#' @rdname cpp_RollVolumeProfile
NULL
