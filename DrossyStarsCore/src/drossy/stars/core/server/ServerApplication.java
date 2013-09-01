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

import com.jme3.app.Application;
import com.jme3.scene.Node;
import com.jme3.system.AppSettings;
import com.jme3.system.JmeContext;
import drossy.stars.api.IDrossyStarsCore;
import drossy.stars.api.Side;

/**
 * Server realization of IDrossyStarsCore and server application base class.
 * @author ncrashed
 */
public class ServerApplication extends Application implements IDrossyStarsCore
{                                                                   
    protected Node rootNode = new Node("Root Node");

    /**
     * Get loaded side.
     * @return Side.SERVER if server side and Side.CLIENT if client side.
     */
    @Override
    public Side getSide()
    {
        return Side.SERVER;
    }
    
    public ServerApplication() 
    {
       
    }

    @Override
    public void start() 
    {
        // set some default settings in-case
        // settings dialog is not shown
        boolean loadSettings = false;
        if (settings == null) {
            setSettings(new AppSettings(true));
            loadSettings = true;
        }

        //re-setting settings they can have been merged from the registry.
        setSettings(settings);
        super.start(JmeContext.Type.Headless);
    }

    /**
     * Retrieves rootNode
     * @return rootNode Node object
     *
     */
    public Node getRootNode() {
        return rootNode;
    }

    @Override
    public void initialize() 
    {
        super.initialize();

    }

    @Override
    public void update() 
    {
        super.update(); // makes sure to execute AppTasks
        
        if (speed == 0 || paused) 
        {
            return;
        }

        float tpf = timer.getTimePerFrame() * speed;

        // update states
        stateManager.update(tpf);

 
        rootNode.updateLogicalState(tpf);
    }
}
