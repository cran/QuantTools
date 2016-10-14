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

#ifndef COST_H
#define COST_H

class Cost {

public:

  double cancel     = 0; // absolute commission per order cancel
  double order      = 0; // absolute commission per order
  double tradeAbs   = 0; // absolute commission per trade
  double stockAbs   = 0; // absolute commission per stock / contract
  double tradeRel   = 0; // relative commission per trade volume
  double longAbs    = 0; // absolute commission/refund per long position
  double longRel    = 0; // relative commission/refund per long volume
  double shortAbs   = 0; // absolute commission/refund per short position
  double shortRel   = 0; // relative commission/refund per short volume
  double pointValue = 1; // absolute point value ( 1 for stocks )

};

#endif //COST_H
