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

alias vec2(T) = Vector!(T, 2);
alias vec3(T) = Vector!(T, 3);

struct Vector(Element, size_t n)
{
    Element[n] elements;
    
    this(Element[n] args ...)
    {
        elements = args;
    }
    
    static if(n >= 1)
    {
        Element x() { return elements[0]; }
        const(Element) x() const { return elements[0]; }
    }
    
    static if(n >= 2)
    {
        Element y() { return elements[1]; }
        const(Element) y() const { return elements[1]; }
    }
    
    static if(n >= 3)
    {
        Element z() { return elements[2]; }
        const(Element) z() const { return elements[2]; }
    }
    
    static if(n >= 4)
    {
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
} 