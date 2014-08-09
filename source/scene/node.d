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
module scene.node;

import std.range;
import std.traits;
import std.typecons;

import math.vec;
import math.quaternion;
import util.cinterface;

import render.model.model;

/// Thrown by SceneNode if getting parent of root scene node.
class ParentOfRootNodeException : Exception
{
    @safe pure nothrow this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
    
    @safe pure nothrow this(string msg, Throwable next, string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line, next);
    }
}

/**
*   Scene consists of tree hierarchy of scene nodes, that handles info about
*   relative translation and rotation.
*
*   Nodes doesn't handle graphical information, it is attached via models and meshes. 
*
*   Note: The implementation should be a reference type.
*/
struct CISceneNode
{
    /**
    *   Returns primary children of the scene node.
    */
    @trasient
    T children(T)() if(isInputRange!T && isSceneNode!(ElementType!T));
    
    /**
    *   Returns parent node.
    *
    *   Throws: ParentOfRootNodeException if getting parent of root.
    */
    @trasient
    T parent(T)() if(isSceneNode!T);
    
    /**
    *   Returns node position relative to parent one. 
    */
    @trasient
    vec3!T position(T)() if(isFloatingPoint!T);
    
    /**
    *   Returns node rotation relative to parent one.
    */
    @trasient
    quat!T rotation(T)() if(isFloatingPoint!T);
    
    /**
    *   Setting node position relative to parent one.
    */
    @trasient
    This position(this This, T)(vec3!T val) if(isFloatingPoint!T);
    
    /**
    *   Setting node rotation relative to parent one.
    */
    @trasient
    This rotation(this This, T)(quat!T val) if(isFloatingPoint!T);
    
    /**
    *   Returns node position relative to root one. 
    */
    @trasient
    vec3!T absolutePosition(T)() if(isFloatingPoint!T);
    
    /**
    *   Returns node rotation relative to root one.
    */
    @trasient
    quat!T absoluteRotation(T)() if(isFloatingPoint!T);
    
    /**
    *   Adding child to the scene node.
    */
    @trasient
    This addChild(this This, T)(T child) if(isSceneNode!T);
    
    /**
    *   Removing child if can find.
    */
    @trasient
    This removeChild(this This, T)(T child) if(isSceneNode!T);
    
    /**
    *   Getting range of all models attached to the node.
    */
    @trasient
    T models(T)() if(isInputRange!T && isModel!(ElementType!T));
    
    /**
    *   Attaching model to the scene node.
    */
    @trasient
    This attach(this This, T)(T model) if(isModel!T);
    
    /**
    *   Detaching model from the scene node if can find
    */
    This detach(this This, T)(T model) if(isModel!T);
}

/// Checking if T is implementing scene node interface
template isSceneNode(T)
{
    enum isSceneNode = isExpose!(T, CISceneNode);
}