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
module render.color;

import std.traits;

import util.cinterface;
import math.vec;

/// Compile time interface for colors
struct CIColor
{
	/// Components count
	enum size_t length = 0; 
	
	/// Translates the color to opengl format [0, 1]
	@trasient
	Vector!(float, n) toGLClampf(size_t n)()
		if(n == length);
		
	/// Converting to opengl RGB format
	vec3!float toGLRGB();
	
	/// Converting to opengl RGB format
	vec4!float toGLRGBA();
}

/// Checking is $(B T) actual color type
template isColor(T)
{
	template hasToGLClampf(T)
	{
		static if(hasMember!(T, "toGLClampf"))
		{
			alias RetType = ReturnType!(__traits(getMember, T, "toGLClampf"));
			
			static if(is(RetType : Vector!(float, n), size_t n))
			{
				enum hasToGLClampf = n == T.length;
			} else
			{
				enum hasToGLClampf = false;
			}
		}
		else
		{
			enum hasToGLClampf = false;
		}
	}
	
	enum isColor = isExpose!(T, CIColor) && hasToGLClampf!T;
}

/// Color with red green and blue components
struct RGB
{
	/// Components count
	enum size_t length = 3;
	
	/// Color components
	float[length] components = [0.0f, 0.0f, 0.0f];
	
	/// Creating from components
	this(float[length] args...)
	{
		components = args;
	}
	
	/// Red component
	float r() const
	{
		return components[0];
	}
	
	/// Green component
	float g() const
	{
		return components[1];
	}
	
	/// Blue component
	float b() const
	{
		return components[2];
	}
	
	/// Red component
	void r(float val)
	{
		components[0] = val;
	}
	
	/// Green component
	void g(float val)
	{
		components[1] = val;
	}
	
	/// Blue component
	void b(float val)
	{
		components[2] = val;
	}
	
	/// Translates the color to opengl format [0, 1]
	vec3!float toGLClampf()
	{
		return vec3!float(components);
	}
	
	/// Converting to opengl RGB format
	vec3!float toGLRGB()
	{
		return vec3!float(components);
	}
	
	/// Converting to opengl RGB format
	vec4!float toGLRGBA()
	{
		return vec4!float([r, g, b, 0.0f]);
	}
}
static assert(isColor!RGB);

/// Color with red green blue and alpha components
struct RGBA
{
	/// Components count
	enum size_t length = 4;
	
	/// Color components
	float[length] components = [0.0f, 0.0f, 0.0f, 0.0f];
	
	/// Creating from components
	this(float[length] args...)
	{
		components = args;
	}
	
	/// Red component
	float r() const
	{
		return components[0];
	}
	
	/// Green component
	float g() const
	{
		return components[1];
	}
	
	/// Blue component
	float b() const
	{
		return components[2];
	}
	
	/// Alpha component
	float a() const
	{
		return components[3];
	}
	
	/// Red component
	void r(float val)
	{
		components[0] = val;
	}
	
	/// Green component
	void g(float val)
	{
		components[1] = val;
	}
	
	/// Blue component
	void b(float val)
	{
		components[2] = val;
	}
	
	/// Alpha component
	void a(float val)
	{
		components[3] = val;
	}
	
	/// Translates the color to opengl format [0, 1]
	vec4!float toGLClampf()
	{
		return vec4!float(components);
	}
	
	/// Converting to opengl RGB format
	vec3!float toGLRGB()
	{
		return vec3!float([r, g, b]);
	}
	
	/// Converting to opengl RGB format
	vec4!float toGLRGBA()
	{
		return vec4!float(components);
	}
}
static assert(isColor!RGBA);

