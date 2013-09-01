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
package drossy.stars.core.server;

import com.jme3.app.state.AbstractAppState;
import drossy.stars.api.IGameState;

/**
 * Main server state. Server is permamently running this state.
 * @author ncrashed
 */
public class ServerMainState extends AbstractAppState implements IGameState
{
    private ServerApplication app;
    
    public ServerMainState(ServerApplication app)
    {
        this.app = app;
    }
    
    public String getName() 
    {
        return "mainState";
    }

    public void load() 
    {
        app.getStateManager().attach(this);
    }

    public void unload() 
    {
        app.getStateManager().detach(this);
    }
}
