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

import com.jme3.app.SimpleApplication;
import com.jme3.renderer.RenderManager;
import drossy.stars.api.IDrossyStarsCore;
import drossy.stars.api.Side;

/**
 * Client realization of IDrossyStarsCore and client application base class.
 * @author ncrashed
 */
public class ClientApplication extends SimpleApplication 
    implements IDrossyStarsCore
{
    /**
     * Get loaded side.
     * @return Side.SERVER if server side and Side.CLIENT if client side.
     */
    @Override
    public Side getSide()
    {
        return Side.CLIENT;
    }
    
    @Override
    public void simpleInitApp() 
    {
    }

    @Override
    public void simpleUpdate(float tpf) 
    {
    }

    @Override
    public void simpleRender(RenderManager rm) 
    {
    }
}
