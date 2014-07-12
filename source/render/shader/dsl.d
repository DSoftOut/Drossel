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
*   Helper templates to organize OpenGL code and separates it into modules.
*/
module render.shader.dsl;

/**
*   Expression list for holding pairs of (parameter name, parameter value).
*
*   The template shouldn't be used outside $(B Shader) template,
*   the only purpose is collect pairs in one argument.
*/
template ParamList(T...)
{
    static assert(T.length % 2 == 0, "Expecting pairs of (variable_name, value)");
    static assert(checkTypes!T, "Expecting pairs of (string, some value convertable to string)");

    import std.conv;
    import std.array;
    import std.traits;
    
    /// Checks types of input pairs
    private template checkTypes(T...)
    {
        static if(T.length == 0)
            enum checkTypes = true;
        else
        {
            enum checkTypes =  is(typeof(T[0]) == string) 
                            && __traits(compiles, T[1].to!string) || __traits(compiles, T[1].stringof)
                            && checkTypes!(T[2 .. $]);
        }
    }
    
    /// Count of pairs
    enum length = T.length / 2;
    
    /// Name of i-th parameter
    template paramName(TS...)
    {
        static assert(isUnsigned!(typeof(TS[0])), "Expecting index of type unsigned integral");
        enum i = TS[0];
        
        enum paramName = T[i*2];
    }
    
    /// String value of i-th parameter
    template paramValue(TS...)
    {
        static assert(isUnsigned!(typeof(TS[0])), "Expecting index of type unsigned integral");
        enum i = TS[0];
        
        static if(__traits(compiles, T[i*2 + 1].to!string))
        {
            enum paramValue = T[i*2 + 1].to!string;
        }
        else static if(__traits(compiles, T[i*2 + 1].stringof))
        {
            enum paramValue = T[i*2 + 1].stringof;
        }
    }
    
    /// Performs replacing of all parameters placeholders for corresponding values
    string insertValues(string source)
    {
        string temp = source;
        foreach(ii, _T; T)
        {
            enum i = ii / 2;
            temp = replace(temp, paramName!i, paramValue!i);
        }
        return temp;
    }
}
/// Example
unittest
{
    alias ParamShader = Shader!("ShaderParam", ParamList!("AVALUE", "a", "BVALUE", "b"), q{AVALUE * BVALUE});
    static assert(ParamShader.sources == "a * b");
}

/**
*   Helps to organize D-like module structure for OpenGL shaders:
*   dependencies are included only once.
*
*   Shader are defined as:
*   - list of dependent shaders
*   - name literal (unique for one shader)
*   - shader source code
* 
*   Example:
*   ----------
*   alias Shader1 = Shader!("Shader1", q{it is Shader 1});
*   alias Shader2 = Shader!(Shader1, "Shader2", q{it is Shader 2});
*   alias Shader3 = Shader!(Shader1, "Shader3", q{it is Shader 3});
*   alias Shader4 = Shader!(Shader2, Shader3, "Shader4", q{it is Shader 4});
*   // printing all sources including dependencies
*   pragma(msg, Shader4.sources);
*
*   // Shaders can have parameters 
*   alias ParamShader = Shader!(Shader4, "ShaderParam", ParamList!("AVALUE", "a", "BVALUE", "b"), q{ AVALUE * BVALUE });
*   pragma(msg, ParamShader.sources);
*   ----------
*/
template Shader(TS...)
{
    static assert(TS.length >= 2);
    
    static if(is( typeof(TS[$-2]) == string) )
    {
        private enum hasParams = false; 
        enum shaderName   = TS[$-2];
        private enum shaderSource = TS[$-1];
        alias dependentShaders = TS[0 .. $-2];
    } else
    {
        private enum hasParams = true;
        alias params = TS[$-2];
        enum shaderName   = TS[$-3];
        private enum shaderSource = TS[$-1];
        alias dependentShaders = TS[0 .. $-3];
    }
    
    /// Builds lis of unique dependencies
    private template makeDepends()
    {
        private template inner1(TSS...)
        {
            static if(TSS.length <= 1)
            {
                alias inner1 = ExpressionList!();
            }
            else
            {
                enum savedLength = TSS[0];
                alias saved = TSS[1 .. savedLength+1];
                alias TS = TSS[savedLength+1 .. $];
                
                static if(TS.length == 0)
                {
                    alias inner1 = saved;
                }
                else
                {
                    alias currDep = TS[0]; 
                    alias newDeps = ExpressionList!(currDep.makeDepends!(), currDep);

                    static if(newDeps.length == 0)
                    {
                        alias inner1 = addNext!(savedLength, saved, currDep);
                    }
                    else
                    {
                        alias temp = addNext!(savedLength, saved, newDeps);
                        alias inner1 = inner1!(temp.length, temp, TS[1..$]);
                    }
                }
            }
        }
        
        private template isAdded(TS...)
        {
            alias T = TS[0];
            
            private template Inner(TS...)
            {
                static if(TS.length == 0)
                {
                    enum Inner = false;
                }
                else
                {
                    static if(TS[0].shaderName == T.shaderName)
                    {
                        enum Inner = true;
                    }
                    else
                    {
                        enum Inner = Inner!(TS[1 .. $]);
                    }
                }
            }
           
            enum isAdded = Inner!(TS[1 .. $]);
        }
        
        private template addNext(TS...)
        {
            enum dependsLength = TS[0];
            alias depends = TS[1 .. dependsLength+1];
            alias toadd = TS[1+dependsLength .. $];
            
            private template Inner(TS...)
            {
                static if(TS.length == 0)
                {
                    alias Inner = ExpressionList!();
                }
                else
                {
                    static if(isAdded!(TS[0], depends))
                    {
                        alias Inner = Inner!(TS[1..$]);
                    }
                    else
                    {
                        alias Inner = ExpressionList!(TS[0], Inner!(TS[1..$]));
                    } 
                }
            }
            
            alias addNext = ExpressionList!(depends, Inner!toadd);

        }
        
        alias makeDepends = inner1!(0, dependentShaders);
    }
    
    private template MakeDepsSource(TS...)
    {
        static if(TS.length == 0)
        {
            enum MakeDepsSource = "";
        }
        else
        {
            static if(!TS[0].hasParams)
            {
                enum MakeDepsSource = TS[0].shaderSource ~ "\n" 
                    ~ MakeDepsSource!(TS[1..$]);
            }
            else
            {
                enum MakeDepsSource = TS[0].params.insertValues(TS[0].shaderSource) ~ "\n" 
                    ~ MakeDepsSource!(TS[1..$]);
            }
        }
    }
    
    static if(!hasParams)
    {
        enum sources = MakeDepsSource!(makeDepends!()) ~ shaderSource;
    }
    else
    {
        enum sources = MakeDepsSource!(makeDepends!()) ~ params.insertValues(shaderSource);
    }
}

private:

template ExpressionList(E...)
{
    alias ExpressionList = E;
}

private template MapNames(TS...)
{
    static if(TS.length == 0)
    {
        alias MapNames = ExpressionList!();
    }
    else
    {
        alias MapNames = ExpressionList!(TS[0].shaderName, MapNames!(TS[1..$]));
    }
}