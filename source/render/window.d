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
module render.window;

import render.monitor;
import util.vec;
import util.cinterface;
import util.functional;
import std.traits;

/// Window compile-time interface
struct CIWindow
{
    /// Getting framebuffer size
    vec2!uint frambebufferSize();
    
    /// Is window focused?
    bool focused();
    
    /// Is window minimized?
    bool iconified();
    
    /// Is window vizible?
    bool vizible();
    
    /// Is window resizable?
    bool resizeable();
    
    /// Is window has OS-specific borders and controls?
    bool decorated(); 
    
    /// Getting window monitor
    @trasient
    M monitor(M)() if(isMonitor!M);   
    
    /// Getting window position
    vec2!uint position();
    
    /// Setting window position
    void position(vec2!uint val);
    
    /// Getting window size
    vec2!uint size();
    
    /// Setting window size
    void size(vec2!uint val);
    
    /// Hides window
    void hide();
    
    /// Minimizes window
    void iconify();
    
    /// Shows window
    void show();
    
    /// Restores window from iconified statte
    void restore();
    
    /// Setting window title
    void title(string value);
    
    /// Is window should be closed
    bool shouldClose();
    
    /// Setting flag that indicates that window should be closed 
    void shouldClose(bool val);
    
    /// Called by renderer when the window order comes to be checked
    void pollEvents();
}

/// Checking is $(B T) is a window
template isWindow(T)
{
    static if(hasMember!(T, "monitor"))
    {
        alias R = ReturnType!(__traits(getMember, T, "monitor"));
        
        enum hasMonitor = isMonitor!R;
    } else
    {
        enum hasMonitor = false;
    }
    
    enum isWindow = isExpose!(T, CIWindow) && hasMonitor;
}

/**
*   Compile-time interfaces that collects custom callbacks that
*   are attached to a window while compilation.
*
*   For window hints you can use $(B addDefaultWindowBehavior) mixin
*   that implements default values for undefined hints in your
*   window behavior.
*/
struct CIWindowBehavior
{
    static
    {
        /// Called when window position is changed
        @trasient
        void positionCallback(W)(W window, vec2!uint pos)
            if(isWindow!W);
        
        /// Called when window size is changed    
        @trasient
        void sizeCallback(W)(W window, vec2!uint size)
            if(isWindow!W);
            
        /// Called when window is closing
        @trasient
        void closeCallback(W)(W window) if(isWindow!W);
        
        /// Called when window is refreshed
        @trasient
        void refreshCallback(W)(W window) if(isWindow!W);
        
        /// Called when window get or loose focus
        @trasient
        void focusCallback(W)(W window, bool flag) if(isWindow!W);
        
        /// Called when window iconified or restored
        @trasient
        void iconifyCallback(W)(W window, bool flag) if(isWindow!W);
        
        /// Called when window framebuffer changes it size
        @trasient
        void framebufferSizeCallback(W)(W window, vec2!uint size)
            if(isWindow!W);
    }
    
    // Window options while creation
    // default values are only for example
    /// If window resizable?
    enum bool resizable = true;
    /// If window visible?
    enum bool visible =  true;
    /// If window with default controls?
    enum bool decorated = true;
    
    /// Context red bits count
    enum uint redBits = 8;
    /// Context green bits count
    enum uint greenBits = 8;
    /// Context blue bits count
    enum uint blueBits = 8;
    /// Context alpha bits count
    enum uint alphaBits = 8;
    /// Context depth bits count
    enum uint depthBits = 24;
    /// Context stencil bits count
    enum uint stencilBits = 8;
    
    /// Context red bits count for accumulation buffer
    enum uint accumRedBits = 0;
    /// Context green bits count for accumulation buffer
    enum uint accumGreenBits = 0;
    /// Context blue bits count for accumulation buffer
    enum uint accumBlueBits = 0;
    /// Context alpha bits count for accumulation buffer
    enum uint accumAlphaBits = 0;
    
    /// Specifies the desired number of auxiliary buffers
    enum size_t auxBuffers = 0;
    /// Specifies the desired number of samples to use for multisampling. Zero disables multisampling.
    enum size_t samples = 0;
    /// Specifies the desired refresh rate for full screen windows. If set to zero, the highest available refresh rate will be used.
    enum uint refreshRate = 0;
    
    /// Specifies whether to use stereoscopic rendering.
    enum bool stereo = false;
    /// Specifies whether the framebuffer should be sRGB capable.
    enum bool sRGBCapable = false;
}

/// Checking if $(B T) is an actual WindowBehavior
template isWindowBehavior(T)
{
    private template hasMethod(string name, alias RestParamsList)
    {
        alias RestParams = RestParamsList.expand;
        
        static if(hasMember!(T, name))
        {
            alias paramList = ParameterTypeTuple!(__traits(getMember, T, name));
            static if(paramList.length >= 1)
            {
                enum hasMethod = isWindow!(paramList[0]) && staticEqual!(StrictList!(paramList[1 .. $]), StrictList!RestParams);
            } else
            {
                enum hasMethod = false;
            }
        } else
        {
            enum hasMethod = false;
        }
    }
    
    enum isWindowBehavior = isExpose!(T, CIWindowBehavior) &&
        allSatisfy2!(hasMethod,
        "positionCallback", StrictList!(vec2!uint),
        "sizeCallback", StrictList!(vec2!uint),
        "closeCallback", StrictList!(),
        "focusCallback", StrictList!bool,
        "iconifyCallback", StrictList!bool,
        "framebufferSizeCallback", StrictList!(vec2!uint)
        );
}

/**
*   Mixin that adds missing window hints and callbacks to your window behavior type.
*/
mixin template addDefaultWindowBehavior(alias W, Members...)
{
    import std.traits;
    import std.typetuple;
    
    private template hasSymbol(string name)
    {
        enum hasSymbol = staticIndexOf!(name, Members) != -1 ||
            __traits(compiles, { mixin("alias Identity!(T."~name~") Sym;"); });
    }
    
    static if(!hasSymbol!"resizable")
    {
        /// If window resizable?
        enum bool resizable = true;
    }
    static if(!hasSymbol!"visible")
    {
        /// If window visible?
        enum bool visible = true;
    }
    static if(!hasSymbol!"decorated")
    {
        /// If window with default controls?
        enum bool decorated = true;
    }

    static if(!hasSymbol!"redBits")
    {
        /// Context red bits count
        enum uint redBits = 8;
    }
    static if(!hasSymbol!"greenBits")
    {
        /// Context green bits count
        enum uint greenBits = 8;
    }
    static if(!hasSymbol!"blueBits")
    {
        /// Context blue bits count
        enum uint blueBits = 8;
    }
    static if(!hasSymbol!"alphaBits")
    {
        /// Context alpha bits count
        enum uint alphaBits = 8;
    }
    static if(!hasSymbol!"depthBits")
    {
        /// Context depth bits count
        enum uint depthBits = 24;
    }
    static if(!hasSymbol!"stencilBits")
    {
        /// Context stencil bits count
        enum uint stencilBits = 8;
    }
    
    static if(!hasSymbol!"accumRedBits")
    {
        /// Context red bits count for accumulation buffer
        enum uint accumRedBits = 0;
    }
    static if(!hasSymbol!"accumGreenBits")
    {
        /// Context green bits count for accumulation buffer
        enum uint accumGreenBits = 0;
    }
    static if(!hasSymbol!"accumBlueBits")
    {
        /// Context blue bits count for accumulation buffer
        enum uint accumBlueBits = 0;
    }
    static if(!hasSymbol!"accumAlphaBits")
    {
        /// Context alpha bits count for accumulation buffer
        enum uint accumAlphaBits = 0;
    }
    
    static if(!hasSymbol!"auxBuffers")
    {
        /// Specifies the desired number of auxiliary buffers
        enum size_t auxBuffers = 0;
    }
    static if(!hasSymbol!"samples")
    {
        /// Specifies the desired number of samples to use for multisampling. Zero disables multisampling.
        enum size_t samples = 0;
    }
    static if(!hasSymbol!"refreshRate")
    {
        /// Specifies the desired refresh rate for full screen windows. If set to zero, the highest available refresh rate will be used.
        enum uint refreshRate = 0;
    }
    
    static if(!hasSymbol!"stereo")
    {
        /// Specifies whether to use stereoscopic rendering.
        enum bool stereo = false;
    }
    static if(!hasSymbol!"sRGBCapable")
    {
        /// Specifies whether the framebuffer should be sRGB capable.
        enum bool sRGBCapable = false;
    }
}