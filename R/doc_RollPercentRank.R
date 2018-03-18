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

#' @title C++ Rolling Percent Rank class
#' @description C++ class documentation
#' @section Usage: \code{RollPercentRank( int n )}
#' @param n indicator period
#' @family C++ indicators
#' @family C++ classes
#'
#' @section Public Members and Methods:
#' \tabular{lll}{
#'  \strong{Name}                 \tab \strong{Return Type}        \tab \strong{Description}      \cr
#'  \code{Add( InputType value )} \tab \code{void}                 \tab update indicator          \cr
#'  \code{Reset()}                \tab \code{void}                 \tab reset to initial state    \cr
#'  \code{IsFormed()}             \tab \code{bool}                 \tab is indicator value valid? \cr
#'  \code{GetHistory()}           \tab \code{std::vector<double>}  \tab history vector
#' }
#'
#' @name RollPercentRank
#' @rdname cpp_RollPercentRank
NULL
