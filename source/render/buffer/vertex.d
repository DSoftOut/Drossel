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
module render.buffer.vertex;

import derelict.opengl3.gl3;

import render.buffer.buffer;
import math.vec;

/// Buffer that stores GPU vertices
struct VertexBuffer(BufferType btype)
{
    enum GLenum glType = GL_FLOAT;
    enum size_t elementSize = 3;
    
	mixin genDynamicBuffer!(vec3!float, btype);
}

static assert(isBuffer!(VertexBuffer!(BufferType.Static)));
static assert(isBuffer!(VertexBuffer!(BufferType.Dynamic)));
static assert(isBuffer!(VertexBuffer!(BufferType.Stream)));