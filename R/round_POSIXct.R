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


#' Round POSIXct timestamps
#'
#' @param x POSIXct vector
#' @param units to round off to
#' @param type \code{floor} or \code{ceiling}
#' @details
#' Rounds POSIXct vector.
#'
#'
#' @export
round_POSIXct <- function(x, units = c('seconds',"minutes", "5min", "10min", "15min", "30min","hour","day"), type = 'floor' ){
  if(is.numeric(units)) units <- as.character(units)

  units <- match.arg(units)

  if(units == 'day') return(as.Date(x))

  r <- switch(units,
    "seconds" = 1,
    "minutes" = 60,
    "5min"  = 60*5,
    "10min" = 60*10,
    "15min" = 60*15,
    "30min" = 60*30,
    "hour"  = 60*60
  )

  res <- as.numeric(x) - (as.numeric(x) %% r) + r * (type == 'ceiling')
  ret <- as.POSIXct( res,origin = '1970-01-01', tz = attributes(x)$tzone )

  return(ret)
}
