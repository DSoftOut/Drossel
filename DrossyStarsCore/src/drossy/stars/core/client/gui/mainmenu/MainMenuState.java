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
package drossy.stars.core.client.gui.mainmenu;

import com.jme3.app.Application;
import com.jme3.app.state.AbstractAppState;
import com.jme3.app.state.AppStateManager;
import com.jme3.asset.AssetManager;
import com.jme3.input.InputManager;
import com.jme3.niftygui.NiftyJmeDisplay;
import de.lessvoid.nifty.Nifty;
import drossy.stars.api.IGameState;
import drossy.stars.api.gui.IButton;
import drossy.stars.api.gui.mainmenu.IMainMenu;
import drossy.stars.core.client.ClientApplication;

/**
 * State wich represents main menu. Main menu is first that user see after
 * starting the game.
 * @author ncrashed
 */
public class MainMenuState extends AbstractAppState implements IGameState
{
    private ClientApplication   app;
    private AssetManager        assetManager;
    private InputManager        inputManager;
    private Nifty               nifty;
    private NiftyJmeDisplay     niftyDisplay;
    private IMainMenu           mainMenu;
    
    public MainMenuState(ClientApplication app)
    {
        super();
        this.app = app;
    }
    
    @Override
    public void initialize(AppStateManager stateManager, Application app)
    {
        super.initialize(stateManager, app);
        
        assetManager = app.getAssetManager();
        inputManager = app.getInputManager();
        
        initNifty();
    }
    
    @Override
    public void cleanup()
    {
        super.cleanup();
        
        deinitNifty();
    }
    
    @Override
    public void update(float tpf)
    {
        
    }

    private void initNifty()
    {
        niftyDisplay = new NiftyJmeDisplay(assetManager,
                inputManager, app.getAudioRenderer(), app.getGuiViewPort());
       
        nifty = niftyDisplay.getNifty();
        nifty.loadStyleFile("nifty-default-styles.xml");
        nifty.loadControlFile("nifty-default-controls.xml");
 
        app.getGuiViewPort().addProcessor(niftyDisplay);
        app.getFlyByCamera().setEnabled(false);
        app.getFlyByCamera().setDragToRotate(true);
        inputManager.setCursorVisible(true);
        
        mainMenu = new MainScreen(nifty);
        
        mainMenu.addButton(new IButton(){

            public String getCaption() 
            {
                return "Quit";
            }

            public void apply() 
            {
                quit();
            }

            public String getName() 
            {
                return "quitButton";
            }    
        });
        
        mainMenu.show();
    }
    
    private void deinitNifty()
    {
        app.getGuiViewPort().removeProcessor(niftyDisplay);
        app.getFlyByCamera().setEnabled(true);
        app.getFlyByCamera().setDragToRotate(false);
        inputManager.setCursorVisible(false);
        niftyDisplay.cleanup();
    }

    public void quit()
    {
        app.stop(false);
    }

    public String getName() 
    {
        return "mainMenu";
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
