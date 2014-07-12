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
module render.shader.program;

import derelict.opengl3.gl3;

import render.shader.shader;
import util.cinterface;
import util.functional;

/// Should be thrown when a linking error occurs while linking a GPU program
class ProgramLinkingException : Exception
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
*   Compile-time interface for GPU shader program.
*
*   Consists of several shaders built into a pipeline.
*/
struct CIShaderProgram
{
    /// GPU program name
    enum string name = "";
    
    /// GPU program id (OpenGL)
    GLuint id();
    
    /**
    *   Setting specific element of rendering pipeline.
    *
    *   By default no shader is set.
    *
    *   Note: In this interface KeyValueList is demonstrates
    *   that keys should be of type ShaderType and CIShader is some
    *   shader.
    */
    @trasient
    alias pipeline = KeyValueList!(ShaderType, CIShader);
    
    /**
    *   Compiles all elements of rendering pipeline.
    *   
    *   Throws: ShaderCompilationException
    */
    void compile();
    
    /**
    *   Performs linking elements of rendering pipeline into
    *   one program.
    *
    *   Throws: ProgramLinkingException
    */
    void link();
}

/// Checks if $(B T) is a shader program
template isShaderProgram(T)
{
    enum isShaderProgram = isExpose!(T, CIShaderProgram); 
}
