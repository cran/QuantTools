// Copyright (C) 2016 Stanislav Kovalevsky
//
// This file is part of QuantTools.
//
// QuantTools is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 2 of the License, or
// (at your option) any later version.
//
// QuantTools is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with QuantTools. If not, see <http://www.gnu.org/licenses/>.

#ifndef TRADE_H
#define TRADE_H

#include <Rcpp.h>
#include "Tick.h"
#include <vector>

enum class TradeSide: int { LONG, SHORT };

enum class TradeState: int { NEW, OPENED, CLOSED };

class Trade {
friend class Processor;

    TradeState state;
    int    idTrade    = NA_INTEGER - 1;
    int    idSent     = NA_INTEGER - 1;
    int    idEnter    = NA_INTEGER - 1;
    int    idExit     = NA_INTEGER - 1;
    TradeSide side;
    double priceEnter = NA_REAL;
    double priceExit  = NA_REAL;
    double timeSent   = NA_REAL;
    double timeEnter  = NA_REAL;
    double timeExit   = NA_REAL;
    double pnl        = NA_REAL;
    double mtmMin     = 0;
    double mtmMax     = 0;
    double cost       = 0;
    double pnlRel     = NA_REAL;
    double mtmMinRel  = 0;
    double mtmMaxRel  = 0;
    double costRel    = 0;

};

#endif //TRADE_H
