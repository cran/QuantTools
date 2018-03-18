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

#' @title C++ Stochastic class
#' @description C++ class documentation
#' @section Usage: \code{Stochastic< InputType >( int n, int nFast, int nSlow )}
#' @param InputType \code{Tick} or \code{ double }
#' @param n indicator period
#' @param nFast fast smooth
#' @param nSlow slow smooth
#' @details R function \link{stochastic}.
#' @family C++ indicators
#' @family C++ classes
#'
#' @section Public Members and Methods:
#' \tabular{lll}{
#'  \strong{Name}                 \tab \strong{Return Type}        \tab \strong{Description}                                                       \cr
#'  \code{Add( InputType value )} \tab \code{void}                 \tab update indicator                                                           \cr
#'  \code{Reset()}                \tab \code{void}                 \tab reset to initial state                                                     \cr
#'  \code{IsFormed()}             \tab \code{bool}                 \tab is indicator value valid?                                                  \cr
#'  \code{GetValue()}             \tab \code{StochasticValue}      \tab has members \code{double kFast, dFast, dSlow}                              \cr
#'  \code{GetKFastnHistory()}     \tab \code{std::vector< double >}\tab return k fast history                                                      \cr
#'  \code{GetDFastHistory()}      \tab \code{std::vector< double >}\tab return d fast history                                                      \cr
#'  \code{GetDSlowHistory()}      \tab \code{std::vector< double >}\tab return d slow history                                                      \cr
#'  \code{GetHistory()}           \tab \code{List}                 \tab return values history data.table with columns \code{k_fast, d_fast, d_slow}
#' }
#'
#' @name Stochastic
#' @rdname cpp_Stochastic
NULL
