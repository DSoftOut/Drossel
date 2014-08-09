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
module render.model.mesh;

import util.cinterface;
import util.functional;

/**
*   Compile-time interface for a mesh. Mesh is consists of:
*   - buffers (vertex, color, normal)
*   - shader program
*/
struct CIMesh
{
    /// Name of the mesh
    enum string name = "";
    
    /**
    *   Static associative array that holds $(B BufferSlot) values that 
    *   are correspond shader program slots for input buffers.
    *
    *   Each stored $(B Buffer) have to implement render.buffer.buffer
    *   compile-time interface.
    */
    @trasient
    alias buffers(BufferSlot, Buffer) = KeyValueList!(BufferSlot, Buffer);
    // if(isBuffer!Buffer)
    
    /**
    *   Stores type that describes GPU program to render $(B buffers).
    *
    *   $(B T) have to implement render.shader.program compile-time interface.
    */
    @trasient
    alias program(T) = T;
    // if(isShaderProgram!T)
}

/// Checks is $(B T) is an actually implements a Mesh
template isMesh(T)
{
    enum isMesh = isExpose!(T, CIMesh);
}
