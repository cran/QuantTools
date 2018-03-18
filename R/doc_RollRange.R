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

#' @title C++ Rolling Range / Quantile class
#' @description C++ class documentation
#' @section Usage: \code{RollRange( int n, double p = 0.5 )}
#' @param n indicator period
#' @param p probability value \code{[0, 1]}
#' @details R functions \link{roll_range}, \link{roll_quantile}, \link{roll_min}, \link{roll_max}.
#' @family C++ indicators
#' @family C++ classes
#'
#' @section Public Members and Methods:
#' \tabular{lll}{
#'  \strong{Name}                 \tab \strong{Return Type}        \tab \strong{Description}                         \cr
#'  \code{Add( InputType value )} \tab \code{void}                 \tab update indicator                             \cr
#'  \code{Reset()}                \tab \code{void}                 \tab reset to initial state                       \cr
#'  \code{IsFormed()}             \tab \code{bool}                 \tab is indicator value valid?                    \cr
#'  \code{GetValue()}             \tab \code{Range}                \tab has members \code{double min, max, quantile} \cr
#'  \code{GetMinHistory()}        \tab \code{std::vector< double >}\tab return min history                           \cr
#'  \code{GetMaxHistory()}        \tab \code{std::vector< double >}\tab return max history                           \cr
#'  \code{GetQuantileHistory()}   \tab \code{std::vector< double >}\tab return quantile history                      \cr
#'  \code{GetHistory()}           \tab \code{List}                 \tab return values history data.table with columns \code{min, max}
#' }
#'
#' @name RollRange
#' @rdname cpp_RollRange
NULL
