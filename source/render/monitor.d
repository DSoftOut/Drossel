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
module render.monitor;

import std.range;
import std.traits;

import render.mode;
import util.cinterface;
import math.vec;

struct CIMonitor
{
    /// Monitor position on virtual surface
    vec2!uint position() const;
    /// Monitor physical size in pixels
    vec2!uint size() const;
    /// Monitor system name
    string name() const;
    
    /// Returns available video modes
    @trasient
    R videoModes(R)() 
      if(isInputRange!R && is(ElementType!R == VideoMode));
      
    /// Returns current video mode  
    VideoMode videoMode() const;   
}

/// Checking if $(B T) is a Monitor
template isMonitor(T)
{
    static if(hasMember!(T, "videoModes"))
    {
        alias R = ReturnType!(__traits(getMember, T, "videoModes"));
        
        enum hasVideoModes = isInputRange!R && is(ElementType!R == VideoMode);
    } else
    {
        enum hasVideoModes = false;
    }
    
    enum isMonitor = isExpose!(T, CIMonitor) && hasVideoModes;
}