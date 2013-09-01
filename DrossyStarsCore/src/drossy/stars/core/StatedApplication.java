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

import com.jme3.app.Application;
import drossy.stars.api.GameStateConflictException;
import drossy.stars.api.IDrossyStarsCore;
import drossy.stars.api.IGameState;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Application with implemented game stating api.
 * @author ncrashed
 */
public abstract class StatedApplication extends Application 
    implements IDrossyStarsCore
{
    private Map<String, IGameState> gameStates = 
            new ConcurrentHashMap<String, IGameState>();
    private IGameState currentState = null;
    
    public IGameState getCurrentState() 
    {
        return currentState;
    }

    public Set<String> getAvailableGameStates() 
    {
        return gameStates.keySet();
    }

    public void transferToGameState(String stateName) 
    {
        if(gameStates.containsKey(stateName))
        {
            if(currentState != null) {
                currentState.unload();
            }
            
            currentState = gameStates.get(stateName);
            currentState.load();
        }
    }

    public void registerGameState(IGameState state) 
            throws GameStateConflictException
    {
        if(gameStates.containsKey(state.getName()))
        {
            throw new GameStateConflictException(state.getName());
        }
        
        gameStates.put(state.getName(), state);
    }
}
