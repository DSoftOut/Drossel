// written in the D programming language
/*
*   This file is part of DrossyStars.
*   
*   DrossyStars is free software: you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation, either version 3 of the License, or
*   (at your option) any later version.
*   
*   DrossyStars is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*   
*   You should have received a copy of the GNU General Public License
*   along with DrossyStars.  If not, see <http://www.gnu.org/licenses/>.
*/
/**
*   Copyright: © 2014 Anton Gushcha
*   License: Subject to the terms of the GPL-3.0 license, as written in the included LICENSE file.
*   Authors: Anton Gushcha <ncrashed@gmail.com>
*/
module render.input.mods;

import std.bitmanip;
import std.conv;

/// Wrapper around bitfield modificator stored in a uint
/**
*
*/
struct Modificators
{
    mixin(bitfields!(
        bool, "shift",   1,
        bool, "control", 1,    
        bool, "alt",     1,
        bool, "_super",   1,
        uint, "",        uint.sizeof*8 - 4   
        ));
    
    static assert(Modificators.sizeof == uint.sizeof);
    
    /// Reading modificators from raw value
    /**
    *   This method expects that bit orders is same for
    *   $(B mods) and this representation.
    */
    static Modificators fromBitfield(uint mods)
    {
        return (cast(Modificators*)&mods)[0];
    }
    
    /// Creating modificators from unpacked data
    this(bool shift = false, bool control = false, bool alt = false, bool _super = false)
    {
        this.shift = shift;
        this.control = control;
        this.alt = alt;
        this._super = _super;
    }
    
    /// Casting self to raw uint value
    uint toBitfield()
    {
        return (cast(uint*)&this)[0];
    }
    
    void toString(scope void delegate(const(char)[]) sink) const
    {
        sink("Modificators(");
        sink("shift: "); sink(shift.to!string);
        sink(" control: "); sink(control.to!string);
        sink(" alt: "); sink(alt.to!string);
        sink(" super: "); sink(_super.to!string); 
        sink(")");
    }
}
/// Example
unittest
{
    auto mods = Modificators.fromBitfield(0x1 | 0x4);
    assert(mods.shift && mods.alt);
    
    mods.shift = false;
    mods._super = true;
    
    assert(mods.alt && mods._super);
    assert(mods.toBitfield == (0x4 | 0x8));
}
unittest
{
    assert(Modificators.fromBitfield(0x1).shift);
    assert(Modificators.fromBitfield(0x2).control);
    assert(Modificators.fromBitfield(0x4).alt);
    assert(Modificators.fromBitfield(0x8)._super);
}
