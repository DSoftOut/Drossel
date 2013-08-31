// Copyright (с) 2013 Gushcha Anton <ncrashed@gmail.com>
/*
 * This file is part of Foguan Engine.
 * 
 * Foguan Engine is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Foguan Engine is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Foguan Engine.  If not, see <http://www.gnu.org/licenses/>.
 */
package drossy.stars.core;

/**
 * Entry point of foguan application. The only thing it should do is
 * loading engine core.
 * @author ncrashed
 */
public class Main 
{
    private static StartOptions options;

    public static void main(String[] args) 
    {
        options = new StartOptions(args);
        
        if(options.side.isServer())
        {
            new ServerApplication().start();
        } else
        {
            new ClientApplication().start();
        }
    }
}
