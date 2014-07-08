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
*	Describes angle measure units as separate types. This helps to prevent degree/radian hell.
*/
module math.angle;

public
{
	import std.math;
	import std.conv;
}

/// Radian
/**
*	Radian is central angle of circle sector with arc length equal to the circle radius.
*/
struct Radian
{
	double value;
	alias value this;
	
	/// Creating from raw value
	this(double value)
	{
		this.value = value;
	}
	
	/// Converts degrees to radians
	this(Degree value)
	{
		this.value = (cast(double)value) * (PI / 180.0);
	}
	///
	unittest
	{
		assert(approxEqual(PI, Degree(180.0).to!Radian));
		assert(approxEqual(1.0, Degree(57.2957795).to!Radian));
	}
	
	/// Trims radian angle in range (-2*PI..2*PI).
	ref Radian trim()
	{
		while( value > 2*PI || approxEqual(value, 2*PI))
			value -= 2*PI;
		while( value < -2*PI  || approxEqual(value, -2*PI)) 
			value += 2*PI;
		return this;
	}
	///
	unittest
	{
		assert(approxEqual(Radian(PI/6).trim, PI/6));
		assert(approxEqual(Radian(-PI/3).trim, -PI/3));
		assert(approxEqual(Radian(4*PI).trim, 0));
		assert(approxEqual(Radian(-6*PI).trim, 0));
		assert(approxEqual(Radian(8*PI/3).trim, 2*PI/3));
		assert(approxEqual(Radian(-13*PI/6).trim, -PI/6));
	}
}

/// Degree
/**
*	Degree is 1/360 part of full angle.
*/
struct Degree
{
	double value;
	alias value this;
	
	/// Creating from raw value
	this(double value)
	{
		this.value = value;
	}
	
	/// Converts radians to degrees
	this(Radian value)
	{
		this.value = (cast(double)value) * (180.0 / PI);
	}
	///
	unittest
	{
		assert(approxEqual(180.0,Radian(PI).to!Degree));
		assert(approxEqual(57.2957795, Radian(1.0).to!Degree));
	}
	
	/// Trims degree angle in range (-360.0..360.0).
	ref Degree trim()
	{
		while( value > 360.0 || approxEqual(value, 360.0))
			value -= 360.0;
		while( value < -360.0  || approxEqual(value, -360.0)) 
			value += 360.0;
		return this;
	}
	///
	unittest
	{
		assert(approxEqual(Degree(30.0).trim, 30.0));
		assert(approxEqual(Degree(-60.0).trim, -60.0));
		assert(approxEqual(Degree(720.0).trim, 0.0));
		assert(approxEqual(Degree(-1080.0).trim, 0.0));
		assert(approxEqual(Degree(480.0).trim, 120.0));
		assert(approxEqual(Degree(-390).trim, -30));
	}
}

/// Determines is T is some angle
template isAngle(T)
{
	enum isAngle = is(T == Radian) || is(T == Degree);
}
