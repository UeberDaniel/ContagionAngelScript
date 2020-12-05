# Contagion AngelScript Plugins

# PLUGIN INSTALLATION

## Install the plugin

Put the file YourCoolPlugin.as in the ```\contagion\data\scripts\plugins``` folder in your contagion directory.

---

## Enable the plugin

There are two ways to enable an AngelScript plugin:

1. Use the \contagion\default_plugins.json, all servers you create on this root will boot up with this plugins activated:
```js
  {
    "plugins": [
       {
       "script": "YourCoolPlugin.as"
        }
      ]
  }
```
2. Use the \contagion\cfg\server.cfg or, for a specific gamemode, \contagion\cfg\gamemodes\GamemodeName.cfg and add a new line with
    * ```as_loadplugin "YourCoolPlugin.as"``` for activation and
    * ```as_unloadplugin "YourCoolPlugin.as"``` for deactivation.


>I prefer point 2, because you could play around like you want with the gamemodes and plugins, use one plugin for this gamemode, another for the next gamemode and also unload the current plugin which is not needed now, like the way you want.

---

## Configfiles

Many plugins are configurable, some only at start, others also at runtime.

At the first server start after the plugin installation, the plugin can create a configuration file, if this is provided by the plugin creator.

This configfile will be located under ```\contagion\data\custom\```

You can edit this file with a texteditor, restart the server and the new settings will be used.

---

## Configuration at runtime

All Contagion AngelScript ConVars, created by plugins, should begin with "as_" and end with some useful ConVar name like "as_ycp_coolness_factor".
If the plugin uses such ConVars (console commands), you should be able to change them at server runtime.

With the command "as_showcommands" in the console, you will get a list of all available ASConVars form all plugins.
  
>On my plugins it will follow the structure "as_ + abbreviation of the pluginname + _ + setting name".

Usage for the dedicated server console:

```ascmd "as_ycp_coolness_factor"	"3"```

Usage for the listen server or client console:

```"as_ycp_coolness_factor"	"3"```

**Note: There is no need for a plugin creator to give you a config file, use ConVars or let the plugin react on a change of a ConVar at server runtime.
This is not a standard and is up to the plugin creator whether he offers this or not.**

If you want to go deeper: http://contagion-game.com/api/.
