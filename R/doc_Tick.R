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

#' @title C++ Tick class
#' @description C++ class documentation
#' @section Usage: \code{Tick{ int id, double time, double price, int volume, double bid, double ask, bool system }}
#' @param id id
#' @param time seconds since epoch
#' @param price price
#' @param volume volume
#' @param bid best bid
#' @param ask best offer
#' @param system \code{true} ignore all except \code{time} and \code{id} value, default is \code{false}
#' @name Tick
#' @rdname cpp_Tick
#' @family backtesting classes
#' @family C++ classes
NULL
