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
package drossy.stars.api;

import com.beust.jcommander.IStringConverter;

/**
 * Represents current loaded side, client or server.
 * @author ncrashed
 */
public enum Side implements IStringConverter<Side>
{
    /**
     * Side with no render capabilities. Usually only server is able to change
     * gamestate and only server has full information about game state.
     */
    SERVER,
    /**
     * Side with render capabilites. Usually main client purpose is sending
     * user input to server and render incoming game state. But also client
     * can make some prediction of next game state to smooth latency.
     */
    CLIENT,
    /**
     * Invalid state. Can occure while converting from string or other deep
     * bags exits.
     */
    UNKNOWN;

    @Override
    public Side convert(String string) 
    {
        string = string.toLowerCase();
        if(string.equals("server"))
        {
            return Side.SERVER;
        } else if(string.equals("client"))
        {
            return Side.CLIENT;
        } else
        {
            return Side.UNKNOWN;
        }
    }
    
    /**
     * Wrapper to simplify detecting client side.
     * @return true if it is client side
     */
    public boolean isClient()
    {
        return this == Side.CLIENT;
    }
    
    /**
     * Wrapper to simplify detecting server side.
     * @return true if it is server side
     */
    public boolean isServer()
    {
        return this == Side.SERVER;
    }
    
    /**
     * Wrapper to simplify detecting invalid side.
     * @return true if it is invalid state.
     */
    public boolean isUnknown()
    {
        return this == Side.UNKNOWN;
    }
}
