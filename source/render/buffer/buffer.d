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
module render.buffer.buffer;

import std.traits;
import std.range;

import derelict.opengl3.gl3;

import util.cinterface;

/// Describes buffer data updating strategy
enum BufferType
{
	/// The data store contents will be modified once and used many times.
	Static,
	/// The data store contents will be modified repeatedly and used many times.
	Dynamic,
	/// The data store contents will be modified once and used at most a few times.
	Stream,
}

/// Translates BufferType to corresponding OpenGL enum 
uint mapBufferTypeToGL(BufferType type)
{
	final switch(type)
	{
		case(BufferType.Static):  return GL_STATIC_DRAW;
		case(BufferType.Dynamic): return GL_DYNAMIC_DRAW;
		case(BufferType.Stream):  return GL_STREAM_DRAW;
	}
}

/// Compile time interface for buffers
/**
*	Stores some uniform data that is synchronized with GPU.
*
*	Vertex, color, normal and other buffers are example of implementation
*	of the interface.
*/
struct CIBuffer 
{
	/// Getting raw data of the buffer
	void[] rawData();
	
	/// OpenGL buffer where data is stored on GPU side
	GLenum id();
	
	/// Stored element of data
	@trasient
	alias Element = ubyte;
	
	/// Type of elementary element for OpenGL driver
	/**
	*  If $(B Element) is vector of floats, then 
	*  $(B glType) should be GL_Float.
	*/
	enum GLenum glType = GL_FLOAT;
	
	/// Count of elementary elements in buffer element
	/**
	*  If $(B Element) is vec3!float, then $(B elementSize)
	*  should be equal 3.
	*/
	enum size_t elementSize = 3;
	
	/// Getting data of the buffer
	@trasient
	Element[] data();
	
	/// Getting buffer type
	BufferType type();
	
	/// If there is data to be loaded to GPU?
	bool dirty();
	
	/// Loads changes from CPU side to GPU
	void update();
	
	/// Updates element of the buffer at place $(B i)
	/**
	*	Does nothing for static buffers
	*/
	@trasient
	Element opIndexAssign(Element e, size_t i);
	
	/// Reading element at place $(B i)
	@trasient
	Element opIndex(size_t i);
	
	/// Filling the buffer with element $(B e)
	/**
	*	Does nothing for static buffers
	*/
	@trasient
	Element opSliceAssign(Element e);
	
	/// Filling part of the buffer with element $(B e)
	/**
	*	Does nothing for static buffers
	*/
	@trasient
	Element opSliceAssign(Element e, size_t x, size_t y);

	/// Filling the buffer with range of elements $(B r)
	/**
	*	Does nothing for static buffers
	*/
	@trasient
	void opSliceAssign(R)(R r)
		if(isInputRange!R && is(ElementType!R == Element));
	
	/// Filling part of the buffer with range of elements $(B r)
	/**
	*	Does nothing for static buffers
	*/
	@trasient
	void opSliceAssign(R)(R r, size_t x, size_t y)
		if(isInputRange!R && is(ElementType!R == Element));	
	
	/// buffer[] operator 
	@trasient
	Element[] opSlice();
	
	/// Slicing operator
	@trasient
	Element[] opSlice(size_t x, size_t y);

	/// Operator $
	@trasient
	size_t opDollar(size_t pos)();
}

/// Checking if actually $(B T) is a buffer
template isBuffer(T)
{
	template hasData()
	{
		static if(hasMember!(T, "data"))
		{
			alias RT = ReturnType!(__traits(getMember, T, "data"));
			enum hasData = isArray!RT;
		} else
		{
			enum hasData = false;
		}
	}
	
	enum isBuffer = isExpose!(T, CIBuffer) && hasData!();
}

/**
*	Generates default implementation for buffers filled with $(B ElementType)
*	with updating strategy $(B btype).
*
*	That buffers can be filled only in run-time.
*/
mixin template genDynamicBuffer(ElementType, BufferType btype)
{
	import std.bitmanip;

	import derelict.opengl3.gl3;
	
	import render.buffer.buffer;
	
	/// Stored element of data
	alias Element = ElementType;

	/// Creating from array of data
	this(const(Element[]) pdata = [])
	{
		_data = pdata.dup;
		static if(btype != BufferType.Static)
			changeMap.length = _data.length;
			
		glGenBuffers(1, &_buffer);
		glBindBuffer(GL_ARRAY_BUFFER, _buffer);
		glBufferData(GL_ARRAY_BUFFER, rawData.length, rawData.ptr, btype.mapBufferTypeToGL);
	}

	/// OpenGL buffer where data is stored on GPU side
	GLenum id()
	{
		return _buffer;
	}
	
	/// Getting raw data of the buffer
	void[] rawData()
	{
		return cast(void[]) _data;
	}
		
	/// Getting raw data of the buffer
	const(void[]) rawData() const
	{
		return cast(void[]) _data;
	}
	
	/// Getting data of the buffer
	Element[] data()
	{
		return _data;
	}
	
	/// Getting data of the buffer
	const(Element[]) data() const
	{
		return _data;
	}
	
	/// Getting buffer type
	BufferType type()
	{
		return btype;
	}
	
	/// If there is data to be loaded to GPU?
	bool dirty()
	{
		static if(btype == BufferType.Static)
		{
			return false;
		}
		else
		{
			return _dirty;
		}
	}
	
	/// Loads changes from CPU side to GPU
	void update()
	{
		static if(btype != BufferType.Static)
		{
			if(_dirty)
			{
				glBindBuffer(GL_ARRAY_BUFFER, _buffer);
				
				// Scanning buffer for changes
				for(size_t i = 0; i < changeMap.length; i++)
				{
					if(changeMap[i])
					{
						size_t j = i;
						while(j < changeMap.length && changeMap[j]) j++;
						
						// Loading data
						glBufferSubData(GL_ARRAY_BUFFER
							, i*Element.sizeof, (j-i+1)*Element.sizeof
							, rawData[i*Element.sizeof .. (j+1)*Element.sizeof].ptr);
					}
				}
				
				// Cleaning helping structures
				_dirty = false;
				changeMap.length = 0;
				changeMap.length = _data.length;
			}
		}
	}
	
	/// Updates element of the buffer at place $(B i)
	/**
	*	Does nothing for static buffers
	*/
	Element opIndexAssign(Element e, size_t i)
	{
		static if(btype != BufferType.Static)
		{
			_data[i] = e;
		}
		return e;
	}
	
	/// Reading element at place $(B i)
	Element opIndex(size_t i)
	{
		return _data[i];
	}
	
	const(Element) opIndex(size_t i) const
	{
		return _data[i];
	}
	
	/// Filling the buffer with element $(B e)
	/**
	*	Does nothing for static buffers
	*/
	Element opSliceAssign(Element e)
	{
		static if(btype != BufferType.Static)
		{
			_data[] = e;
		}
		return e;
	}
	
	/// Filling part of the buffer with element $(B e)
	/**
	*	Does nothing for static buffers
	*/
	Element opSliceAssign(Element e, size_t x, size_t y)
	{
		static if(btype != BufferType.Static)
		{
			_data[x .. y] = e;
		}
		return e;
	}

	/// Filling the buffer with range of elements $(B r)
	/**
	*	Does nothing for static buffers
	*/
	void opSliceAssign(R)(R r)
		if(isInputRange!R && is(ElementType!R == Element))
	{
		static if(btype != BufferType.Static)
		{
			_data[] = r[];
		}
	}
	
	/// Filling part of the buffer with range of elements $(B r)
	/**
	*	Does nothing for static buffers
	*/
	void opSliceAssign(R)(R r, size_t x, size_t y)
		if(isInputRange!R && is(ElementType!R == Element))
	{
		static if(btype != BufferType.Static)
		{
			_data[x .. y] = r[];
		}
	}
		
	/// buffer[] operator 
	Element[] opSlice()
	{
		return _data;
	}
	
	const(Element[]) opSlice() const
	{
		return _data;
	}
	
	/// Slicing operator
	Element[] opSlice(size_t x, size_t y)
	{
		return _data[x .. y];
	}

	const(Element[]) opSlice(size_t x, size_t y) const
	{
		return _data[x .. y];
	}
	
	/// Operator $
	size_t opDollar(size_t pos)() const
	{
		return _data.length;
	}
	
	private
	{
		Element[] _data;
		GLenum _buffer;
		
		static if(btype != BufferType.Static)
		{
			bool _dirty = true;
			
			/// Storing where changes were occurred
			BitArray changeMap;
		}
	}
}