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
*
*   Template for fixed size vector, also used to operate in math functions.
*/
module util.vec;

import std.traits;
import std.conv;

/// Alias for vector of 2 elements
alias vec2(T) = Vector!(T, 2);
/// Alias for vector of 3 elements
alias vec3(T) = Vector!(T, 3);
/// Alias for vector of 4 elements
alias vec4(T) = Vector!(T, 4);
/// Alias for vector of 5 elements
alias vec5(T) = Vector!(T, 5);
/// Alias for vector of 6 elements
alias vec6(T) = Vector!(T, 6);
/// Alias for vector of 7 elements
alias vec7(T) = Vector!(T, 7);

/**
*   Constant size equal $(B n) vector with elements
*   of type $(B Element).
*/
struct Vector(Element, size_t n)
{
    /// Piece of memory wher elements are stored
    Element[n] elements;
    
    /// Creating from passed arguments
    this(Element[n] args ...)
    {
        elements = args;
    }
    
    static if(n >= 1)
    {
        /// Returning first element
        Element x() { return elements[0]; }
        const(Element) x() const { return elements[0]; }
    }
    
    static if(n >= 2)
    {
        /// Returning second element
        Element y() { return elements[1]; }
        const(Element) y() const { return elements[1]; }
    }
    
    static if(n >= 3)
    {
        /// Returning third element
        Element z() { return elements[2]; }
        const(Element) z() const { return elements[2]; }
    }
    
    static if(n >= 4)
    {
        /// Returning fourth element
        Element w() { return elements[3]; }
        const(Element) w() const { return elements[3]; }
    }
    
    /// fastest variant
    void toString(scope void delegate(const(char)[]) sink) const
    {
        sink("(");
        static if(n > 0)
        {
            foreach(e; elements[0 .. $-1])
            {
                sink(e.to!string);
                sink(",");
            }
            sink(elements[$-1].to!string);
        }
        sink(")");
    }
    
    auto opBinary(string op, OtherElement)(Vector!(OtherElement, n) vec)
        if((op == "-" || op == "+" || op == "/" || op == "*") &&
            __traits(compiles, Element.init / OtherElement.init))
    {
        alias NewElement = typeof(Element.init / OtherElement.init);
        
        NewElement[n] buff;
        foreach(i, ref elem; buff)
            elem = mixin(`elements[i] `~op~`vec.elements[i]`);
            
        return Vector!(NewElement, n)(buff);
    }
} 