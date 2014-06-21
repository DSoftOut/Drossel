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
module render.glfw3opengl3;

import render.driver;
import util.cinterface;
import util.log;
import std.exception;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

class GLFW3OpenGL3Driver
{
    static assert(isExpose!(typeof(this), CIDriver), "Implementation error!");
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
}