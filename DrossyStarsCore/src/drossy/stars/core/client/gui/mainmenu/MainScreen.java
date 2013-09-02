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

import de.lessvoid.nifty.Nifty;
import de.lessvoid.nifty.builder.LayerBuilder;
import de.lessvoid.nifty.builder.PanelBuilder;
import de.lessvoid.nifty.builder.ScreenBuilder;
import de.lessvoid.nifty.controls.button.builder.ButtonBuilder;
import de.lessvoid.nifty.screen.Screen;
import de.lessvoid.nifty.screen.ScreenController;
import drossy.stars.api.gui.IButton;
import drossy.stars.api.gui.mainmenu.IConnectScreen;
import drossy.stars.api.gui.mainmenu.IMainMenu;
import drossy.stars.core.client.ClientApplication;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author ncrashed
 */
public class MainScreen implements IMainMenu, ScreenController
{
    private ClientApplication app;
    private Nifty nifty;
    private Screen screen;
    private List<IButton> buttons = new ArrayList<IButton>();
    private ConnectScreen connectScreen;
    
    public MainScreen(Nifty nifty, ClientApplication app)
    {
        this.app = app;
        this.nifty = nifty;
        connectScreen = new ConnectScreen(nifty);
        
        rebuild();
    }
    
    public String getName() 
    {
        return "MainScreen";
    }

    public void show() 
    {
        if(!app.getCurrentState().getName().equals(MainMenuState.NAME))
        {
            app.transferToGameState(MainMenuState.NAME);
        }
        
        nifty.gotoScreen(getName());
    }

    public final void rebuild() 
    {
        screen = buildScreen();
        nifty.removeScreen(getName());
        nifty.addScreen(getName(), screen);
    }
    
    public void addButton(IButton button) 
    {
        buttons.add(button);
        rebuild();
    }
    
    public void bind(Nifty nifty, Screen screen) 
    {
        
    }

    public void onStartScreen() 
    {

    }

    public void onEndScreen() 
    {

    }
    
    private Screen buildScreen()
    {
        final ScreenController controller = this;
        
        return new ScreenBuilder(getName()) {{
            controller(controller);
            layer(new LayerBuilder("mainLayer") {{
                childLayout(ChildLayoutType.Center);
                panel(new PanelBuilder("buttonPanel") {{
                    childLayout(ChildLayoutType.Vertical);
                    width("30%");
                    int panelHeight = Math.min(buttons.size()*8, 80);
                    height(Integer.toString(panelHeight)+"%");
                    style("nifty-panel-simple");
                    
                    final float btnHeight = 100/(float)buttons.size();
                    for (final IButton btn : buttons)
                    {
                        control(new ButtonBuilder(btn.getName(), btn.getCaption()) {{
                            width("96%");
                            marginTop("2%");
                            marginLeft("2%");
                            marginRight("2%");
                            height(Float.toString(btnHeight)+"%");
                            interactOnClick("pressButton("+btn.getName()+")");
                        }});
                    }
                }});
            }});
        }}.build(nifty);
    }

    public IButton getButton(String name) 
    {
        for(IButton btn: buttons)
        {
            if(btn.getName().equals(name))
            {
                return btn;
            }
        }
        
        return null;
    }
    
    public void pressButton(String name)
    {
        IButton btn = getButton(name);
        if(btn != null) {
            btn.apply();
        }
    }

    public IConnectScreen getConnectScreen() 
    {
        return connectScreen;
    }
}
