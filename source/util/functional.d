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
module util.functional;

import std.typetuple;

/**
*   Simple expression tuple wrapper.
*
*   See_Also: Expression tuple at dlang.org documentation.
*/
template Tuple(T...)
{
    alias Tuple = T;
}
/// Example
unittest
{
    static assert([Tuple!(1, 2, 3)] == [1, 2, 3]);
}

/**
*   Sometimes we don't want to auto expand expression tuples.
*   That can be used to pass several tuples into templates without
*   breaking their boundaries.
*/
template StrictTuple(T...)
{
    template expand()
    {
        alias expand = T;
    }
}
/// Example
unittest
{
    template Test(alias T1, alias T2)
    {
        static assert([T1.expand!()] == [1, 2]);
        static assert([T2.expand!()] == [3, 4]);
        enum Test = true;
    }
    
    static assert(Test!(StrictTuple!(1, 2), StrictTuple!(3, 4)));
}

/**
*   Same as std.typetuple.staticMap, but passes two arguments to the first template.
*/
template staticMap2(alias F, T...)
{
    static assert(T.length % 2 == 0);
    
    static if (T.length < 2)
    {
        alias staticMap2 = Tuple!();
    }
    else static if (T.length == 2)
    {
        alias staticMap2 = Tuple!(F!(T[0], T[1]));
    }
    else
    {
        alias staticMap2 = Tuple!(F!(T[0], T[1]), staticMap2!(F, T[2  .. $]));
    }
}
/// Example
unittest
{
    template Test(T...)
    {
        enum Test = T[0] && T[1];
    }
    
    static assert([staticMap2!(Test, true, true, true, false)] == [true, false]);
}

/**
*   Same as std.typetuple.allSatisfy, but passes 2 arguments to the first template.
*/
template allSatisfy2(alias F, T...)
{
    static assert(T.length % 2 == 0);
    
    static if (T.length < 2)
    {
        enum allSatisfy2 = true;
    }
    else static if (T.length == 2)
    {
        enum allSatisfy2 = F!(T[0], T[1]);
    }
    else
    {
        enum allSatisfy2 = F!(T[0], T[1]) && allSatisfy2!(F, T[2  .. $]);
    }
}
/// Example
unittest
{
    template Test(T...)
    {
        enum Test = is(typeof(T[0]) == string) && is(typeof(T[1]) == bool);
    }
    
    static assert(allSatisfy2!(Test, "42", true, "108", false));
}

/**
*   Replicates first argument by times specified by second argument.
*/
template staticReplicate(TS...)
{
    static if(is(TS[0]))
        alias T = TS[0];
    else
        enum T = TS[0];
        
    enum n = TS[1];
    
    static if(n > 0)
    {
        alias staticReplicate = Tuple!(T, staticReplicate!(T, n-1));
    }
    else
    {
        alias staticReplicate = Tuple!();
    }
} 
/// Example
unittest
{    
    template isBool(T)
    {
        enum isBool = is(T == bool);
    }
    
    static assert(allSatisfy!(isBool, staticReplicate!(bool, 2))); 
    static assert([staticReplicate!("42", 3)] == ["42", "42", "42"]);
}

/**
*   Static version of std.algorithm.reduce (or fold). Expects that $(B F)
*   takes accumulator as first argument and a value as second argument.
*
*   First value of $(B T) have to be a initial value of accumulator.
*/
template staticFold(alias F, T...)
{
    static if(T.length == 0) // invalid input
    {
        alias staticFold = Tuple!(); 
    }
    else static if(T.length == 1)
    {
        static if(is(T[0]))
            alias staticFold = T[0];
        else
            enum staticFold = T[0];
    }
    else 
    {
        alias staticFold = staticFold!(F, F!(T[0], T[1]), T[2 .. $]);
    }
}
/// Example
unittest
{
    template summ(T...)
    {
        enum summ = T[0] + T[1];
    }
    
    static assert(staticFold!(summ, 0, 1, 2, 3, 4) == 10);
    
    template preferString(T...)
    {
        static if(is(T[0] == string))
            alias preferString = T[0];
        else
            alias preferString = T[1];
    }
    
    static assert(is(staticFold!(preferString, void, int, string, bool) == string));
    static assert(is(staticFold!(preferString, void, int, double, bool) == bool));
}

template staticRobin(SF...)
{
    // Calculating minimum length of all tuples
    private template minimum(T...)
    {
        enum length = T[1].expand!().length;
        enum minimum = T[0] > length ? length : T[0];
    }
    
    enum minLength = staticFold!(minimum, size_t.max, SF);
    
    private template robin(NS...)
    {
        enum i = NS[0];
        
        private template takeByIndex(alias T)
        {
            static if(is(T.expand!()[i]))
                alias takeByIndex = T.expand!()[i];
            else
                enum takeByIndex = T.expand!()[i];
        }
        
        static if(i >= minLength)
        {
            alias robin = Tuple!();
        }
        else
        {
            alias robin = Tuple!(staticMap!(takeByIndex, SF), robin!(i+1));
        }
    }
    
    alias staticRobin = robin!0; 
}
/// Example
unittest
{
    alias test = staticRobin!(StrictTuple!(int, int, int), StrictTuple!(float, float));
    static assert(is(test == Tuple!(int, float, int, float)));
    
    alias test2 = staticRobin!(StrictTuple!(1, 2), StrictTuple!(3, 4, 5), StrictTuple!(6, 7));
    static assert([test2]== [1, 3, 6, 2, 4, 7]);
}