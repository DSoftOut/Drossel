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
module render.model.model;

import std.range;

import util.cinterface;

import render.model.mesh;

/**
*   Model handles several meshes and controls their visibility, animation
*   and other global visual parameters.
*/
struct CIModel
{
    /**
    *   Returning range of meshes in the model
    */
    @trasient
    T meshes(T)() if(isInputRange!T && isMesh!(ElementType!T));
    
    /**
    *   Adding mesh to the model
    */
    @trasient
    This addMesh(T)(T mesh) if(isMesh!T);
    
    /**
    *   Removing mesh from the model if can find
    */
    @trasient
    This removeMesh(T)(T mesh) if(isMesh!T);
}

/// Checks if T is a model
template isModel(T)
{
    enum isModel = isExpose!(T, CIModel);
}