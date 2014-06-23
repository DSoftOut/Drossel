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
module render.renderer;

import render.driver;
import render.window;
import util.cinterface;
import std.traits;
import std.range;
import std.typecons;
import std.typetuple;

/**
*   Compile-time interface describing rendering subsystem.
*/
struct CIRenderer
{
    /// Name of renderer, should include underlying driver
    immutable string name;
    /// Detail description of the renderer
    immutable string description;
    
    /// Initialization method, could varies within implementation
    void initialize(T...)(T args);
    
    /// Get driver of the renderer
    @trasient
    Driver driver()() if(isDriver!Driver); 
    
    /// Get windows that was defined in compile-time and added in runtime
    @trasient
    Tuple!(WindowsRanges) windows(Windows...)()
        if( allSatisfy!(isInputRange, WindowsRanges) &&
            allSatisfy!(isWindow, staticMap!(ElementType, WindowsRanges))
          );
    
    /// Creates new window that is supported by the renderer
    /**
    *   Created window is returned. $(B args) are passed to window $(B create)
    *   method.
    *
    *   Renderer should add this window to dispatching cycle and start to listen
    *   events.
    *   
    *   Note: the $(B Window) have to supported by the renderer.
    *   ----
    *   staticIndexOf!(Window, staticMap!(ElementType, ReturnType!windows.expand)) != -1
    *   ----
    */
    @trasient
    Window createWindow(Window, Behavior, Args...)(Args args)
        if(isWindowBehavior!Behavior);

    /// Creates new window that is supported by the renderer, dynamic version
    /**
    *   Created window is returned. $(B args) are passed to window $(B create)
    *   method.
    *
    *   Renderer should add this window to dispatching cycle and start to listen
    *   events.
    *   
    *   Note: the $(B Window) have to supported by the renderer.
    *   ----
    *   staticIndexOf!(Window, staticMap!(ElementType, ReturnType!windows.expand)) != -1
    *   ----
    */ 
    @trasient
    Window createWindow(Window, Behavior, Args...)(Behavior behavior, Args args)
        if(isWindowBehavior!Behavior);
                
    /// Blocking. Infinite loop that updates windows
    void startEventListening();
}

/// Test if $(B T) is actual renderer
template isRenderer(T)
{
    private template extract(alias T)
    {
        static if(is(T : Tuple!U, U...))
        {
            alias extract = U;
        }
        else
        {
            alias extract = List!();
        }
    }
    
    static if(hasMember!(T, "driver") 
        &&    hasMember!(T, "windows")
        &&    hasMember!(T, "createWindow"))
    {
        alias Driver = ReturnType!(__traits(getMember, T, "driver"));
        alias WindowsRanges = extract!(ReturnType!(__traits(getMember, T, "windows")));
                
        enum hasExtra = isDriver!Driver
            && allSatisfy!(isInputRange, WindowsRanges) 
            && allSatisfy!(isWindow, staticMap!(ElementType, WindowsRanges)
            );

    } else
    {
        enum hasExtra = false;
    }
    
    enum isRenderer = isExpose!(T, CIRenderer) && hasExtra;
}