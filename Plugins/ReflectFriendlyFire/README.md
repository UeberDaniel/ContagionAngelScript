# Contagion AngelScript Plugin: ReflectFriendlyFire
###### This plugin does NOT set the game into custom mode, therefore it does NOT trigger the associated achievements lock.

## DESCRIPTION:

This plugin will allow you to set the firendly fire damage in % for the victim and also reflect some percent of the
damage to the attacker.

---
## CONFIGURATION:

* CVars:
  * ```as_rff_victim_killable         : Can attacker kill victim? 1 = Yes; 0 = HP of victim will be capped on 1 HP.```
  * ```as_rff_attacker_msg_enabled    : Display message to attcker? 1 = Yes; 0 = No```
  * ```as_rff_dmgfactor_attacker      : How much dmg (%) the attacker gets reflected. 0.0 = 0 %; 1.0 = 100 %```
  * ```as_rff_dmgfactor_victim        : How much dmg (%) the victim receives. 0.0 = 0 %; 1.0 = 100 %```

* Messages:
  * ```as_rff_attacker_msg            : Message which is displayed to the attacker on firendly fire.```
    - You can edit this message in the Config file, for the victim name and the damage done you can use the
    placeholders {strVictim} and {strDamage}. For colored text parts use the placeholders listed here:
    http://contagion-game.com/api/#cat=Utilities&page=Chat&function=PrintToChat

---
## ADDITIONAL INFORMATION:
- This plugin is paused in hunted game mode, no damage is reflected/calculated here!

---
## CHANGELOG:
[ + Added Feature | - Removed Feature | * Changed or Fixed Feature ]

* 05.12.2020: Version 1.0
  + Initial Release
