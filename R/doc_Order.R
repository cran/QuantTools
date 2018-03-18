# Copyright (C) 2016-2018 Stanislav Kovalevsky
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

#' @title C++ Order class
#' @description C++ class documentation
#' @section Usage: \code{Order( OrderSide side, OrderType type, double price, std::string comment, int idTrade )}
#' @param side \code{BUY} or \code{SELL}
#' @param type \code{LIMIT}, \code{MARKET}, \code{STOP}, \code{TRAIL}
#' @param price limit order price level, ignored for market orders
#' @param comment arbitrary comment
#' @param idTrade trade id for grouping multiple orders into trades
#' @family backtesting classes
#' @family C++ classes
#'
#' @section Public Members and Methods:
#' \tabular{lll}{
#'   \strong{Name}             \tab \strong{Return Type} \tab \strong{Description}                                                                                  \cr
#'   \code{isNew()}            \tab \code{bool}          \tab order is new or just sent to exchange?                                                                \cr
#'   \code{isRegistered()}     \tab \code{bool}          \tab placement confirmation received from exchange?                                                        \cr
#'   \code{isCancelling()}     \tab \code{bool}          \tab cancel request sent to exchange?                                                                      \cr
#'   \code{isCancelled()}      \tab \code{bool}          \tab cancel confirmation received from exchange?                                                           \cr
#'   \code{isExecuted()}       \tab \code{bool}          \tab execution confirmation received from exchange?                                                        \cr
#'   \code{isBuy?}             \tab \code{bool}          \tab buy order?                                                                                            \cr
#'   \code{isSell?}            \tab \code{bool}          \tab sell order?                                                                                           \cr
#'   \code{isLimit?}           \tab \code{bool}          \tab limit order?                                                                                          \cr
#'   \code{isMarket?}          \tab \code{bool}          \tab market order?                                                                                         \cr
#'   \code{GetTradeId()}       \tab \code{int}           \tab trade id for grouping multiple orders into trades                                                     \cr
#'   \code{GetExecutionPrice()}\tab \code{double}        \tab execution price, price for limit order and market price for market order                              \cr
#'   \code{GetExecutionTime()} \tab \code{double}        \tab execution time                                                                                        \cr
#'   \code{GetProcessedTime()} \tab \code{double}        \tab processed time                                                                                        \cr
#'   \code{GetState()}         \tab \code{OrderState}    \tab order state                                                                                           \cr
#'   \code{comment}            \tab \code{std::string}   \tab arbitrary comment, useful to identify order when analyzing backtest results                           \cr
#'   \code{onExecuted}         \tab \code{std::function} \tab called when execution confirmation received from exchange                                             \cr
#'   \code{onCancelled}        \tab \code{std::function} \tab called when cancellation confirmation received from exchange                                          \cr
#'   \code{onRegistered}       \tab \code{std::function} \tab called when placement confirmation received from exchange                                             \cr
#'   \code{onCancelFailed}     \tab \code{std::function} \tab called when execution confirmation received from exchange but order was about to cancel               \cr
#'   \code{Cancel()}           \tab \code{void}          \tab sends cancel request to exchange if \code{state} is \code{REGISTERED} and \code{type} is \code{LIMIT}
#' }
#' @name Order
#' @rdname cpp_Order
NULL

