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

import com.beust.jcommander.JCommander;
import com.beust.jcommander.Parameter;
import drossy.stars.api.Side;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ncrashed
 */
public class StartOptions 
{
    /**
     *  List of parsed paramters.
     */
    @Parameter
    public List<String> parameters = new ArrayList<String>();

    /**
     *  Core can be started with graphics and without it. If paramater
     *  not found or invalid, client side will be charged.
     */
    @Parameter(names = "-side", converter = Side.class, description = 
            "'server' value will start game as dedicated server and 'client' "+
            "value will start game as client with built in server")
    public Side side = Side.UNKNOWN;
    
    /**
     *  Saved commander object.
     */
    protected JCommander commander;
    
    /**
     * Parse arguments list.
     * @param args
     */
    public StartOptions(String[] args)
    {
        commander = new JCommander(this, args);
        
        if(side.isUnknown())
        {
            side = Side.CLIENT;
        }
    }
}
