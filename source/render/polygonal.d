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
module render.polygonal;

import render.renderer;
import render.driver;
import render.window;
import util.cinterface;
import util.log;
import std.algorithm;
import std.conv;
import std.container;
import std.typetuple;
import std.typecons;
import std.range;

/**
*   Renderer for polygonal graphics.
*
*   $(B Driver) is used driver, could be opengl, directx, software and e.t.c.
*   
*   $(Windows) compile-time defined windows in StrictList, first window is 
*   main window, all following windows are additional ones. 
*/
class PolygonalRenderer(Driver, Windows...)
    if(isDriver!Driver && allSatisfy!(isWindow, Windows))
{
    static assert(Windows.length > 0, "Expecting at least 1 window!");
    static assert(isRenderer!(typeof(this)), "Implementation error!");
    
    mixin Logging;
    
    /// Name of renderer, should include underlying driver
    enum name = "Polygonal renderer";
    
    /// Detail description of the renderer
    enum description = text("Rendering via polygons rasterizer. Driver: ", driver.name, ".");
    
    this()
    {
        _driver = new Driver();
        initialize();
    }
    
    override destroy()
    {
        logInfo(name, " shutdown...");
        {
            scope(success) logInfo(name, " shutdown is finished...");
            driver.destroy();
        }
        super.destroy();
    }
    
    void initialize()()
    {
        logInfo(name, " initializing...");
        scope(success) 
        {
            logInfo(name, " initalization is finished!");
            logInfo(description);
        }
    }
    
    Driver driver()
    {
        return _driver;
    }
    
    const(Driver) driver() const
    {
        return _driver;
    }
    
    /// Get windows that was defined in compile-time
    @trasient
    Tuple!WindowsRanges windows()
    {
        Tuple!WindowsRanges ret;
        foreach(i, ref range; ret)
        {
            range = _windows[i][].array;
        }
        
        return ret;
    }
    
    /// Creates new window that is supported by the renderer
    /**
    *   Created window is returned. $(B args) are passed to window $(B create)
    *   method.
    *
    *   Renderer should add this window to dispatching cycle and start to listen
    *   events.
    */
    Window createWindow(Window, Behavior, Args...)(Args args)
        if( isWindowBehavior!Behavior &&
            staticIndexOf!(Window , getWindowIndex!Window != -1))
    {
        enum size_t i = getWindowIndex!Window;
        
        auto window = Window.create!Behavior(args);
        _windows[i].insert(window);
        
        return window;
    }
    
    /// Version for main window type
    Windows[0] createWindow(Behavior, Args...)(Args args)
        if( isWindowBehavior!Behavior)
    {
        auto window = Windows[0].create!Behavior(args);
        _windows[0].insert(window);
        
        return window;
    }
    
    /// Creates new window that is supported by the renderer, dynamic version
    /**
    *   Created window is returned. $(B args) are passed to window $(B create)
    *   method.
    *
    *   Renderer should add this window to dispatching cycle and start to listen
    *   events.
    */
    Window createWindow(Window, Behavior, Args...)(Behavior behavior, Args args)
        if( isWindowBehavior!Behavior &&
            staticIndexOf!(Window , getWindowIndex!Window != -1))
    {
        enum size_t i = getWindowIndex!Window;
        
        auto window = Window.create!Behavior(args);
        _windows[i].insert(window);
        
        return window;
    }
    
    /// Version for main window type
    Windows[0] createWindow(Behavior, Args...)(Behavior behavior, Args args)
        if( isWindowBehavior!Behavior)
    {
        auto window = Windows[0].create!Behavior(args);
        _windows[0].insert(window);
        
        return window;
    }
    
    /// Blocking. Infinite loop that updates windows
    void startEventListening()
    {
        while(!isNoWindowsLeft)
        {
            foreach(ref winList; _windows)
            {
                foreach(ref window; winList[])
                {
                    window.swapBuffers();
                    window.pollEvents();
                    
                    if(window.shouldClose)
                    {
                        auto findRes = winList[].find!((e) => e == window);
                        winList.remove(findRes);
                    }
                }
            }
        }
    }
    
    private
    {
        template WrapDList(T)
        {
            alias WrapDList = DList!T;
        }
        
        template WrapDListRange(alias T)
        {
            alias WrapDListRange = T[];
        }
        
        alias WindowsLists = staticMap!(WrapDList, Windows);
        alias WindowsRanges = staticMap!(WrapDListRange, Windows);
        
        template getWindowIndex(W)
        {
            enum getWindowIndex = staticIndexOf!(W, Windows);
        }
        
        private bool isNoWindowsLeft()
        {
            foreach(winList; _windows)
            {
                if(!winList.empty)
                    return false;
            }
            return true;
        }
        
        Driver _driver;
        Tuple!WindowsLists _windows;
    }
}