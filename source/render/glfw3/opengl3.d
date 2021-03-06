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
module render.glfw3.opengl3;

import std.container;
import std.exception;
import std.range;

import derelict.glfw3.glfw3 :
    DerelictGLFW3,
    glfwInit,
    glfwTerminate,
    glfwGetMonitors,
    glfwGetPrimaryMonitor,
    _GLFWmonitor = GLFWmonitor;
import derelict.opengl3.gl3;

import render.color;
import render.driver;
import render.glfw3.monitor;
import util.cinterface;
import util.log;

class GLFW3OpenGL3Driver
{
    static assert(isDriver!(typeof(this)), "Implementation error!");
    mixin Logging;
    
    /// Driver name
    enum name = "OpenGL 3.0 driver with GLFW3 context";
    
    /// Detail description
    enum description = "The driver supports minimum OpenGL 3.0 version. Windows and context creation are "
            "handled via GLFW3 library.";
            
    this()
    {
        initialize();
    }
    
    override destroy()
    {
        logInfo(name, " shutdown...");
        {
            scope(success)
            {
                logInfo(name, " shutdown is finished!");
            }
        }
        glfwTerminate();
        super.destroy();
    }
    
    void initialize()()
    {
        logInfo("Initializing driver...");
        scope(success) logInfo("Driver initialization is finished!");
        
        initOpenGL();
        initGLFW3();
        initOpenGL3();
    }
    
    private void initOpenGL()
    {
        logInfo("Initializing base OpenGL...");
        scope(success) logInfo("Base OpenGL initialization is finished!");
        
        DerelictGL3.load();
    }
    
    private void initGLFW3()
    {
        logInfo("Initializing GLFW3...");
        scope(success) logInfo("GLFW3 initialization is finished!");
        
        DerelictGLFW3.load();
        
        enforce(glfwInit(), raiseLogged("Failed to initialize GLFW3!"));
    }
    
    private void initOpenGL3()
    {
        logInfo("Initializing OpenGL3 ...");
        scope(success) logInfo("OpenGL3 initialization is finished!");
    }
    
    auto monitors() const
    {
        uint count;
        auto ptr = glfwGetMonitors(cast(int*)&count);
        enforce(ptr, raiseLogged("Failed to get monitors!"));
        
        DList!GLFWMonitor list;
        foreach(i; 0 .. count)
        {
            list.insert(GLFWMonitor(ptr[i]));
        }
        
        return list[];
    }
    
    GLFWMonitor monitor() const
    {
        auto ptr = glfwGetPrimaryMonitor();
        enforce(ptr, raiseLogged("Failed to get primary monitor!"));
        
        return GLFWMonitor(ptr);
    }
    
    /// Drawing scene to current context
    void draw()
    {
    	// Clear the screen
		glClear( GL_COLOR_BUFFER_BIT );
    }
    
    /// Setting scene background color to $(B rc) for current context.
	void backgroundColor(Color)(Color rc)
		if(isColor!Color)
	{
		auto c = rc.toGLRGBA;
		glClearColor(c.x, c.y, c.z, c.w);
	}
	
	/// Enables or disables depth buffer
	void setDepthTest(bool flag)
	{
		if(flag) glEnable(GL_DEPTH_TEST);
		else glDisable(GL_DEPTH_TEST);
	}
	
	/// Sets comparison function for depth test
	void depthFunc(DepthFunc func)
	{
		final switch(func)
		{
			case DepthFunc.Never:        glDepthFunc(GL_NEVER);    break;
			case DepthFunc.Less:         glDepthFunc(GL_LESS);     break;
			case DepthFunc.Equal:        glDepthFunc(GL_EQUAL);    break;
			case DepthFunc.LessEqual:    glDepthFunc(GL_LEQUAL);   break;
			case DepthFunc.Greater:      glDepthFunc(GL_GREATER);  break;
			case DepthFunc.NotEqual:     glDepthFunc(GL_NOTEQUAL); break;
			case DepthFunc.GreaterEqual: glDepthFunc(GL_GEQUAL);   break;
			case DepthFunc.Always:       glDepthFunc(GL_ALWAYS);   break;
		}
	}
}