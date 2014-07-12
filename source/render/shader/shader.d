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
module render.shader.shader;

import std.range;

import derelict.opengl3.gl3;

import render.buffer.buffer;
import util.cinterface;

/// Represents shader type
enum ShaderType
{
    Vertex,
    Geometry,
    Fragment,
    TessellationControl,
    TessellationEvaluation,
}

/// Should be thrown when a compilation error occurs while compiling a shader
class ShaderCompilationException : Exception
{
    @safe pure nothrow this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
    
    @safe pure nothrow this(string msg, Throwable next, string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line, next);
    }
}

/**
*   Compile-time interface for GPU shader: vertex, fragment, geometry and etc.
*/
struct CIShader
{
    /// Return shader name
    enum string name = "";
    
    /// Returns shader type
    enum ShaderType type = ShaderType.Vertex;
    
    /// Returning source of this shader
    /**
    *   That symbol could be enum or a function that loads shader code from
    *   some file.
    */
    string source();
    
    /// Returns shader id (OpenGL)
    GLuint id();
    
    /// Compiles sources in the shader
    /**
    *   Should throw $(B ShaderCompilationException) on compilation errors.
    */
    void compile();      
    
    /**
    *   Enumeration that describes available slots for buffers
    *   (vertex, color, normal, etc) in the shader.
    *
    *   The each type value corresponds for one buffer slot.
    *
    *   The following buffers are binded to the shader at mesh level.
    */
    alias BufferSlot = int; // if(is(BufferSlot == enum))
    
    /**
    *   Binds $(B buffer) to specified $(B slot), that is defined by $(B BufferSlot)
    *   enumeration.
    */
    @trasient
    void bindBuffer(BufferSlot slot, Buffer)(Buffer buffer)
        if(isBuffer!Buffer);
        
    /**
    *   All binded buffers should be unbinded after rendering pass.
    */
    void unbindBuffers();
}

/// Checks if $(B T) is a shader program
template isShader(T)
{
    enum isShader = isExpose!(T, CIShader); 
}