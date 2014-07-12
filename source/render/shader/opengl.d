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
module render.shader.opengl;

import render.shader.shader;
import render.shader.program;

/// Generates default implementation of shader interface for OpenGL
/**
*   To use this mixin you should provide following symbols of shader interface:
*   - name
*   - type
*   - source
*
*   Example:
*   ---------
*   import util.functional;
*   
*   struct AShader
*   {
*       enum name = "TestShader";
*       enum type = ShaderType.Fragment;
*       string source() { return ""; }
*       
*       mixin addDefaultOpenGLShader!(allMembers!(typeof(this)));
*   }
*
*   static assert(isShader!AShader);
*   ---------
*/
mixin template addDefaultOpenGLShader(Members...)
{
    import std.string;
    import std.traits;
    import std.typetuple;

    import derelict.opengl3.gl3;
    
    import render.shader.shader;
    import util.log;
    
    private alias T = typeof(this);
    
    private template hasSymbol(string name)
    {
        enum hasSymbol = staticIndexOf!(name, Members) != -1 ||
            __traits(compiles, { mixin("alias Identity!(T."~name~") Sym;"); });
    }
    
    static assert(hasSymbol!"name", "addDefaultOpenGLShader expects "~T.stringof~" has a name enum!");
    static assert(hasSymbol!"type", "addDefaultOpenGLShader expects "~T.stringof~" has is a type enum!");
    static assert(hasSymbol!"source", "addDefaultOpenGLShader expects "~T.stringof~" has is a source function!");
    
    static if(!hasSymbol!"id")
    {
        private GLuint _id;
        private bool isCreated = false;
        
        /// Returns shader id (OpenGL)
        GLuint id()
        {
            if(!isCreated)
            {
                _id = glCreateShader(mapShaderType(type));
                isCreated = true;
            }
            return _id;
        }
        
        /// Mapping to OpenGL shader type
        private GLuint mapShaderType(ShaderType sht)
        {
            final switch(sht)
            {
                case(ShaderType.Fragment): return GL_FRAGMENT_SHADER;
                case(ShaderType.Geometry): return GL_GEOMETRY_SHADER;
                case(ShaderType.Vertex):   return GL_VERTEX_SHADER;
                case(ShaderType.TessellationControl): return GL_TESS_CONTROL_SHADER;
                case(ShaderType.TessellationEvaluation): return GL_TESS_EVALUATION_SHADER;
            }
        }
        
        ~this()
        {
            if(isCreated) glDeleteProgram(_id);
        }
    }
    
    static if(!hasSymbol!"compile")
    {
        void compile()
        {
            static if(hasLogging!T) logInfo("Compiling shader: ", name);
            const(char*) sourcePtr = source.toStringz;
            glShaderSource(id, 1, &sourcePtr, null);
            glCompileShader(id);
            
            // Here exception could be thrown
            check();
        }
        
        private void check()
        {
            GLint result = GL_FALSE;
            int logLength;
            glGetShaderiv(id, GL_COMPILE_STATUS, &result);
            glGetShaderiv(id, GL_INFO_LOG_LENGTH, &logLength);
            if(logLength > 0)
            {
                auto buff = new char[logLength + 1];
                glGetShaderInfoLog(id, logLength, null, buff.ptr);
                
                auto shaderLog = buff.ptr.fromStringz.idup;
                static if(hasLogging!T) logError("Failed to compile shader: ", name, ". Reason: ", shaderLog);
                throw new ShaderCompilationException(shaderLog);
            }
        }
    }
}
version(unittest)
{
    import util.functional;
    import util.log;
    
    struct AShader
    {
        enum name = "TestShader";
        enum type = ShaderType.Fragment;
        string source() { return ""; }
    
        mixin Logging!(LoggerType.Global);
        mixin addDefaultOpenGLShader!(allMembers!(typeof(this)));
    }
}
unittest
{
    static assert(isShader!AShader);
}

/**
*   Generates default implementation for shader program based on OpenGL 3.3.
*
*/
mixin template addDefaultOpenGLShaderProgram(Members...)
{
    import std.conv;
    import std.string;
    import std.traits;
    import std.typetuple;

    import derelict.opengl3.gl3;
    
    import render.shader.program;
    import render.shader.shader;
    import util.log;
    
    private alias T = typeof(this);
    
    private template hasSymbol(string name)
    {
        enum hasSymbol = staticIndexOf!(name, Members) != -1 ||
            __traits(compiles, { mixin("alias Identity!(T."~name~") Sym;"); });
    }
    
    static assert(hasSymbol!"name", "addDefaultOpenGLShaderProgram expects "~T.stringof~" has a name enum!");
    static assert(hasSymbol!"pipeline", "addDefaultOpenGLShaderProgram expects "~T.stringof~" has is a pipeline alias!");
    
    static if(!hasSymbol!"id")
    {
        private GLuint _id;
        private bool isCreated = false;
        
        /// GPU program id (OpenGL)
        GLuint id()
        {
            if(!isCreated)
            {
                _id = glCreateProgram();
                isCreated = true;
            }
            return _id;
        }
        
        ~this()
        {
            if(isCreated) glDeleteProgram(_id);
        }
    }
    
    static if(!hasSymbol!"compile")
    {
        private static string shaderField(size_t i)
        {
            return text("shader", i);
        }
    
        private static string genShadersFields()
        {
            string ret;
            alias pipelineShaders = pipeline.values;
            foreach(i; Iota!(pipelineShaders.length))
            {
                ret ~= text(pipelineShaders[i].stringof, " ", shaderField(i), ";\n");
            }
            return ret;
        }
        //pragma(msg, genShadersFields);
        mixin(genShadersFields);
        
        void compile()
        {
            alias pipelineTypes = pipeline.keys;
            alias pipelineShaders = pipeline.values;
            
            foreach(i; Iota!(pipelineTypes.length))
            {
                enum shaderType = pipelineTypes[i];
                alias shader = pipelineShaders[i];
                
                static assert(isShader!shader, text("Expecting a shaders in program ", name, " pipeline! "
                    , shader.stringof, " is not a shader type!"));
                
                static if(hasLogging!T) logInfo("Compiling a ", shaderType, " for a program ", name);
                
                mixin(shaderField(i)).compile();
            }
        }
    }
    
    static if(!hasSymbol!"link")
    {
        void link()
        {
            alias pipelineShaders = pipeline.values;
            
            foreach(i; Iota!(pipelineShaders.length))
            {
                glAttachShader(id, mixin(shaderField(i)).id);
            }
            glLinkProgram(id);
            
            // here exception could be thrown
            check();
        }
        
        private void check()
        {
            GLint result = GL_FALSE;
            int logLength;
            glGetProgramiv(id, GL_LINK_STATUS, &result);
            glGetProgramiv(id, GL_INFO_LOG_LENGTH, &logLength);
            if(logLength > 0)
            {
                auto buff = new char[logLength + 1];
                glGetProgramInfoLog(id, logLength, null, buff.ptr);
                
                auto programLog = buff.ptr.fromStringz.idup;
                static if(hasLogging!T) logError("Failed to link program: ", name, ". Reason: ", programLog);
                throw new ProgramLinkingException(programLog);
            }
        }
    }
}
version(unittest)
{
    import util.functional;
    import util.log;
    
    struct AShaderProgram
    {
        enum name = "TestShaderProgram";
        alias pipeline = KeyValueList!(ShaderType.Fragment, AShader);
    
        mixin Logging!(LoggerType.Global);
        mixin addDefaultOpenGLShaderProgram!(allMembers!(typeof(this)));
    }
}
unittest
{
    static assert(isShaderProgram!AShaderProgram);
}