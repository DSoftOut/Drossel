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
module math.vec;

import std.conv;
import std.traits;
import util.functional;

/// Alias for vector of 1 elements
alias vec1(T) = Vector!(T, 1);
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
    
    /// Operators for per-element operations
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
    
    /// Indexing vector
    Element opIndex(size_t i)
    {
        assert(i < n, text("Overload opIndex ", i, " >= ", n));
        return elements[i];
    }
    
    /// Indexing vector
    const(Element) opIndex(size_t i) const
    {
        assert(i < n, text("Overload opIndex ", i, " >= ", n));
        return elements[i];
    }
    
    /// Assign specific component
    ref Vector!(Element, n) opIndexAssign(Element e, size_t i)
    {
        assert(i < n, text("Overload opIndexAssign ", i, " >= ", n));
        elements[i] = e;
        return this;
    }
    
    /// Is some char is a vector component name
    private template isElement(char c)
    {
        static if(n == 0) {
            enum isElement = false;
        }
        else static if(n == 1) {
            enum isElement = c == 'x';
        } 
        else static if(n == 2) {
            enum isElement = c == 'x' || c == 'y';
        }
        else static if(n == 3) {
            enum isElement = c == 'x' || c == 'y' || c == 'z';
        }
        else static if(n >= 4) {
            enum isElement = c == 'x' || c == 'y' || c == 'z' || c == 'w';
        }
    }
    
    private template isConstant(char c)
    {
        enum isConstant = c >= '0' && c <= '9';
    }

    private template allElementsOrConstants(string s)
    {
        
        private template or(alias A, alias B)
        {
            template inner(char c)
            {
                enum inner = A!(c) || B!(c);
            }
            
            alias or = inner;
        }
        
        private template allSatisfyString(alias F, string s)
        {
            static if(s.length == 0) {
                enum allSatisfyString = true;
            } else {
                enum allSatisfyString = F!(s[0]) && allSatisfyString!(F, s[1 .. $]);
            }
        }
        
        enum allElementsOrConstants = allSatisfyString!(or!(isElement, isConstant), s);
    }
    
    /// Comparing vectors with equal sizes
    bool opEquals(OtherElement)(auto ref const Vector!(OtherElement, n) vec) const 
        if(__traits(compiles, Element.init == OtherElement.init))
    {
        bool res = true;
        foreach(i; Iota!n)
        {
            res = res && this[i] == vec[i];
        }
        return res;
    }
    
    /**
    *   Generates new vector from pattern $(B op).
    *
    *   Each char of $(B op) is a name of component of old vector
    *   or a constant (0 to 9, one char).
    *
    *   Example:
    *   ----------
    *   auto vec = vec4!int(1, 2, 3, 4);
    *
    *   assert(vec.x1 == vec2!int(1, 1));
    *   assert(vec.x0 == vec2!int(1, 0));
    *   assert(vec.xy == vec2!int(1, 2));
    *   assert(vec.yx == vec2!int(2, 1));
    *   assert(vec.xy0z == vec4!int(1, 2, 0, 3));
    *   assert(vec.xyzw == vec4!int(1, 2, 3, 4));
    *   ----------
    */
    auto opDispatch(string op)()
        if(allElementsOrConstants!op)
    {
        enum newn = op.length;
        Vector!(Element, newn) newvec;
        
        foreach(i; Iota!newn)
        {
            enum c = op[i];
            static if(isElement!c)
                newvec[i] = mixin("this." ~ c);
            else static if(isConstant!c)
                 newvec[i] = [c].to!Element;
        }
        
        return newvec;
    }
}
unittest
{
    auto vec = vec4!int(1, 2, 3, 4);
    assert(vec.opDispatch!"x1" == vec2!int(1, 1));
    assert(vec.x1 == vec2!int(1, 1));
    assert(vec.x0 == vec2!int(1, 0));
    assert(vec.xy == vec2!int(1, 2));
    assert(vec.yx == vec2!int(2, 1));
    assert(vec.xy0z == vec4!int(1, 2, 0, 3));
    assert(vec.xyzw == vec4!int(1, 2, 3, 4));
}