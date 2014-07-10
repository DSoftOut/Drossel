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
module math.matrix;

import std.algorithm;
import std.array;
import std.conv;
import std.format;
import std.math;
import std.traits;

import math.angle;
import math.vec;
import util.functional;

/// Alias for square matrices
alias SquareMatrix(Element, size_t n) = Matrix!(Element, n, n);

/// Shortcut for square 1x1 matrix
alias mat11(Element) = SquareMatrix!(Element, 1);
/// Shortcut for square 2x2 matrix
alias mat22(Element) = SquareMatrix!(Element, 2);
/// Shortcut for square 3x3 matrix
alias mat33(Element) = SquareMatrix!(Element, 3);
/// Shortcut for square 4x4 matrix
alias mat44(Element) = SquareMatrix!(Element, 4);

/**
*   Matrix with $(B n) rows and $(B m) columns with type of element
*   equal to $(B Element). Internally it is a static array of $(B Element) 
*   values, stored at column order (to match OpenGL native representation).
*
*   Matrix supports pretty printing:
*   -------------
*   writefln("%p", mat33!int([
*               [-44343, 0, 0],
*               [0, 565656, 0],
*               [0, 0, 0],
*           ]));
*   // Will output:
*   mat33!int(
*   -44343,     0,0,
*        0,565656,0,
*        0,     0,0,
*   )
*   -------------
*/
struct Matrix(Element, size_t n, size_t m)
{
    /// Alias for type of this matrix
    alias ThisMatrix = Matrix!(Element, n, m);
    /// Alias for element type
    alias MatrixElement = Element;
    /// Count of rows
    enum rowsCount = n;
    /// Count of columns
    enum columnsCount = m;
    /// Count of elements
    enum elementsCount = rowsCount * columnsCount;
    
    /// Is matrix square (rows == columns)
    template isSquare()
    {
        enum isSquare = n == m;
    }
    
    /// Checks if elements have an operator $(B op)
    template elementHasOp(string op)
    {
        enum elementHasOp = hasOp!(Element, Element, op);
    }
    
    /// Elements as 2-dimensional array, columns order
    Element[m][n] elements;
    
    /// Creates matrix 
    this(Element fillElement) pure nothrow @safe
    {
        (cast(Element[n*m])elements)[] = fillElement;
    }
    
    // 1x1 matrix constructors will conflict
    static if(elementsCount > 1)
    {
        /// Creating matrix from raw numbers in row order
        this(Element[n*m] elements...) pure nothrow @safe
        {
            this(cast(Element[n][m])elements);
        }
        
        /// Creating matrix from static array in row order
        this(Element[n][m] pelems) pure nothrow @safe
        {
            foreach(i; Iota!n)
            {
                foreach(j; Iota!m)
                {
                    elements[j][i] = pelems[i][j];
                }
            }
        }
    }
    
    /// Matrix filled with zeros 
    static ThisMatrix zeros() pure nothrow @safe
    {
        return ThisMatrix(cast(Element)0);
    }
    
    /// Matrix filled with ones
    static ThisMatrix ones() pure nothrow @safe
    {
        return ThisMatrix(cast(Element)1);
    }
    
    static if(isSquare!())
    {
        /// Identity matrix
        static ThisMatrix identity() pure nothrow @safe
        {
            auto mat = zeros;
            foreach(i; 0..n)
            {
                mat[i, i] = cast(Element)1;
            }
            return mat;
        }
    }
    
    /// Indexing matrix by row and column
    Element opIndex(size_t rowi, size_t columni) pure nothrow @safe 
    {
        return elements[columni][rowi];
    }
    
    /// Indexing matrix by row and column
    const(Element) opIndex(size_t rowi, size_t columni) pure nothrow @safe const 
    {
        return elements[columni][rowi];
    }
    
    /// Setting element of matrix by row and column index
    ref ThisMatrix opIndexAssign(Element e, size_t rowi, size_t columni) pure nothrow @safe
    {
        elements[columni][rowi] = e;
        return this;
    }
    
    /// Setting element of matrix by row and column index
    ref ThisMatrix opIndexOpAssign(string op)(Element e, size_t rowi, size_t columni) pure nothrow @safe
        if(elementHasOp!op)
    {
        mixin("elements[columni][rowi] "~op~"= e;");
        return this;
    }
    
    /// Comparing matrices with equal sizes
    bool opEquals(OtherElement)(auto ref const Matrix!(OtherElement, n, m) mat) const nothrow @safe
        if(hasOp!(Element, OtherElement, "=="))
    {
        bool res = true;
        foreach(i; Iota!n)
        {
            foreach(j; Iota!m)
            {
                res = res && this[i, j] == mat[i, j];
            }
        }
        return res;
    }
    
    /// Comparing with std.math.approxEqual
    bool approxEqual(OtherElement)(auto ref const Matrix!(OtherElement, n, m) mat
        , double maxRelDiff = 1e-2, double maxAbsDiff = 1e-5) const nothrow @safe
        if(__traits(compiles, std.math.approxEqual(Element.init, OtherElement.init, double.init, double.init)))
    {
        bool res = true;
        foreach(i; Iota!n)
        {
            foreach(j; Iota!m)
            {
                res = res && std.math.approxEqual(this[i, j], mat[i, j], maxRelDiff, maxAbsDiff);
            }
        }
        return res;
    }
    
    /// Operators for addition and subtraction of matrices
    ThisMatrix opBinary(string op)(in auto ref ThisMatrix mat) const pure nothrow @safe
        if(op == "+" || op == "-")
    {
        auto ret = ThisMatrix.zeros;
        foreach(i; Iota!n)
        {
            foreach(j; Iota!m)
            {
                ret[i,j] = mixin("this[i,j]" ~ op ~ "mat[i,j]");
            }
        }
        return ret;
    }
    
    /// Multiplication of vector and matrix
    Vector!(Element, n) opBinary(string op)(in auto ref Vector!(Element, m) vec) const pure nothrow @safe
        if(op == "*")
    {
        auto ret = Vector!(Element, n).zeros;
        foreach(i; Iota!n)
        {
            foreach(j; Iota!m)
            {
                ret[i] += vec[j]*this[i,j];  
            }
        }
        return ret;
    }
    
    /// Multiplication of matrices O(n^3)
    auto opBinary(string op, OtherElement, size_t k)
        (in auto ref Matrix!(OtherElement, m, k) mat) const pure nothrow @safe
        if(op == "*" && hasOp!(Element, OtherElement, "*"))
    {
        alias NewElement = typeof(Element.init * OtherElement.init);
        auto ret = Matrix!(NewElement, n, k).zeros;
        foreach(i; Iota!n)
        {
            foreach(j; Iota!k)
            {
                foreach(s; Iota!m)
                    ret[i,j] += this[i, s] * mat[s, j]; 
            }
        }
        return ret;
    }
    
    /// foreach over the matrix
    int opApply(int delegate(ref Element) dg)
    {
        foreach(ref val; cast(Element[n*m])elements)
        {
            auto result = dg(val);
            if (result) return result;
        }
        return 0;
    }
    
    /// foreach over the matrix
    int opApply(int delegate(const ref Element) dg) const
    {
        foreach(ref val; cast(Element[n*m])elements)
        {
            auto result = dg(val);
            if (result) return result;
        }
        return 0;
    }
    
    /// foreach over the matrix with indexes
    int opApply(int delegate(size_t i, size_t j, ref Element) dg)
    {
        foreach(j, ref column; elements)
        {
            foreach(i, ref val; column)
            {
                auto result = dg(i, j, val);
                if (result) return result;
            }
        }
        return 0;
    }
    
    /// foreach over the matrix with indexes
    int opApply(int delegate(size_t i, size_t j, const ref Element) dg) const
    {
        foreach(j, ref column; elements)
        {
            foreach(i, ref val; column)
            {
                auto result = dg(i, j, val);
                if (result) return result;
            }
        }
        return 0;
    }
    
    /// Getting array of rows
    Vector!(Element, m)[n] rows() const
    {
        return cast(Vector!(Element, m)[n])transpose.elements;
    }
    
    /// Getting specific row
    Vector!(Element, m) row(size_t i) const
    {
        Vector!(Element, m) vec;
        foreach(j; Iota!m)
        {
            vec[j] = this[i,j];
        }
        return vec;
    }
    
    /// Getting array of columns
    Vector!(Element, n)[m] columns() const
    {
        return cast(Vector!(Element, n)[m])elements;
    }
    
    /// Getting specific column
    Vector!(Element, n) column(size_t i) const
    {
        return cast(Vector!(Element, n))elements[i];
    }
    
    /// Mutates the matrix by swapping rows $(B i1) and $(B i2)
    ref ThisMatrix swapRows(size_t i1, size_t i2)
    {
        auto temp = row(i2);
        foreach(j; Iota!m)
        {
            this[i2, j] = this[i1, j];
            this[i1, j] = temp[j];
        }
        return this;
    }
    
    /// Mutates the matrix by swapping columns $(B j1) and $(B j2)
    ref ThisMatrix swapColumns(size_t j1, size_t j2)
    {
        swap(elements[j1], elements[j2]);
        return this;
    }
    
    /// Multiplies matrix row by specific value
    ref ThisMatrix multiplyRow()(size_t i, Element value)
        if(elementHasOp!"*")
    {
        foreach(j; Iota!m)
        {
            this[i, j] *= value;
        }
        return this;
    }
    
    /// Multiplies matrix row by specific value
    ref ThisMatrix multiplyColumn()(size_t j, Element value)
        if(elementHasOp!"*")
    {
        elements[j][] *= value;
        return this;
    }
    
    /// Getting pointer to inner data to pass matrix into OpenGL functions
    Element* toOpenGL() pure nothrow
    {
        return &elements[0][0];
    }
    
    /// Getting pointer to inner data to pass matrix into OpenGL functions
    const(Element)* toOpenGL() const pure nothrow
    {
        return &elements[0][0];
    }
    
    /// Creating matrix from OpenGL matrix
    /**
    *   Warning: function doesn't perform bounds checking!
    */
    static ThisMatrix fromOpenGL(in Element* glMatrix) pure nothrow
    {
        ThisMatrix mat;
        foreach(i, ref val; mat.elements)
            val = glMatrix[i];
        return mat;
    }
    
    /// Transposes the matrix
    ThisMatrix transpose() const pure nothrow @safe
    {
        auto mat = ThisMatrix.zeros;
        foreach(i; Iota!n)
        {
            foreach(j; Iota!m)
            {
                mat[i, j] = this[j, i];
            }
        }
        return mat;
    }
    
    static if(isSquare!())
    {
        /// Transforms the matrix to triangular
        private ThisMatrix triangular(T)(out size_t swaps, ref T mirror) const nothrow pure @safe
            if(is(T == Vector!(Element, n)) || is(T == ThisMatrix))
        {
            static if(elementsCount == 1) return this;
            else
            {
                // Copy matrix, here is desctructive updates
                ThisMatrix matrix = this;  
                // Swaps count
                swaps = 0;

                mainloop: foreach(i; Iota!n)
                {
                    // Special case, swaps rows if first element == 0
                    if(matrix[i,i] == cast(Element)0)
                    {
                        bool failed = true;
                        foreach(m; Iota!(i+1, n))
                        {
                            if(matrix[m,i] != cast(Element)0)
                            {
                                ++swaps;
                                matrix.swapRows(i, m);
                                static if(is(T == ThisMatrix))
                                {
                                    mirror.swapRows(i, m);
                                }
                                failed = false;
                                break;
                            } 
                        }
                        if(failed) break mainloop;
                    }
                    
                    
                    static if(is(T == ThisMatrix))
                    {
                        mirror.multiplyRow(i, 1/matrix[i,i]);
                    } else static if(is(T : Vector!(Element, n)))
                    {
                        mirror[i] /= matrix[i,i];
                    }
                    matrix.multiplyRow(i, 1/matrix[i,i]);
                    
                    // Substract rows
                    foreach(j; Iota!(i+1, n))
                    {
                        static if(is(T == ThisMatrix))
                        {
                            mirror.subtractRows(j, i, matrix[j,i]);
                        } else static if(is(T : Vector!(Element, n)))
                        {
                            mirror[j] -= mirror[i]*matrix[j,i];
                        }
                        matrix.subtractRows(j, i, matrix[j,i]);
                    }
                }
                
                return matrix;
            }
        }
        
        /// Transforms the matrix to triangular and count swaps
        ThisMatrix triangular()(out size_t swaps) const nothrow pure @safe
        {
            static if(elementsCount == 1) return this;
            else
            {
                // Copy matrix, here is desctructive updates
                ThisMatrix matrix = this;  
                // Swaps count
                swaps = 0;

                mainloop: foreach(i; Iota!n)
                {
                    // Special case, swaps rows if first element == 0
                    if(matrix[i,i] == cast(Element)0)
                    {
                        bool failed = true;
                        foreach(m; Iota!(i+1, n))
                        {
                            if(matrix[m,i] != cast(Element)0)
                            {
                                ++swaps;
                                matrix.swapRows(i, m);
                                failed = false;
                                break;
                            } 
                        }
                        if(failed) break mainloop;
                    }
                    
                    // Substract rows
                    foreach(j; Iota!(i+1, n))
                    {
                        matrix.subtractRows(j, i, matrix[j,i]/matrix[i,i]);
                    }
                }
                
                return matrix;
            }
        }
        
        /// Transforms the matrix to triangular
        ThisMatrix triangular()() const nothrow pure @safe
        {
            size_t swaps;
            return triangular(swaps);
        }
        
        /// Calculates determinant of the matrix
        Element determinant()() const pure nothrow @safe
            if(elementHasOp!"/" && elementHasOp!"-")
        {
            static if(elementsCount == 1) return elements[0];
            else
            {
                // Swaps count
                size_t swaps = 0;
                // Copy matrix, here is desctructive updates
                ThisMatrix matrix = triangular(swaps);  
                
                // determinant = product of elements on main diagonal 
                auto ret = cast(Element)1;
                foreach(i; Iota!n)
                    ret *= matrix[i,i];
                
                // Swaps are changing sign
                if(swaps % 2 == 1)
                {
                    ret *= cast(Element)(-1);
                }
                return ret;
            }
        }
        
        /// Thrown by inverse method when determinant equals zero
        static class MatrixNoInverse: Exception
        {
            /// Failed matrix
            ThisMatrix matrix;
            
            @safe pure nothrow this(const ref ThisMatrix matrix
                , string file = __FILE__, size_t line = __LINE__, Throwable next = null)
            {
                this.matrix = matrix;
                super("Matrix has no inverse!", file, line, next);
            }
        
            @safe pure nothrow this(const ref ThisMatrix matrix
                , Throwable next, string file = __FILE__, size_t line = __LINE__)
            {
                this.matrix = matrix;
                super("Matrix has no inverse!", file, line, next);
            }
        }
        
        /**
        *   Returns inverse of the matrix.
        *
        *   Throws: if determinant == 0 then throws MatrixNoInverse
        *   exception.
        */
        ThisMatrix inverse()() const pure @safe
            if(elementHasOp!"/" && elementHasOp!"-")
        {
            if(determinant == 0)
                throw new MatrixNoInverse(this);
                
            static if(elementsCount == 1) return cast(Element)1 / elements[0];
            else
            {
                size_t unused;
                // matrix that attached right
                auto ret = ThisMatrix.identity;
                // Making triangular matrix
                ThisMatrix matrix = triangular(unused, ret);
                
                // Backward pass, getting identity matrix
                foreach_reverse(i; Iota!(1, n))
                {
                    foreach_reverse(j; Iota!i)
                    {
                        ret.subtractRows(j, i, matrix[j,i]);
                        matrix.subtractRows(j, i, matrix[j,i]);
                    }
                }
                 
                return ret;
            }
        }
        
        /// Solves by Gauss-Jordan method system of linear equations
        /**
        *   Throws: NoInverseMatrix if determinant == 0
        */
        Vector!(Element, n) solveLinear(in Vector!(Element, n) freeColumn) pure const @safe
        {
            if(determinant == 0)
                throw new MatrixNoInverse(this);
                
            static if(n == 1) return Vector!(Element, n)(freeColumn[0]/m[0]);
            else
            {
                size_t unused;
                // Vector that is mutated
                Vector!(Element, n) ret = freeColumn;
                // Making triangular matrix
                ThisMatrix matrix = triangular(unused, ret);
                
                // Backward pass, transforming to identity matrix
                foreach_reverse(i; Iota!(1, n))
                {
                    foreach_reverse(j; Iota!i)
                    {
                        ret[j] -= ret[i]*matrix[j,i];
                        matrix.subtractRows(j, i, matrix[j,i]);
                    }
                }
                
                return ret;
            }
        }
        
        /// Calculating rang of the matrix
        size_t rang() pure @safe const 
        {
            auto matrix = triangular;
            
            size_t ret;
            foreach(i; Iota!n)
            {
                if(matrix.row(i) != Vector!(Element, n)(cast(Element)0)) ++ret;
            }
            
            return ret;
        }
        
        /// Applying $(B func) to each element of the matrix
        ref ThisMatrix apply(alias func)()
            if(__traits(compiles, func(Element.init)))
        {
            foreach(i; Iota!n)
            {
                foreach(j; Iota!m)
                {
                    this[i, j] = func(this[i,j]);
                }
            }
            return this;
        }
    }
    
    /**
    *   Matrix supports two formats: normal and pretty.
    *
    *   In normal format (%s) matrix is printed as 2-dimensional
    *   array in one line.
    *
    *   In pretty format (%p) matrix is printed with newlines and
    *   column width alignment.
    *   -------------
    *   writefln("%p", mat33!int([
    *               [-44343, 0, 0],
    *               [0, 565656, 0],
    *               [0, 0, 0],
    *           ]));
    *   // Will output:
    *   mat33!int(
    *   -44343,     0,0,
    *        0,565656,0,
    *        0,     0,0,
    *   )
    *   -------------
    */
    void toString(scope void delegate(const(char)[]) sink
        , FormatSpec!char fmt)
    {
        switch(fmt.spec)
        {
            case 'p': // with newlines and aligned
            {
                // heading
                static if(isSquare!())
                {
                    static if(n <= 9)
                    {
                        sink(text("mat", n, n, "!", Element.stringof~"(\n"));
                    } else {
                        sink(text("SquareMatrix!(", Element.stringof, ", ", n, ")(\n"));
                    }
                } else {
                    sink(text("SquareMatrix!(", Element.stringof, ", ", n, ", ", m, ")(\n"));
                }
                
                // Saving converted values
                char[][n][m] saved;
                FormatSpec!char elemFmt = fmt; 
                elemFmt.spec = 's';
                foreach(i; Iota!n)
                {
                    foreach(j; Iota!m)
                    {
                        auto writer = appender!(char[]);
                        formatValue(writer, this[i,j], elemFmt);
                        saved[i][j] = writer.data; 
                    }
                }
                
                // Finding max width of columns
                size_t[m] columnWidths;
                foreach(j; Iota!m)
                {
                    foreach(i; Iota!n)
                    {
                        if(columnWidths[j] < saved[i][j].length)
                        {
                            columnWidths[j] = saved[i][j].length;
                        }
                    }
                }
                
                // Printing values
                foreach(i; Iota!n)
                {
                    foreach(j; Iota!m)
                    {
                        size_t elemWidth = saved[i][j].length;
                        size_t colWidth = columnWidths[j];
                        if(elemWidth < colWidth)
                        {
                            foreach(k; 0 .. (colWidth - elemWidth))
                                sink(" ");
                        }
                        sink(saved[i][j]);
                        sink(",");
                    }
                    sink("\n");
                }
                
                // ending
                sink(")");
                break;
            }
            default: // %s
            {
                FormatSpec!char elemFmt = fmt; 
                elemFmt.spec = 's';
                
                sink("[");
                foreach(i; Iota!n)
                {
                    sink("[");
                    foreach(j; Iota!m)
                    {
                        formatValue(sink, this[i,j], elemFmt);
                        static if(j != m-1)
                            sink(",");
                    }
                    static if(i == n-1)
                        sink("]");
                    else 
                        sink("],");
                }
                sink("]");
            }
        }
    }
    
    /// Mutates matrix: row k1 - (row k2 * val)
    private ref ThisMatrix subtractRows()(size_t k1, size_t k2, Element val)
    {
        auto temp = row(k2)*val;
        foreach(j; Iota!m)
        {
            this[k1,j] -= temp[j];
        }
        return this;
    } 
}
unittest
{
    auto a = mat33!float.zeros;
    auto b = mat33!float.ones;
    auto c = mat33!float.identity;
    
    assert(a == mat33!int([
                [0, 0, 0],
                [0, 0, 0],
                [0, 0, 0],
            ]));
    assert(b == mat33!int([
                [1, 1, 1],
                [1, 1, 1],
                [1, 1, 1],
            ]));
    assert(c == mat33!int([
                [1, 0, 0],
                [0, 1, 0],
                [0, 0, 1],
            ]));

    // column order
    assert(mat22!int([
                [0, 1],
                [0, 0],
            ]).elements
            == 
            [
                [0, 0],
                [1, 0], 
            ]);
    
    b = b + b;
    assert(b == mat33!int([
                [2, 2, 2],
                [2, 2, 2],
                [2, 2, 2],
            ]));
    
    b = c * b;
    assert(b == mat33!int([
                [2, 2, 2],
                [2, 2, 2],
                [2, 2, 2],
            ]));
    
    auto aa = mat44!int(
            1,   2,  3,  4,
            5,   6,  7,  8,
            9,  10, 11, 12,
            13, 14, 15, 16,
        );
    auto bb = mat44!int(
            16, 15, 14, 13,
            12, 11, 10,  9,
             8,  7,  6,  5,
             4,  3,  2,  1,
        );
    
    auto cc = aa * bb;
    assert(cc == mat44!int(
             80,  70,  60,  50,
            240, 214, 188, 162,
            400, 358, 316, 274,
            560, 502, 444, 386,
        ));
    
    auto cct = cc.transpose;
    assert(cct == mat44!int(
            80, 240, 400, 560,
            70, 214, 358, 502,
            60, 188, 316, 444,
            50, 162, 274, 386 
        ));
}
unittest // determinant
{    
    assert(mat33!float(
            1.0f, 2.0f, 3.0f,
            4.0f, 5.0f, 6.0f,
            7.0f, 8.0f, 9.0f,
        ).determinant == 0, "Determinant failed!");
    assert(mat33!float(
            0.0f, 1.0f, 1.0f,
            1.0f, 0.0f, 0.0f,
            2.0f, 2.0f, 2.0f
        ).determinant == 0, "Determinant failed!");
    assert(mat33!float(
            4.0f, 1.0f, 1.0f,
            1.0f, 0.0f, 0.0f,
            0.0f, 0.0f, 2.0f
        ).determinant == -2, "Determinant failed!");
    assert(mat33!float(
            4.0f, 1.0f, 1.0f,
            1.0f, 0.0f, 5.0f,
            0.0f,25.0f, 2.0f
        ).determinant == -477, "Determinant failed!");
}
unittest // inverse
{
    auto m1 = mat33!float(
        1.0f, 1.0f, 1.0f,
        4.0f, 2.0f, 1.0f,
        9.0f, 3.0f, 1.0f        
        );
    auto m1i = mat33!float(
         0.5f,-1.0f, 0.5f,
        -2.5f, 4.0f,-1.5f,
         3.0f,-3.0f, 1.0f       
        );
    assert(m1.inverse == m1i, "Inverse failed!");

    auto m2 = mat33!float(
        3.0f, 2.0f, 2.0f,
        1.0f, 3.0f, 1.0f,
        5.0f, 3.0f, 4.0f        
        );
    auto m2i = mat33!float(
          1.8f,-0.4f,-0.8f,
          0.2f, 0.4f,-0.2f,
         -2.4f, 0.2f, 1.4f      
        );
    assert(m2.inverse.approxEqual(m2i), "Inverse failed!"); 
}
unittest // gauss-jordan
{
    auto m = mat33!float(
        1.0f, 1.0f, 1.0f,
        4.0f, 2.0f, 1.0f,
        9.0f, 3.0f, 1.0f,
        );
    auto mfree = vec3!float(0,1,3);
    assert(m.solveLinear(mfree) == vec3!float(0.5,-0.5,0), "Linear solve failed!");
}
unittest // apply
{
    auto m1 = mat33!float(
        1.0f, 1.0f, 1.0f,
        4.0f, 2.0f, 1.0f,
        9.0f, 3.0f, 1.0f    
        );
    auto m2 = mat33!float(
        E, E, E,
        exp(4.0f), exp(2.0f), E,
        exp(9.0f), exp(3.0f), E 
        );
    assert(m1.apply!exp.approxEqual(m2));
}
unittest // rang
{
    assert(mat33!float(
            -0.17f, 0.17f, 0.0f,
            0.0f, -0.17f, 0.17f,
            0.08f, 0.0f, -0.08f 
        ).rang == 2);
}

/// Constructing a translation matrix
mat44!T translateMatrix(T)(vec3!T v) pure nothrow @safe
    if(isFloatingPoint!T)
{
    return mat44!T(
        1.0, 0.0, 0.0, v.x,
        0.0, 1.0, 0.0, v.y,
        0.0, 0.0, 1.0, v.z,
        0.0, 0.0, 0.0, 1.0,
    );
}

/// Constructing a scaling matrix
mat44!T scaleMatrix(T)(vec3!T v) pure nothrow @safe
    if(isFloatingPoint!T)
{
    return mat44!T(
        v.x, 0.0, 0.0, 0.0,
        0.0, v.y, 0.0, 0.0,
        0.0, 0.0, v.z, 0.0,
        0.0, 0.0, 0.0, 1.0,
    );
}

/// Constructing a rotation matrix from Euler's angles
mat44!T rotationMatrix(T)(Vector!(T, 3) v) pure nothrow @safe
    if(isFloatingPoint!T)
{
    auto pitch = v.x;
    auto yaw = v.y;
    auto roll = v.z;
    
    return mat44!T(
        cos(yaw)*cos(roll), -cos(pitch)*sin(roll)+sin(pitch)*sin(yaw)*cos(roll),  sin(pitch)*sin(roll)+cos(pitch)*sin(yaw)*cos(roll), 0.0,
        cos(yaw)*sin(roll),  cos(pitch)*cos(roll)+sin(pitch)*sin(yaw)*sin(roll), -sin(pitch)*cos(roll)+cos(pitch)*sin(yaw)*sin(roll), 0.0,
        -sin(yaw),           sin(pitch)*cos(yaw),                                 cos(pitch)*cos(yaw),                                0.0,
        0.0,                0.0,                                                  0.0,                                                1.0,
    );
}

/// Constructing a rotation matrix from Euler's angles
mat33!T rotationMatrix3(T)(Vector!(T, 3) v) pure nothrow @safe
    if(isFloatingPoint!T)
{
    alias pitch = v.x;
    alias yaw = v.y;
    alias roll = v.z;
    
    return mat33!T(
        cos(yaw)*cos(roll), -cos(pitch)*sin(roll)+sin(pitch)*sin(yaw)*cos(roll),  sin(pitch)*sin(roll)+cos(pitch)*sin(yaw)*cos(roll), 
        cos(yaw)*sin(roll),  cos(pitch)*cos(roll)+sin(pitch)*sin(yaw)*sin(roll), -sin(pitch)*cos(roll)+cos(pitch)*sin(yaw)*sin(roll), 
        -sin(yaw),           sin(pitch)*cos(yaw),                                 cos(pitch)*cos(yaw),                               
    );
}
///
unittest
{
    auto a = vec4!float(1,0,0,1);
    a = rotationMatrix(vec3!float(0,PI/2.,0))*a;
    assert(approxEqual(a.x,0) && approxEqual(a.z, -1) && a.y == 0 && a.w == 1, "Vertex rotation failed: "~to!string(a));

    a = rotationMatrix(vec3!float(PI/2, 0, 0))*a;
    assert(approxEqual(a.x,0) && approxEqual(a.y, 1) && approxEqual(a.z, 0) && a.w == 1, "Vertex rotation failed: "~to!string(a));
}

/// Returns projection matrix
/**
*   The matrix transforms camera coordinate system into window system.
*   Param:
*       fovyAngle    Angle of view. Usually value in range of [30 .. 90] degrees.
*       aspect       Ratio of height to width of viewport
*       zNear        Near clipping plane distance, should be as maximum as possible
*       zFar         Far clipping plane distance, should be as minimum as possible
*
*   Note: Used to get MVP matrix (Model-View-Projection).
*/
mat44!T projectionMatrix(T, Angle)(Angle fovyAngle, T aspect, T zNear, T zFar)
    if(isAngle!Angle && isFloatingPoint!T)
{
    immutable fovy  = cast(T)fovyAngle;
    immutable top   = zNear*tan(fovy/2.0f);
    immutable right = top / aspect;
    
    alias r = right;
    alias t = top;
    alias n = zNear;
    alias f = zFar;
    
    return mat44!T(
        n/r,    0.0,    0.0,             0.0,
        0.0,    n/t,    0.0,             0.0,
        0.0,    0.0,    -(f+n)/(f-n),   -2*f*n/(f-n),
        0.0,    0.0,    -1.0,            0.0,
    );
}

/// Returns matrix for rotating vector to look at specific point
/**
*   Kind of View matrix that transforms world coordinates to camera coordinates
*   Params:
*       eye Camera position
*       at  Camera target
*       up  Camera up direction
*
*   Note: Used to get MVP matrix (Model-View-Projection).
*/
mat44!T lookAt(T)(Vector!(T, 3) eye, Vector!(T, 3) at, Vector!(T, 3) up)
{
    immutable zaxis = (at-eye).normalize;
    immutable xaxis = up.cross(zaxis);
    immutable yaxis = zaxis.cross(xaxis);
    
    return mat44!T(
       xaxis.x, xaxis.y, xaxis.z, -xaxis.dot(eye),
       yaxis.x, yaxis.y, yaxis.z, -yaxis.dot(eye),
       zaxis.x, zaxis.y, zaxis.z, -zaxis.dot(eye),
       0.0,     0.0,    0.0,       1.0, 
    );
} 

/// TransformedVector = ScaleMatrix * RotationMatrix * TranslationMatrix * OriginalVector;