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
*   Quaternion implementation for rotation utilities.
*
*   The main advantage over matrices is a invariant order of rotation and lesser computation
*   cost.
*/
module math.quaternion;

import std.conv;
import std.math;

import util.functional;

import math.angle;
import math.vec;
import math.matrix;

/// Shortcut similar to vectors
alias quat(T) = Quaternion!T;

/// Mathematical quaternion for rotation purposes
struct Quaternion(T)
{
    T x, y, z, w;
    
    /// Returns zeroed quaternion
    static Quaternion!T zero() pure @safe nothrow
    {
        return Quaternion(cast(T)0, cast(T)0, cast(T)0, cast(T)0);
    }
    
    /// Returns unit quaternion
    static Quaternion!T one() pure @safe nothrow
    {
        return Quaternion(cast(T)1, cast(T)0, cast(T)0, cast(T)0);
    }
    
    /// Explicit creation from elements
    this(T[4] elems...) pure @safe nothrow
    {
        x = elems[0];
        y = elems[1];
        z = elems[2];
        w = elems[3];
    }
    
    /// Explicit creation from vector elements
    this(Vector!(T, 4) vec) pure @safe nothrow
    {
        x = vec.x;
        y = vec.y;
        z = vec.z;
        w = vec.w;
    }
    
    /// Explicit casting to vector
    U opCast(U)() pure @safe nothrow 
        if(is(U == Vector!(T, 4)))
    {
        return vec4!T(x, y, z, w);
    }
    
    /// Creating quaternion for rotation
    /**
    *   Params:
    *       axis    Axis of rotation, could be not normalized
    *       angle   Amount of rotation, could be not trimed in [0, 2*Pi]
    */
    this(Angle)(Vector!(T, 3) axis, Angle angle) pure @safe nothrow
        if(isAngle!Angle)
    {
        axis.normalized;
        angle.trim;
        
        immutable t = sin(angle/2);
        x = axis.x*t;
        y = axis.y*t;
        z = axis.z*t;
        w = cos(angle/2);
    }
    
    /// Creating quaternion from Euler angles
    this(T pitch, T yaw, T roll) pure @safe nothrow
    {
        immutable cos_z_2 = cos(0.5*roll);
        immutable cos_y_2 = cos(0.5*yaw);
        immutable cos_x_2 = cos(0.5*pitch);
        
        immutable sin_z_2 = sin(0.5*roll);
        immutable sin_y_2 = sin(0.5*yaw);
        immutable sin_x_2 = sin(0.5*pitch);
        
        w = cos_z_2*cos_y_2*cos_x_2 + sin_z_2*sin_y_2*sin_x_2;
        x = cos_z_2*cos_y_2*sin_x_2 - sin_z_2*sin_y_2*cos_x_2;
        y = cos_z_2*sin_y_2*cos_x_2 + sin_z_2*cos_y_2*sin_x_2;
        z = sin_z_2*cos_y_2*cos_x_2 - cos_z_2*sin_y_2*sin_x_2;
    }
    
    /// Creating quaternion from Euler angles
    this(Vector!(T, 3) angles) pure @safe nothrow
    {
        this(angles.pitch, angles.yaw, angles.roll);
    }
    
    /// Creating from rotation matrix
    this(Matrix!(T, 3, 3) m) pure @safe nothrow
    {
        immutable tr = m.trace;
        if(tr > 0) // then w is biggest component
        {
            x = m[1,2] - m[2,1];
            y = m[2,0] - m[0,2];
            z = m[0,1] - m[1,0];
            w = tr + cast(T)1;
            
            immutable t = cast(T)0.5 / sqrt(w); // contains norm * 4
            x *= t;
            y *= t;
            z *= t;
            w *= t;
        }
        else if( (m[0,0] > m[1,1]) && (m[0,0] > m[2,2]) )
        {
            x = (cast(T)1 + m[0,0] - m[1,1] - m[2,2]);
            y = m[1,0] + m[0,1];
            z = m[2,0] + m[0,2];
            w = m[1,2] - m[2,1];
            
            immutable t = cast(T)0.5 / sqrt(x);
            x *= t;
            y *= t;
            z *= t;
            w *= t; 
        }
        else if( m[1,1] > m[2,2] )
        {
            x = m[1,0] + m[0,1];
            y = cast(T)1 + m[1,1] - m[0,0] - m[2,2];
            z = m[2,1] + m[1,2];
            w = m[2,0] - m[0,2];
            
            immutable t = cast(T)0.5 / sqrt(y);
            x *= t;
            y *= t;
            z *= t;
            w *= t;
        }
        else
        {
            x = m[2,0] + m[0,2];
            y = m[2,1] + m[1,2];
            z = cast(T)1 + m[2,2] - m[0,0] - m[1,1];
            w = m[0,1] - m[1,0];
            
            immutable t = cast(T)0.5 / sqrt(z);
            x *= t;
            y *= t;
            z *= t;
            w *= t;
        }
    }
    
    /// Explicit casting to rotation matrix
    U opCast(U)() pure @safe nothrow 
        if(is(U == Matrix!(T, 4, 4))) 
    {
        Matrix!(T, 4, 4) ret;
        immutable s = cast(T)2 / length; // 4 multiplications, 3 additions and 1 division
        immutable x2 = x * s,  y2 = y * s,  z2 = z * s;
        immutable xx = x * x2, xy = x * y2, xz = x * z2;
        immutable yy = y * y2, yz = y * z2, zz = z * z2;
        immutable wx = w * x2, wy = w * y2, wz = w * z2;
        
        ret[0,0] = 1.0f - (yy + zz);
        ret[1,0] = xy - wz;
        ret[2,0] = xz + wy;

        ret[0,1] = xy + wz;
        ret[1,1] = 1.0f - (xx + zz);
        ret[2,1] = yz - wx;

        ret[0,2] = xz - wy;
        ret[1,2] = yz + wx;
        ret[2,2] = 1.0f - (xx + yy);
        ret[3,3] = 1.0f;
        return ret;
    }
    
    /// Returns axis of rotation coded by the quaternion
    vec3!T axis() const pure @safe nothrow 
    {
        vec3!float ret;
        immutable t = sin(acos(w));
        ret.x = x/t;
        ret.y = y/t;
        ret.z = z/t;
        return ret;
    }
    
    /// Returns vector part of the quaternion
    vec3!T vec() const pure @safe nothrow
    {
        vec3!T ret;
        ret.x = x;
        ret.y = y;
        ret.z = z;
        return ret;
    }
    
    /// Setting vector part of the quaternion
    auto ref Quaternion!T vec(Vector!(T, 3) val) pure @safe nothrow
    {
        x = val.x;
        y = val.y;
        z = val.z;
        return this;
    }
    
    /// Getting scalar part of the quaternion
    T scalar() const pure @safe nothrow
    {
        return w;
    }
    
    /// Setting scalar part of the quaternion
    auto ref Quaternion!T scalar(T val) pure @safe nothrow
    {
        w = val;
        return this;
    }
    
    /// Returning angle that the quaternion is performing
    Radian angle() const pure @safe nothrow
    {
        return Radian(2*acos(w));
    }
    
    /// addition and substraction
    Quaternion!T opBinary(string op, U)(Quaternion!U q) const pure @safe nothrow 
        if((op == "+" || op == "-") && hasOp!(T, U, op)) 
    {
        Quaternion ret;
        ret.x = mixin("x "~op~" q.x");
        ret.y = mixin("y "~op~" q.y");
        ret.z = mixin("z "~op~" q.z");
        ret.w = mixin("w "~op~" q.w");
        return ret;
    }

    /// Multiplication
    Quaternion!T opBinary(string op, U)(Quaternion!U q) const pure @safe nothrow  
        if(op=="*" && hasOp!(T, U, op))
    {
        Quaternion ret; // a = w, b = x, c = y, d = z
        ret.x = w*q.x + x*q.w + y*q.z - z*q.y; // a1*b2+b1*a2+c1*d2-d1*c2
        ret.y = w*q.y - x*q.z + y*q.w + z*q.x; // a1*c2-b1*d2+c1*a2+d1*b2
        ret.z = w*q.z + x*q.y - y*q.x + z*q.w; // a1*d2+b1*c2-c1*b2+d1*a2
        ret.w = w*q.w - x*q.x - y*q.y - z*q.z; // a1*a2-b1*b2-c1*c2-d1*d2
        return ret;
    }

    /// Length
    T length() const pure @safe nothrow  
    {
        return cast(T)sqrt(w*w + x*x + y*y + z*z);
    }

    /// Squared length
    /**
    *   Cheaper then length
    */
    T length2() const pure @safe nothrow  
    {
        return w*w + x*x + y*y + z*z;
    }

    /// Quaternion conjugation, inverting w component
    Quaternion!T conjugation() const pure @safe nothrow 
    {
        Quaternion!T ret;
        ret.x = x;
        ret.y = y;
        ret.z = z;
        ret.w = -w;
        return ret;
    }

    /// Returning quaternion with length equal 1
    void normalize() pure @safe nothrow
    {
        immutable l = length;
        x = x/l;
        y = y/l;
        z = z/l;
    }

    /// Returning quaternion with length equal 1
    Quaternion!T normalized() const pure @safe nothrow
    {
        Quaternion!T ret;
        
        immutable l = length;
        ret.x = x/l;
        ret.y = y/l;
        ret.z = z/l;
        
        return ret;
    }
    
    /// Invertion
    /**
    *   Inverted quaternion restores previous rotation state.
    */
    Quaternion!T invert() const pure @safe nothrow
    {
        auto ret = conjugation();
        immutable l = length;
        ret.x /= l;
        ret.y /= l;
        ret.z /= l;
        return ret;
    }
    
    /// Vector rotation by the quaternion
    /**
    *   The quaternion should be created from axis and angle or from rotation matrix or Euler angles to 
    *   avoid invalid rotations.
    */
    vec3!T rotate(vec3!T v) const pure @safe nothrow
    {
        assert(approxEqual(length, cast(T)1), "Invalid state of quaternion for rotation, length should be equal 1");
        Quaternion vq;
        vq.vec = v;
        vq.w = cast(T)0;
        immutable vqt = this * vq * conjugation;
        return vqt.vec*(-1);
    }
}
unittest
{
    immutable q = quat!float(vec3!float(0, 1, 0), Radian(PI/2.0));
    immutable vec = q.rotate(vec3!float(1.0f, 0.0f, 0.0f));
    assert(vec.approxEqual(vec3!float(0, 0, -1)));
    assert(q.rotate(vec).approxEqual(vec3!float(-1, 0, 0)));
}
unittest
{
    immutable a = vec3!float(1.0f,2.0f,3.0f);

    for(float angle = 0.0f; angle <= 2*PI; angle+=PI/20.0f)
    {
        immutable b = rotationMatrix3(vec3!float(angle, 0.0f, 0.0f))*a;
        immutable q = Quaternion!float(angle, 0.0f, 0.0f);
        immutable c = q.rotate(a);
        assert(b.approxEqual(c), text("Rotation pitch test failed for angle = ",angle,". ",b," != ", c));
    }
}
unittest
{
    immutable a = vec3!float(1.0f,2.0f,3.0f);
    for(float angle = 0.0f; angle <= 2*PI; angle+=PI/20.0f)
    {
        immutable b = rotationMatrix3(vec3!float(0.0f, angle, 0.0f))*a;
        immutable q = Quaternion!float(0.0f, angle, 0.0f);
        immutable c = q.rotate(a);
        assert(b.approxEqual(c), text("Rotation yaw test failed for angle = ",angle,". ",b," != ", c));
    }
}
unittest
{
    immutable a = vec3!float(1.0f,2.0f,3.0f);
    for(float angle = 0.0f; angle <= 2*PI; angle+=PI/20.0f)
    {
        immutable b = rotationMatrix3(vec3!float(0.0f, 0.0f, angle))*a;
        immutable q = Quaternion!float(0.0f, 0.0f, angle);
        immutable c = q.rotate(a);
        assert(b.approxEqual(c), text("Rotation roll test failed for angle = ",angle,". ",b," != ", c));
    }
}