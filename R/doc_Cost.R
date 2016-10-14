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

#' c++ Trading Commissions class
#' @description c++ class documentation
#' @section Usage: \code{Cost = \{\}}
#' @param pointValue price point value ( 1 for stocks )
#' @param cancel absolute commission per order cancel
#' @param order absolute commission per order
#' @param stock absolute commission per stock / contract
#' @param tradeAbs absolute commission per trade
#' @param tradeRel relative commission per trade volume
#' @param longAbs absolute commission/refund per long position
#' @param longRel relative commission/refund per long volume
#' @param shortAbs absolute commission/refund per short position
#' @param shortRel relative commission/refund per short volume
#' @name Cost
#' @rdname cpp_Cost
#' @family backtesting classes
#' @family c++ classes
#' @section IMPORTANT:
#' Positive value means refund, negative value means cost!
NULL
