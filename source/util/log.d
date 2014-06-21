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
*   Logger is dependency that is used actually at any game subsystem. To not forward
*   logger within all dependency graph this module provides mixin template that helps
*   to eliminate boilerplate while logging.
*
*   Example with local logger:
*   --------
*   class MyClass
*   {
*       // Logger shared via instances of the class
*       // with name MyClass.log
*       mixin Logging!(LoggerType.Local);
*
*       void method()
*       {
*           logInfo("Info message");
*           logError("Error message");
*           logWarning("Warning message");
*           logDebug("Debug message");
*       }
*   }
*   --------
*
*   Example with global logger:
*   --------
*   class MyClass
*   {
*       mixin Logging;
*
*       void method()
*       {
*           logInfo("Info message");
*           logError("Error message");
*           logWarning("Warning message");
*           logDebug("Debug message");
*       }
*   }
*   
*   // Important to init global logger before using
*   void main()
*   {
*       initGlobalLogger("logfile.log");
*   }
*   --------
*
*   Also the template adds $(B logger) method to access
*   currently used logger. 
*/
module util.log;

import dlogg.strict;

/// The enum is used to choose logger type in $(B Logging) mixin template
enum LoggerType
{
    Global,
    Local
}

public shared(ILogger) globalLogger; 

/**
*   If you are using global logging, very important to call this once
*   before any use of the logger!
*/
void initGlobalLogger(string logname)()
{
     globalLogger = new shared StrictLogger(logname);
}

shared static ~this()
{
    if(globalLogger) globalLogger.finalize;
}

/**
*   LoggedError is wrapper that is thrown by $(B raiseLogged).
*/
class LoggedError : Error
{
    @safe pure nothrow this(string msg, Throwable next = null)
    {
        super(msg, next);
    }

    @safe pure nothrow this(string msg, string file, size_t line, Throwable next = null)
    {
        super(msg, file, line, next);
    }
}

/**
*   Mixin this to inject logging support to your class/struct.
*
*   $(B type) parameter chooses between global logger for whole
*   application and local logger shared between class instances.
*
*   Note: the $(B initGlobalLogger) should be called at startup to
*   use global logger.
*/
mixin template Logging(LoggerType type = LoggerType.Global)
{
    import dlogg.strict;
    
    static if(type == LoggerType.Local)
    {
        private enum logName = typeof(this).stringof ~ ".log";
        private static shared(ILogger) _logger;
        
        static shared this()
        {
             _logger = new shared StrictLogger(logName);
        }
        
        static shared ~this()
        {
            _logger.finalize();
        }
        
        private shared(ILogger) logger()
        {
            return _logger;
        }
        
        private void logInfo(T...)(T msgs)
        {
            _logger.log(text(msgs), LoggingLevel.Notice);
        }
        
        private void logDebug(T...)(T msgs)
        {
            _logger.log(text(msgs), LoggingLevel.Debug);
        }
        
        private void logError(T...)(T msgs)
        {
            _logger.log(text(msgs), LoggingLevel.Fatal);
        }
        
        private void logWarning(T...)(T msgs)
        {
            _logger.log(text(msgs), LoggingLevel.Warning);
        }
        
        private LoggedError raiseLogged(T...)(T msgs)
        {
            string msg = text(msgs);
            _logger.log(msg, LoggingLevel.Fatal);
            return new LoggedError(msg);
        }
    }
    else
    {
        private shared(ILogger) logger()
        {
            return globalLogger;
        }
        
        private void logInfo(T...)(T msgs)
        {
            globalLogger.log(text(msgs), LoggingLevel.Notice);
        }
        
        private void logDebug(T...)(T msgs)
        {
            globalLogger.log(text(msgs), LoggingLevel.Debug);
        }
        
        private void logError(T...)(T msgs)
        {
            globalLogger.log(text(msgs), LoggingLevel.Fatal);
        }
        
        private void logWarning(T...)(T msgs)
        {
            globalLogger.log(text(msgs), LoggingLevel.Warning);
        }
        
        private LoggedError raiseLogged(T...)(T msgs)
        {
            string msg = text(msgs);
            globalLogger.log(msg, LoggingLevel.Fatal);
            return new LoggedError(msg);
        }
    }
} 