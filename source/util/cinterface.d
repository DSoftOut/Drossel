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
module util.cinterface;

import std.traits;
import std.typetuple;

import util.functional;

/// UDA if you don't want to match element in interface
enum trasient;

/**
*   Checks $(B Type) to satisfy compile-time interfaces listed in $(B Interfaces). 
*
*   $(B Type) should expose all methods and fields that are defined in each interface.
*   Compile-time interface description is struct with fields and methods without 
*   implementation. There are no implementations to not use the struct in usual way,
*   linker will stop you. 
*
*   Overloaded methods are handled as expected. Check is provided by name, return type and
*   parameters types of the method that is looked up.
*/
template isExpose(Type, Interfaces...)
{
    private template getMembers(T)
    {
        alias getMembers = List!(__traits(allMembers, T));
    }
    
    private template isExposeSingle(Interface)
    {
        alias intMembers = StrictList!(Filter!(filterTrasient, fieldsAndMethods!Interface));
        alias intTypes = StrictList!(staticReplicate!(Interface, intMembers.expand.length)); 
        alias pairs = staticMap2!(bindType, staticRobin!(intTypes, intMembers)); 
    
        private template filterTrasient(string name) // and aliases
        {
        	static if(is(typeof(__traits(getMember, Interface, name))))
        	{
        		enum filterTrasient 
        			= staticIndexOf!(trasient, __traits(getAttributes, __traits(getMember, Interface, name))) == -1;
			}
        	else
        	{
        		enum filterTrasient = false;
        	}
        }
        
        private template bindType(Base, string T) // also expanding overloads
        {
            private template getType(alias T)
            {
                alias getType = typeof(T);
            }
            
            alias overloads_ = staticMap!(getType , List!(__traits(getOverloads, Base, T)));
            static if(overloads_.length == 0)
                alias overloads = List!(typeof(__traits(getMember, Base, T)));
            else
                alias overloads = overloads_;
                            
            alias names = staticReplicate!(T, overloads.length);
            alias bindType = staticRobin!(StrictList!overloads, StrictList!names);
        }
        
        template checkMember(MemberType, string MemberName)
        {
            static if(hasMember!(Type, MemberName))
            { 
                enum checkMember = hasOverload!(Type, Unqual!MemberType, MemberName);
            }
            else
            { 
                enum checkMember = false;
            }
        }
        
        enum isExposeSingle = allSatisfy2!(checkMember, pairs); 
    }
    
    enum isExpose = allSatisfy!(isExposeSingle, Interfaces);
}
/// Example
version(unittest)
{
    struct CITest1
    {
        string a;
        string meth1();
        bool meth2();
    }
    
    struct CITest2
    {
        bool delegate(string) meth3();
    }
    
    struct CITest3
    {
        bool meth1();
    }
    
    struct Test1
    {
        string meth1() {return "";}
        bool meth2() {return true;}
        
        string a;
        
        bool delegate(string) meth3() { return (string) {return true;}; };
    }
    
    static assert(isExpose!(Test1, CITest1, CITest2));
    static assert(!isExpose!(Test1, CITest3));
    
    struct CITest4
    {
        bool meth1();
        int  meth1();
    }
    
    struct Test2
    {
        bool meth1() {return true;}
    }
    
    static assert(!isExpose!(Test2, CITest4));
    
    struct CITest5
    {
        immutable string const1;
        immutable bool const2;
    }
    
    struct Test3
    {
        enum const1 = "";
        enum const2 = true;
    }
    
    static assert(isExpose!(Test3, CITest5));
    
    struct CITest6
    {
        
    }
    static assert(isExpose!(Test3, CITest6));
}