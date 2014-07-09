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

import std.array;
import std.conv;
import std.format;
import util.functional;

alias SquareMatrix(Element, size_t n) = Matrix!(Element, n, n);

alias mat11(Element) = SquareMatrix!(Element, 1);
alias mat22(Element) = SquareMatrix!(Element, 2);
alias mat33(Element) = SquareMatrix!(Element, 3);
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
    
    /// Elements as 2-dimensional array, columns order
    Element[m][n] elements;
    
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
    
    /// Comparing matrices with equal sizes
    bool opEquals(OtherElement)(auto ref const Matrix!(OtherElement, n, m) mat) const 
        if(__traits(compiles, Element.init == OtherElement.init))
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
    
    static class MatrixNoInverse: Exception
    {
        /// Failed matrix
        ThisMatrix matrix;
        
        @safe pure nothrow this(ref ThisMatrix matrix
            , string file = __FILE__, size_t line = __LINE__, Throwable next = null)
        {
            this.matrix = matrix;
            super("Matrix has no inverse!", file, line, next);
        }
    
        @safe pure nothrow this(ref ThisMatrix matrix
            , Throwable next, string file = __FILE__, size_t line = __LINE__)
        {
            this.matrix = matrix;
            super("Matrix has no inverse!", file, line, next);
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
}