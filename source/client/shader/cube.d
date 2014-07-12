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
module client.shader.cube;

import render.shader.dsl;
import render.shader.program;
import render.shader.shader;
import render.shader.opengl;
import util.log;
import util.functional;

struct CubeVertexShader
{
    enum name = "CubeVertexShader";
    enum type = ShaderType.Vertex;
    
    enum BufferSlot 
    {
        Verticies,
        Colors
    }
    
    string source() 
    {
        return Kernel!(name, q{
            #version 330 core
            
            // Input vertex data, different for all executions of this shader
            layout(location = 0) in vec3 vertexPosition_modelspace;
            layout(location = 1) in vec3 vertexColor;
            
            // Output data. will be interpolated for each fragment
            out vec3 fragmentColor;
            // Values that stay constant for the whole mesh
            uniform mat4 MVP;
                
            void main()
            {
                // Output position of the vertex, in clip space: MVP * position
                gl_Position = MVP * vec4(vertexPosition_modelspace, 1);
                
                // The color of each vertex will be interpolated
                // to produce the color of each fragment
                fragmentColor = vertexColor;
            }
        }).sources;
    }
    
    mixin Logging!(LoggerType.Global);
    mixin addDefaultOpenGLShader!(allMembers!(typeof(this)));
}
static assert(isShader!CubeVertexShader);

struct CubeFragmentShader
{
    enum name = "CubeFragmentShader";
    enum type = ShaderType.Fragment;
    
    string source() 
    {
        return Kernel!(name, q{
            #version 330 core
            
            // Interpolated values from the vertex shaders
            in vec3 fragmentColor;
            
            // Output data
            out vec3 color;
            
            void main() 
            {
                // Output color = color specified in the vertex shader,
                // interpolated between all 3 surrounding vertices
                color = fragmentColor;
            }
        }).sources;
    }
    
    mixin Logging!(LoggerType.Global);
    mixin addDefaultOpenGLShader!(allMembers!(typeof(this)));
}
static assert(isShader!CubeVertexShader);


struct CubeProgram
{
    enum name = "SampleCubeProgram";
    alias pipeline = KeyValueList!(
        ShaderType.Vertex, CubeVertexShader,
        ShaderType.Fragment, CubeFragmentShader,
    );
    
    mixin Logging!(LoggerType.Global);
    mixin addDefaultOpenGLShaderProgram!(allMembers!(typeof(this)));
}
static assert(isShaderProgram!CubeProgram);