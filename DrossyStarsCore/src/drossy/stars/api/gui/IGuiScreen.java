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
package drossy.stars.api.gui;

/**
 * Parent interface for all gui screens.
 * @author ncrashed
 */
public interface IGuiScreen 
{
    /**
     * Name of gui screen.
     * @return 
     */
    String getName();
    
    /**
     * Shows screen. If any another screen is active now, hides it.
     */
    void show();
    
    /**
     * Rebuild screen content. If screen content changes dynamically
     * this method will refresh the screen.
     */
    void rebuild();
}
