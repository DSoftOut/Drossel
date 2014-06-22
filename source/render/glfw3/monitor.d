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
module render.glfw3.monitor;

import render.monitor;
import render.mode;
import derelict.glfw3.glfw3 : 
    glfwGetVideoModes,
    glfwGetMonitorPos,
    glfwGetMonitorPhysicalSize,
    glfwGetMonitorName,
    _GLFWMonitor = GLFWmonitor;

import util.vec;
import util.log;
import util.string;
import std.exception;

/// Wrapper around GLFW3 monitor.
struct GLFWMonitor
{
    static assert(isMonitor!(typeof(this)), "Implementation error!");
    mixin Logging;
    
    this(_GLFWMonitor* handle)
    {
        this.handle = handle;
    }
    
    /// Monitor position on virtual surface
    vec2!uint position() const
    {
        uint x, y;
        glfwGetMonitorPos(cast(_GLFWMonitor*)handle, cast(int*)&x, cast(int*)&y);
        return vec2!uint(x,y); 
    }
    
    /// Monitor physical size in pixels
    vec2!uint size() const
    {
        uint width, height;
        glfwGetMonitorPhysicalSize (cast(_GLFWMonitor*)handle, cast(int*)&width, cast(int*)&height);
        return vec2!uint(width, height);
    }
    
    /// Monitor system name
    string name() const
    {
        auto str = glfwGetMonitorName(cast(_GLFWMonitor*)handle).fromStringz;
        enforce(str !is null, raiseLogged("Failed to get name of monitor!"));
        return str.idup;
    }
    
    /// Returns available video modes
    auto videoModes()
    {
        uint count;
        auto ptr = glfwGetVideoModes(handle, cast(int*)&count); 
        enforce(ptr, raiseLogged("Failed to get video modes!"));
        
        return (cast(VideoMode*)ptr)[0 .. count];
    }
      
    /// Returns current video mode  
    VideoMode videoMode() const;   
    
    private _GLFWMonitor* handle;
}
