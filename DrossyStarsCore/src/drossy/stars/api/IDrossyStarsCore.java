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

import drossy.stars.api.gui.mainmenu.IMainMenu;
import java.util.Set;

/**
 * The main interface of whole Drossy Stars engine. It handles all subsystems
 * and controls mod loading.
 * @author ncrashed
 */
public interface IDrossyStarsCore 
{
    /**
     * Get loaded side.
     * @return Side.SERVER if server side and Side.CLIENT if client side.
     */
    Side getSide();
    
    /**
     * Returns current state game is running in.
     * @return 
     */
    IGameState getCurrentState();
    
    /**
     * Return list of available states to transfer game.
     * @return 
     */
    Set<String> getAvailableGameStates();
    
    /**
     * Tries to transfer game to specified game state.
     * Game state should be registered otherwise do nothing.
     * @param stateName 
     */
    void transferToGameState(String stateName);
    
    /**
     * Registers game state. After calling this function
     * you can transfer game to this state.
     * @param state 
     */
    void registerGameState(IGameState state) throws GameStateConflictException;
    
    /**
     * Returns main menu state. Only client has main menu, server should
     * return null for this method.
     * Note: showing main menu screen will change current game state to main menu
     * state.
     * @return Main menu state or null if no main menu in application. 
     */
    IMainMenuState getMainMenuState();
}
