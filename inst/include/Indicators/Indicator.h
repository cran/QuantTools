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

#ifndef INDICATOR_H
#define INDICATOR_H

template < typename Input, typename Value, typename History >
class Indicator {

public:
  virtual void Add( Input ) = 0;
  virtual void Reset() = 0;
  virtual bool IsFormed() = 0;
  virtual History GetHistory() = 0;

};

#endif //INDICATOR_H
