const string strInfoName = "ReflectFriendlyFire";
const string strInfoAuthor = "UeberDaniel";
const string strInfoVersion = "1.1";
const string strFileName = strInfoName;
const string strConVarName = "as_rff_";
const array<string> strScriptDescription = {
    "---------------------------------> DO NOT DELETE THIS! YOU MAY NEED IT IN THE FUTURE! <---------------------------------",
    "| This plugin does NOT set the game into custom mode, therefore it does NOT trigger the associated achievements lock.  |",
    "|======================================================================================================================|",
    "|                                                                                                                      |",
    "| Contagion AngelScript Plugin: ReflectFriendlyFire                                                                    |",
    "|                                                                                                                      |",
    "| DESCRIPTION:                                                                                                         |",
    "|                                                                                                                      |",
    "| This plugin will allow you to set the firendly fire damage in % for the victim and also reflect some percent of the  |",
    "| damage to the attacker.                                                                                              |",
    "|======================================================================================================================|",
    "|                                                                                                                      |",
    "| CONFIGURATION:                                                                                                       |",
    "|  CVars:                                                                                                              |",
    "|   as_rff_victim_killable         : Can attacker kill victim? 1 = Yes; 0 = HP of victim will be capped on 1 HP.       |",
    "|   as_rff_attacker_msg_enabled    : Display message to attcker? 1 = Yes; 0 = No                                       |",
    "|   as_rff_dmgfactor_attacker      : How much dmg (%) the attacker gets reflected. 0.0 = 0 %; 1.0 = 100 %              |",
    "|   as_rff_dmgfactor_victim        : How much dmg (%) the victim receives. 0.0 = 0 %; 1.0 = 100 %                      |",
    "|                                                                                                                      |",
    "|  Messages:                                                                                                           |",
    "|   as_rff_attacker_msg            : Message which is displayed to the attacker on friendly fire.                      |",
    "|   -You can edit this message in the Config file, for the victim name and the damage done you can use the             |",
    "|    placeholders {strVictim} and {strDamage}. For colored text parts use the placeholders listed here:                |",
    "|    http://contagion-game.com/api/#cat=Utilities&page=Chat&function=PrintToChat                                       |",
    "|                                                                                                                      |",
    "| ADDITIONAL INFORMATION:                                                                                              |",
    "|  -This plugin is paused in hunted game mode, no damage is reflected/calculated here!                                 |",
    "|======================================================================================================================|",
    "|                                                                                                                      |",
    "| CHANGELOG: [ + Added Feature | - Removed Feature | * Changed or Fixed Feature ]                                      |",
    "|                                                                                                                      |",
    "| 05.12.2020: Version 1.0                                                                                              |",
    "| + Initial Release                                                                                                    |",
    "|                                                                                                                      |",
    "| 06.12.2020: Version 1.1                                                                                              |",
    "| - Removed version number in configfile name                                                                          |",
    "|======================================================================================================================|",
    "| Visit https://ohne-reue.de/Scripting/Contagion-AngelScript/Plugins for more Information.                             |",
    "| Created 2020 by https://steamcommunity.com/id/UeberDaniel for https://ohne-reue.de Contagion servers.                |",
    "------------------------------------------------------------------------------------------------------------------------"
};
// Placeholder Strings
const string strPlaceholderVictim = "{strVictim}", strPlaceholderDamage = "{strDamage}";

// Global Variables
string strAttackerMsg = "You hit your teammate {green}" + strPlaceholderVictim + "{default}! Reflected damage: {red}" + strPlaceholderDamage + "{default} HP.";

// CASConVars
CASConVar@ pCanVictimGetKilled = null;
CASConVar@ pAttackerMsgEnabled = null;
CASConVar@ pDmgFactorAttacker = null;
CASConVar@ pDmgFactorVictim = null;


void OnPluginInit()
{
	PluginData::SetName(strInfoName);
	PluginData::SetAuthor(strInfoAuthor);
	PluginData::SetVersion(strInfoVersion);

    Events::Player::OnPlayerDamaged.Hook( @OnPlayerDamaged );

    @pCanVictimGetKilled = ConVar::Create((strConVarName + "victim_killable"), "0", "Can attacker kill victim? 1 = Yes; 0 = HP of victim will be capped on 1 HP.", LEVEL_ADMIN, true, 0, true, 1);
    @pAttackerMsgEnabled = ConVar::Create((strConVarName + "attacker_msg_enabled"), "1", "Display message to attcker? 1 = Yes; 0 = No", LEVEL_ADMIN, true, 0, true, 1);
    @pDmgFactorAttacker = ConVar::Create((strConVarName + "dmgfactor_attacker"), "0.5", "How much dmg (%) the attacker gets reflected. 0.0 = 0 %; 1.0 = 100 %", LEVEL_ADMIN, true, 0, true, 10);
    @pDmgFactorVictim = ConVar::Create((strConVarName + "dmgfactor_victim"), "0.35", "How much dmg (%) the victim receives. 0.0 = 0 %; 1.0 = 100 %", LEVEL_ADMIN, true, 0, true, 10);

    InitFilesystem();                       // Create/Read Configfile
}

HookReturnCode OnPlayerDamaged(CTerrorPlayer@ pPlayer, CTakeDamageInfo &in DamageInfo)
{
    if(ThePresident.GetGameModeType() != CT_HUNTED) // Dont use this on Hunted maps, all Humans are in the same Team!
    {
        CBaseEntity@ pVictim = @pPlayer.opCast().opCast();  // Get Victim Entity
        CBaseEntity@ pAttacker = DamageInfo.GetAttacker();  // Get Attacker Entity
        if(pAttacker.IsPlayer() && (pVictim.GetTeamNumber() == pAttacker.GetTeamNumber()) && (pVictim !is pAttacker))   //Is Attacker: a Player + in the same team with Victim + not the Victim?
        {
            float flDamageDone = DamageInfo.GetDamage();    // Get damage

            //Victim
            float flDamageFactorResultVictim = 0;                                                               // Value to store our new Damage, if Factor = 0, damage will be 0 HP
            if(pDmgFactorVictim.GetFloat() > 0) flDamageFactorResultVictim = flDamageDone * pDmgFactorVictim.GetFloat();    // Calculate new Victimdamage
            float fVictimHealth = flDamageDone + pVictim.GetHealth();                                           // Calculate Originally Player Health
            int iNewVictimHealth = Utils.FloatToInt(fVictimHealth - flDamageFactorResultVictim);                // Calculate New Player Health
            if((iNewVictimHealth < 1) && (!pCanVictimGetKilled.GetBool())) pVictim.SetHealth(1);                // If: pCanVictimGetKilled is not enabled and iNewVictimHealth < 1, set Victimhealth to 1 HP.
            else pVictim.SetHealth(iNewVictimHealth);                                                           // Else: Set new Victimhealth (should be between 1 and 100)

            // Attacker
            float flDamageFactorResultAttacker = 0;                                                             // Value to store our new Damage, if Factor = 0, damage will be 0 HP
            if(pDmgFactorAttacker.GetFloat() > 0) flDamageFactorResultAttacker = flDamageDone * pDmgFactorAttacker.GetFloat();  // Calculate new Attackerdamage
            int iNewAttackerHealth = Utils.FloatToInt(pAttacker.GetHealth() - flDamageFactorResultAttacker);    // Calculate New Player Health
            if(iNewAttackerHealth < 1) pAttacker.TakeDamage(DamageInfo);                                        // Would Attacker die? -> Give Attacker his own damage back -> Kill him
            else  pAttacker.SetHealth(iNewAttackerHealth);                                                      // Else: Set new Attackerhealth
            
            // Attacker Message:
            if(pAttackerMsgEnabled.GetBool()){
                string strVictim = pPlayer.GetPlayerName();                                                     // Get our VictimName
                string strDamage = Utils.FloatToInt(flDamageFactorResultAttacker);                              // Format our new calculated attacker DMG
                string strFormatedAttackerMsg = Utils.StrReplace(Utils.StrReplace(strAttackerMsg, strPlaceholderVictim, strVictim), strPlaceholderDamage, strDamage); // Replace placeholder
                Chat.PrintToChat(pAttacker, "{default}[{azure}RFF{default}] " + strFormatedAttackerMsg);       // Print Attackers Message
            }
        }
    }
	return HOOK_CONTINUE;
}

// Set Up Filesystem
void InitFilesystem(){
    JsonValues@ pFileData = FileSystem::ReadFile(strFileName);
    if(@pFileData is null){         // Create Configfile with Default Values
        Log.PrintToServerConsole(LOGTYPE_INFO, "[" + strInfoName + "] Configfile not existing or broken, creating a new one.");
        CreateFile();
        Log.PrintToServerConsole(LOGTYPE_INFO, "[" + strInfoName + "] Configfile was created.");
    }
    else                            // Configfile already existing
    {
        bool bFileBroken = false;
        switch(FileSystem::Exists(pFileData, "ReflectFriendlyFireCvars", strConVarName + "victim_killable")){
            case 0:{ pCanVictimGetKilled.SetValue(FileSystem::GrabString(pFileData, "ReflectFriendlyFireCvars", strConVarName + "victim_killable"));    break; }
            case 2:{ bFileBroken = true;                                                                                                                break; }
            default:{                                                                                                                                   break; }
        }
        switch(FileSystem::Exists(pFileData, "ReflectFriendlyFireCvars", strConVarName + "attacker_msg_enabled")){
            case 0:{ pAttackerMsgEnabled.SetValue(FileSystem::GrabString(pFileData, "ReflectFriendlyFireCvars", strConVarName + "attacker_msg_enabled"));   break; }
            case 2:{ bFileBroken = true;                                                                                                                    break; }
            default:{                                                                                                                                       break; }
        }
        switch(FileSystem::Exists(pFileData, "ReflectFriendlyFireCvars", strConVarName + "dmgfactor_attacker")){
            case 0:{ pDmgFactorAttacker.SetValue(FileSystem::GrabString(pFileData, "ReflectFriendlyFireCvars", strConVarName + "dmgfactor_attacker"));  break; }
            case 2:{ bFileBroken = true;                                                                                                                break; }
            default:{                                                                                                                                   break; }
        }
        switch(FileSystem::Exists(pFileData, "ReflectFriendlyFireCvars", strConVarName + "dmgfactor_victim")){
            case 0:{ pDmgFactorVictim.SetValue(FileSystem::GrabString(pFileData, "ReflectFriendlyFireCvars", strConVarName + "dmgfactor_victim"));  break; }
            case 2:{ bFileBroken = true;                                                                                                            break; }
            default:{                                                                                                                               break; }
        }

        switch(FileSystem::Exists(pFileData, "ReflectFriendlyFireMessage", strConVarName + "attacker_msg")){
            case 0:{ strAttackerMsg = FileSystem::GrabString(pFileData, "ReflectFriendlyFireMessage", strConVarName + "attacker_msg");                                          break; }
            case 2:{ bFileBroken = true;                                                                                                                                        break; }
            default:{                                                                                                                                                           break; }
        }

        if(bFileBroken){
                Log.PrintToServerConsole(LOGTYPE_ERROR, "[" + strInfoName + "] Read Configfile: File broken, creating new one");
                BackupFile(pFileData);
                CreateFile();
                Log.PrintToServerConsole(LOGTYPE_INFO, "[" + strInfoName + "] Configfile recreated with default values, old one is renamed as '" + strFileName + "_bak.json'.");
        }
        else{
            Log.PrintToServerConsole(LOGTYPE_INFO, "[" + strInfoName + "] Read Configfile: OK");
        }
    }
}

// Create Config File with Default Values
void CreateFile(){
    JsonValues@ pJson = FileSystem::CreateJson();

    for(uint i = 0; i < strScriptDescription.length(); i++){    //Write Script Description
        FileSystem::Write( pJson, "Description", (i > 9 ? ("" + i) : ("0" + i)), strScriptDescription[i]);
    }

    FileSystem::Write( pJson, "ReflectFriendlyFireCvars", strConVarName + "victim_killable", pCanVictimGetKilled.GetDefaultValue());
    FileSystem::Write( pJson, "ReflectFriendlyFireCvars", strConVarName + "attacker_msg_enabled", pAttackerMsgEnabled.GetDefaultValue());
    FileSystem::Write( pJson, "ReflectFriendlyFireCvars", strConVarName + "dmgfactor_attacker", pDmgFactorAttacker.GetDefaultValue());
    FileSystem::Write( pJson, "ReflectFriendlyFireCvars", strConVarName + "dmgfactor_victim", pDmgFactorVictim.GetDefaultValue());

    FileSystem::Write( pJson, "ReflectFriendlyFireMessage", strConVarName + "attacker_msg", strAttackerMsg);
    FileSystem::CreateFile(strFileName, pJson);
}

// Backup Broken File
void BackupFile(JsonValues@ pBackupData){
    FileSystem::CreateFile(strFileName + "_bak", pBackupData);
}
