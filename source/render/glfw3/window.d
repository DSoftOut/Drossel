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
module render.glfw3.window;

import std.exception;
import std.functional;
import std.string;

import derelict.glfw3.glfw3;

public import render.window;

import render.color;
import render.input.keyboard;
import render.input.mods;
import render.input.mouse;
import render.glfw3.monitor;
import render.glfw3.opengl3;
import util.log;
import util.vec;

class GLFWWindow
{
    static assert(isWindow!(typeof(this)), "Implementation error!");
    mixin Logging;
    
    // Constructors for compile-time hints and callbacks
    /// Creating windowed window
    static GLFWWindow create(Behavior)(GLFW3OpenGL3Driver driver, vec2!uint size, string title)
        if(isWindowBehavior!Behavior)
    {
        return new GLFWWindow(driver, Behavior(), size, title);
    }
    
    /// Creating fullscreen window
    static GLFWWindow create(Behavior)(GLFW3OpenGL3Driver driver, vec2!uint size, string title, GLFWMonitor monitor)
        if(isWindowBehavior!Behavior)
    {
        return new GLFWWindow(driver, Behavior(), size, title, monitor);
    }
    
    /// Creating windowed window with shared context
    static GLFWWindow create(Behavior)(GLFW3OpenGL3Driver driver, vec2!uint size, string title, GLFWWindow share)
        if(isWindowBehavior!Behavior)
    {
        return new GLFWWindow(driver, Behavior(), size, title, share);
    }
    
    /// Creating fullscreen window with shared context
    static GLFWWindow create(Behavior)(GLFW3OpenGL3Driver driver, vec2!uint size, string title, GLFWMonitor monitor, GLFWWindow share)
        if(isWindowBehavior!Behavior)
    {
        return new GLFWWindow(driver, Behavior(), size, title, monitor, share);
    }
    
    /// Creating windowed window
    static GLFWWindow create(Behavior)(GLFW3OpenGL3Driver driver, Behavior behavior, vec2!uint size, string title)
        if(isWindowBehavior!Behavior)
    {
        return new GLFWWindow(driver, behavior, size, title);
    }
    
    /// Creating fullscreen window
    static GLFWWindow create(Behavior)(GLFW3OpenGL3Driver driver, Behavior behavior, vec2!uint size, string title, GLFWMonitor monitor)
        if(isWindowBehavior!Behavior)
    {
        return new GLFWWindow(driver, behavior, size, title, monitor);
    }
    
    /// Creating windowed window with shared context
    static GLFWWindow create(Behavior)(GLFW3OpenGL3Driver driver, Behavior behavior, vec2!uint size, string title, GLFWWindow share)
        if(isWindowBehavior!Behavior)
    {
        return new GLFWWindow(driver, behavior, size, title, share);
    }
    
    /// Creating fullscreen window with shared context
    static GLFWWindow create(Behavior)(GLFW3OpenGL3Driver driver, Behavior behavior, vec2!uint size, string title, GLFWMonitor monitor, GLFWWindow share)
        if(isWindowBehavior!Behavior)
    {
        return new GLFWWindow(driver, behavior, size, title, monitor, share);
    }
    
    // Constructors for run-time hints and callback changing
    /// Creating windowed window
    this(B)(GLFW3OpenGL3Driver driver, B behavior, vec2!uint size, string title)
        if(isWindowBehavior!B)
    {
        setWindowHints(behavior);
        handle = glfwCreateWindow(size.x, size.y, title.toStringz, null, null);
        enforce(handle, raiseLogged("Failed to create window!")); 
        bindCallbacks(behavior);
        
        callbacksMap[handle] = WindowDescr(this, behavior);
        this.driver = driver;
    }
    
    /// Creating fullscreen window
    this(B)(GLFW3OpenGL3Driver driver, B behavior, vec2!uint size, string title, GLFWMonitor monitor)
        if(isWindowBehavior!B)
    {
        setWindowHints(behavior);
        handle = glfwCreateWindow(size.x, size.y, title.toStringz, monitor.handle, null);
        enforce(handle, raiseLogged("Failed to create window!")); 
        bindCallbacks(behavior);
        
        callbacksMap[handle] = WindowDescr(this, behavior);
        this.driver = driver;
    }
    
    /// Creating windowed window with shared context
    this(B)(GLFW3OpenGL3Driver driver, B behavior, vec2!uint size, string title, GLFWWindow share)
        if(isWindowBehavior!B)
    {
        setWindowHints(behavior);
        handle = glfwCreateWindow(size.x, size.y, title.toStringz, null, share.handle);
        enforce(handle, raiseLogged("Failed to create window!")); 
        bindCallbacks(behavior);
        
        callbacksMap[handle] = WindowDescr(this, behavior);
        this.driver = driver;
    }
    
    /// Creating fullscreen window with shared context
    this(B)(GLFW3OpenGL3Driver driver, B behavior, vec2!uint size, string title, GLFWMonitor monitor, GLFWWindow share)
        if(isWindowBehavior!B)
    {
        setWindowHints(behavior);
        handle = glfwCreateWindow(size.x, size.y, title.toStringz
            , monitor.handle, share.handle);
        enforce(handle, raiseLogged("Failed to create window!")); 
        bindCallbacks(behavior);
        
        callbacksMap[handle] = WindowDescr(this, behavior);
        this.driver = driver;
    }
    
    /// Used to store hints setting statements
    private mixin template windowHintsStore(alias store)
    {
        void applyHints()
        {
            glfwDefaultWindowHints();
            glfwWindowHint(GLFW_RESIZABLE, store.resizable);
            glfwWindowHint(GLFW_VISIBLE,   store.visible);
            glfwWindowHint(GLFW_DECORATED, store.decorated);
            
            glfwWindowHint(GLFW_RED_BITS,     store.redBits);
            glfwWindowHint(GLFW_GREEN_BITS,   store.greenBits);
            glfwWindowHint(GLFW_BLUE_BITS,    store.blueBits);
            glfwWindowHint(GLFW_ALPHA_BITS,   store.alphaBits);
            glfwWindowHint(GLFW_DEPTH_BITS,   store.depthBits);
            glfwWindowHint(GLFW_STENCIL_BITS, store.stencilBits);
            
            glfwWindowHint(GLFW_ACCUM_RED_BITS,   store.accumRedBits);
            glfwWindowHint(GLFW_ACCUM_GREEN_BITS, store.accumGreenBits);
            glfwWindowHint(GLFW_ACCUM_BLUE_BITS,  store.accumBlueBits);
            glfwWindowHint(GLFW_ACCUM_ALPHA_BITS, store.accumAlphaBits);
            
            glfwWindowHint(GLFW_AUX_BUFFERS,  store.auxBuffers);
            glfwWindowHint(GLFW_SAMPLES,      store.samples);
            glfwWindowHint(GLFW_REFRESH_RATE, store.refreshRate);
            
            glfwWindowHint(GLFW_STEREO,       store.stereo);
            glfwWindowHint(GLFW_SRGB_CAPABLE, store.sRGBCapable);
            
            glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
            glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
            glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
        }
    }
    
    /// Compile-time version
    private void setWindowHints(B)()
        if(isWindowBehavior!B)
    {
        mixin windowHintsStore!B;
        applyHints();
    }
    
    /// Run-time version
    private void setWindowHints(B)(B behavior)
        if(isWindowBehavior!B)
    {
        mixin windowHintsStore!behavior;
        applyHints();
    }
    
    /// Used to store callbacks statements in one place
    private mixin template callbacksStore(alias store)
    {
        static nothrow extern(C) 
        {
            void positionCallback(GLFWwindow* handle, int x, int y)
            {
                scope(failure) {}
                if(auto descr = handle in callbacksMap)
                    descr.positionCallback(descr.window, vec2!uint(cast(uint)x, cast(uint)y));
            }
    
            void sizeCallback(GLFWwindow* handle, int x, int y)
            {
                scope(failure) {}
                if(auto descr = handle in callbacksMap)
                    descr.sizeCallback(descr.window, vec2!uint(cast(uint)x, cast(uint)y));
            }
            
            void closeCallback(GLFWwindow* handle)
            {
                scope(failure) {}
                if(auto descr = handle in callbacksMap)
                    descr.closeCallback(descr.window);
            }
            
            void refreshCallback(GLFWwindow* handle)
            {
                scope(failure) {}
                if(auto descr = handle in callbacksMap)
                    descr.refreshCallback(descr.window);
            }
            
            void focusCallback(GLFWwindow* handle, int flag)
            {
                scope(failure) {}
                if(auto descr = handle in callbacksMap)
                    descr.focusCallback(descr.window, cast(bool)flag);
            }
            
            void iconifyCallback(GLFWwindow* handle, int flag)
            {
                scope(failure) {}
                if(auto descr = handle in callbacksMap)
                    descr.iconifyCallback(descr.window, cast(bool)flag);
            }
            
            void framebufferSizeCallback(GLFWwindow* handle, int x, int y)
            {
                scope(failure) {}
                if(auto descr = handle in callbacksMap)
                    descr.framebufferSizeCallback(descr.window, vec2!uint(cast(uint)x, cast(uint)y));
            }
            
            void mouseButtonCallback(GLFWwindow* handle, int button, int action, int mods)
            {
                scope(failure) {}
                if(auto descr = handle in callbacksMap)
                    descr.mouseButtonCallback(descr.window
                        , cast(MouseButton)button, cast(MouseButtonAction)action
                        , Modificators.fromBitfield(mods));
            }
            
            void cursorPosCallback(GLFWwindow* handle, double xpos, double ypos)
            {
                scope(failure) {} 
                if(auto descr = handle in callbacksMap) 
                    descr.cursorPosCallback(descr.window, vec2!double(xpos, ypos) / descr.window.size);
            }
            
            void cursorEnterCallback(GLFWwindow* handle, int flag)
            {
                scope(failure) {}
                if(auto descr = handle in callbacksMap)
                    descr.cursorEnterCallback(descr.window, cast(bool)flag);
            }
            
            void scrollCallback(GLFWwindow* handle, double xoffset, double yoffset)
            {
                scope(failure) {}
                if(auto descr = handle in callbacksMap)
                    descr.scrollCallback(descr.window, vec2!double(xoffset, yoffset));
            }
            
            void keyCallback(GLFWwindow* handle, int key, int scancode, int action, int mods)
            {
                scope(failure) {}
                if(auto descr = handle in callbacksMap)
                    descr.keyCallback(descr.window
                        , cast(KeyboardKey)key, cast(uint)scancode
                        , cast(KeyboardKeyAction)action
                        , Modificators.fromBitfield(mods));
            }
            
            void charCallback(GLFWwindow* handle, uint codepoint)
            {
                scope(failure) {}
                if(auto descr = handle in callbacksMap)
                    descr.charCallback(descr.window, cast(dchar)codepoint);
            }
        }
        
        void bind(alias GLFWFunc, alias Callback)()
        {
            GLFWFunc(handle, &Callback);
        }
                
        void applyCallbacks()
        {
            bind!(glfwSetWindowPosCallback,       positionCallback);
            bind!(glfwSetWindowSizeCallback,      sizeCallback);
            bind!(glfwSetWindowCloseCallback,     closeCallback);
            bind!(glfwSetWindowRefreshCallback,   refreshCallback);
            bind!(glfwSetWindowFocusCallback,     focusCallback);
            bind!(glfwSetWindowIconifyCallback,   iconifyCallback);
            bind!(glfwSetFramebufferSizeCallback, framebufferSizeCallback);
            
            bind!(glfwSetMouseButtonCallback,     mouseButtonCallback);
            bind!(glfwSetCursorPosCallback,       cursorPosCallback);
            bind!(glfwSetCursorEnterCallback,     cursorEnterCallback);
            bind!(glfwSetScrollCallback,          scrollCallback);
            bind!(glfwSetKeyCallback,             keyCallback);
            bind!(glfwSetCharCallback,            charCallback);
        }
    }
    
    /// Compile-time version
    private void bindCallbacks(B)()
        if(isWindowBehavior!B)
    {
        mixin callbacksStore!B;
        applyCallbacks();
    }
    
    /// Run-time version
    private void bindCallbacks(B)(B behavior)
        if(isWindowBehavior!B)
    {
        mixin callbacksStore!behavior;
        applyCallbacks();
    }
    
    override destroy()
    {
        callbacksMap.remove(handle);
        glfwDestroyWindow(handle);
        super.destroy();
    }
    
    /// Getting framebuffer size
    vec2!uint frambebufferSize()
    {
        uint width, height;
        glfwGetWindowSize(handle, cast(int*)&width, cast(int*)&height);
        return vec2!uint(width, height);
    }
    
    /// Is window focused?
    bool focused()
    {
        return cast(bool)glfwGetWindowAttrib(handle, GLFW_FOCUSED);
    }
    
    /// Is window minimized?
    bool iconified()
    {
        return cast(bool)glfwGetWindowAttrib(handle, GLFW_ICONIFIED);
    }
    
    /// Is window vizible?
    bool vizible()
    {
        return cast(bool)glfwGetWindowAttrib(handle, GLFW_VISIBLE);
    }
    
    /// Is window resizable?
    bool resizeable()
    {
        return cast(bool)glfwGetWindowAttrib(handle, GLFW_RESIZABLE);
    }
    
    /// Is window has OS-specific borders and controls?
    bool decorated()
    {
        return cast(bool)glfwGetWindowAttrib(handle, GLFW_DECORATED);
    }
    
    /// Getting window monitor
    GLFWMonitor monitor()
    {
        auto ptr = glfwGetWindowMonitor(handle);
        enforce(ptr, raiseLogged("Failed to get window monitor!"));
        return GLFWMonitor(ptr);
    }
    
    /// Getting window position
    vec2!uint position()
    {
        uint x, y;
        glfwGetWindowPos(handle, cast(int*)&x, cast(int*)&y);
        return vec2!uint(x, y);
    }
    
    /// Setting window position
    void position(vec2!uint val)
    {
        glfwSetWindowPos(handle, val.x, val.y);
    }
    
    /// Getting window size
    vec2!uint size()
    {
        uint width, height;
        glfwGetWindowSize(handle, cast(int*)&width, cast(int*)&height);
        return vec2!uint(width, height);
    }
    
    /// Setting window size
    void size(vec2!uint val)
    {
        glfwSetWindowSize(handle, val.x, val.y);
    }
    
    /// Hides window
    void hide()
    {
        glfwHideWindow(handle);
    }
    
    /// Minimizes window
    void iconify()
    {
        glfwIconifyWindow(handle);
    }
    
    /// Shows window
    void show()
    {
        glfwShowWindow(handle);
    }
    
    /// Restores window from iconified statte
    void restore()
    {
        glfwRestoreWindow(handle);
    }
    
    /// Setting window title
    void title(string value)
    {
        glfwSetWindowTitle(handle, value.toStringz);
    }
    
    /// Is window should be closed
    bool shouldClose()
    {
        return cast(bool)glfwWindowShouldClose(handle);
    }
    
    /// Setting flag that indicates that window should be closed 
    void shouldClose(bool val)
    {
        glfwSetWindowShouldClose(handle, cast(int)val);
    }
    
    /// Called by renderer when the window order comes to be checked
    void pollEvents()
    {
        glfwPollEvents();
    }
    
    /// Called by renderer when the window order comes to be checked
    void swapBuffers()
    {
        glfwSwapBuffers(handle);
    }
    
    /// Should be called before rendering to the window
    void makeContextCurrent()
    {
    	glfwMakeContextCurrent(handle);
    }
    
    /// Setting scene background color to $(B c).
	void backgroundColor(Color)(Color c)
		if(isColor!Color)
	{
		makeContextCurrent();
		
		driver.backgroundColor = c;
	}
	
    override bool opEquals(Object obj)
    {
        if(auto win = cast(GLFWWindow)obj)
        {
            return win.handle == handle;
        }
        else
        {
            return false;
        }
    }
    
    package GLFWwindow* handle;
    private GLFW3OpenGL3Driver driver;
    
    private struct WindowDescr
    {
        GLFWWindow window;
        void delegate(GLFWWindow window, vec2!uint pos) positionCallback;
        void delegate(GLFWWindow window, vec2!uint size) sizeCallback;
        void delegate(GLFWWindow window) closeCallback;
        void delegate(GLFWWindow window) refreshCallback;
        void delegate(GLFWWindow window, bool flag) focusCallback;
        void delegate(GLFWWindow window, bool flag) iconifyCallback;
        void delegate(GLFWWindow window, vec2!uint size) framebufferSizeCallback;
        
        void delegate(GLFWWindow, MouseButton, MouseButtonAction, Modificators)
            mouseButtonCallback;
        void delegate(GLFWWindow, vec2!double) cursorPosCallback;
        void delegate(GLFWWindow, bool) cursorEnterCallback;
        void delegate(GLFWWindow, vec2!double) scrollCallback;
        void delegate(GLFWWindow, KeyboardKey, uint, KeyboardKeyAction, Modificators)
            keyCallback;
        void delegate(GLFWWindow, dchar) charCallback;
        
        this(B)(GLFWWindow window, B behavior)
            if(isWindowBehavior!B)
        {
            this.window = window;
            positionCallback        = toDelegate(&behavior.positionCallback);
            sizeCallback            = toDelegate(&behavior.sizeCallback);
            closeCallback           = toDelegate(&behavior.closeCallback);
            refreshCallback         = toDelegate(&behavior.refreshCallback);
            focusCallback           = toDelegate(&behavior.focusCallback);
            iconifyCallback         = toDelegate(&behavior.iconifyCallback);
            framebufferSizeCallback = toDelegate(&behavior.framebufferSizeCallback);
            
            mouseButtonCallback     = toDelegate(&behavior.mouseButtonCallback);
            cursorPosCallback       = toDelegate(&behavior.cursorPosCallback);
            cursorEnterCallback     = toDelegate(&behavior.cursorEnterCallback);
            scrollCallback          = toDelegate(&behavior.scrollCallback);
            keyCallback             = toDelegate(&behavior.keyCallback);
            charCallback            = toDelegate(&behavior.charCallback);
        } 
    }
    private static __gshared WindowDescr[GLFWwindow*] callbacksMap;
}