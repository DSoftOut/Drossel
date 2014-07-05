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
*
*   Entry point for client configuration. Main thread is handled by rendering subsystem.
*/
module client.main;

import render.polygonal;
import render.glfw3.opengl3;
import render.glfw3.window;
import render.input.mouse;
import render.input.mods;
import render.input.keyboard;
import render.color;
import client.settings;
import util.log;
import util.vec;
import util.functional;
import std.stdio;

alias Renderer = PolygonalRenderer!(GLFW3OpenGL3Driver, GLFWWindow);
 
shared static this()
{
    initGlobalLogger!(Settings.loggerName);
} 

struct MainWindowBehavior
{
    void closeCallback(GLFWWindow window) 
    {
        window.shouldClose = true;
    }
     
    void mouseButtonCallback(GLFWWindow window, MouseButton button
            , MouseButtonAction action, Modificators mods)
    {
        writeln(button, " ", action, " ", mods);
    }
    
    void cursorPosCallback(GLFWWindow window, vec2!double pos)
    {
        writeln("Mouse pos: ", pos);
    }
    
    void cursorEnterCallback(GLFWWindow window, bool flag)
    {
        writeln("Curosor enter: ", flag);
    }
    
    void scrollCallback(GLFWWindow window, vec2!double offset)
    {
        writeln("Cursor scroll: ", offset);
    }
    
    void keyCallback(GLFWWindow window, KeyboardKey key, uint scancode
            , KeyboardKeyAction action, Modificators mods)
    {
        writeln("Key event: ", key, " ", scancode, " ", action, " ", mods); 
    }
    
    mixin addDefaultWindowBehavior!(GLFWWindow, __traits(allMembers, typeof(this)));
}
static assert(isWindowBehavior!MainWindowBehavior);

int main(string[] args)
{
    auto renderer = new Renderer();
    scope(exit) renderer.destroy();
    
    writeln("Printing monitors:");
    size_t i;
    foreach(monitor; renderer.driver.monitors)
    {
        write(i++, ": ");
        writeln(monitor.name);
        foreach(mode; monitor.videoModes)
        {
            writeln("size: ", mode.size, " colors: ", mode.colorBits, " refresh rate: ", mode.refreshRate);
        }
    }
    
    auto mainWindow = renderer.createWindow!MainWindowBehavior(vec2!uint(600, 800), "Test window!");
    mainWindow.backgroundColor = RGB(1.0f, 0.0f, 0.0f);
    
    renderer.startEventListening;
    return 0;
}