const string strInfoName = "ShowDiffInHostname";
const string strInfoAuthor = "UeberDaniel";
const string strInfoVersion = "1.0";
const string strFileName = strInfoName + "_" + strInfoVersion;
const string strConVarName = "as_sdih_";
const array<string> strScriptDescription = {
    "---------------------------------> DO NOT DELETE THIS! YOU MAY NEED IT IN THE FUTURE! <---------------------------------",
    "| This plugin does NOT set the game into custom mode, therefore it does NOT trigger the associated achievements lock.  |",
    "|======================================================================================================================|",
    "|                                                                                                                      |",
    "| Contagion AngelScript Plugin: ShowDiffInHostname                                                                     |",
    "|                                                                                                                      |",
    "| DESCRIPTION:                                                                                                         |",
    "|                                                                                                                      |",
    "| This plugin will allow you to display a custom text based on the server difficulty behind the hostname.              |",
    "| Each difficulty has a ConVar which can be changed in this configfile or at runtime on your server/client console.    |",
    "|======================================================================================================================|",
    "|                                                                                                                      |",
    "| CONFIGURATION:                                                                                                       |",
    "|  CVars:                                                                                                              |",
    "|   as_sdih_difftext_0     : Text for difficulty = 0                                                                   |",
    "|   as_sdih_difftext_1     : Text for difficulty = 1                                                                   |",
    "|   as_sdih_difftext_2     : Text for difficulty = 2                                                                   |",
    "|   as_sdih_difftext_3     : Text for difficulty = 3                                                                   |",
    "|   as_sdih_difftext_4     : Text for difficulty = 4                                                                   |",
    "|                                                                                                                      |",
    "|======================================================================================================================|",
    "|                                                                                                                      |",
    "| CHANGELOG: [ + Added Feature | - Removed Feature | * Changed or Fixed Feature ]                                      |",
    "|                                                                                                                      |",
    "| 05.12.2020: Version 1.0                                                                                              |",
    "| + Initial Release                                                                                                    |",
    "|======================================================================================================================|",
    "| Visit https://ohne-reue.de/Scripting/Contagion-AngelScript/Plugins for more Information.                             |",
    "| Created 2020 by https://steamcommunity.com/id/UeberDaniel for https://ohne-reue.de Contagion servers.                |",
    "------------------------------------------------------------------------------------------------------------------------"
};


// Default DifficultyText Names
const array<string> strDefaultDifficultyText = { "[Easy]", "[Normal]", "[Hard]", "[Extreme]", "[Nightmare]" };

// CASConVars
CASConVar@ pHostname = null;
CASConVar@ pDifficulty = null;
array <CASConVar@> pDifficultyText(5);          // DifficultyText ConVars

// Global Variables
bool bIgnoreHostnameChanged = false;            // Flag for ignoring the HostnameChanged function
string strBaseHostname;                         // Place for storing the BaseHostname

void OnPluginInit()
{
	PluginData::SetName(strInfoName);
	PluginData::SetAuthor(strInfoAuthor);
	PluginData::SetVersion(strInfoVersion);

    for(uint i = 0; i < pDifficultyText.length(); i++){
        @pDifficultyText[i] = ConVar::Create((strConVarName + "difftext_" + i), strDefaultDifficultyText[i], ("Text for difficulty = " + i), LEVEL_ADMIN);
        ConVar::Register(pDifficultyText[i], ("DifficultyTextChanged"));
    }

    @pDifficulty = ConVar::Find("difficulty");
    ConVar::Register(pDifficulty, "DifficultyChanged");

    @pHostname = ConVar::Find("hostname");
    strBaseHostname = pHostname.GetValue(); // Save BaseHostname;

    InitFilesystem();                       // Create/Read Configfile

    pHostname.SetValue(pHostname.GetValue() + " " + pDifficultyText[Utils.StringToInt(pDifficulty.GetValue())].GetValue());
    ConVar::Register(pHostname, "HostnameChanged");
}

// Restore BaseHostname on Unloading
void OnPluginUnload()
{
    bIgnoreHostnameChanged = true;
    pHostname.SetValue(strBaseHostname);
}

// Update the hostname if the difficulty value has changed.
void DifficultyChanged(string &in strNewValue, string &in strOldValue){
    bIgnoreHostnameChanged = true;
    pHostname.SetValue(strBaseHostname + " " + pDifficultyText[Utils.StringToInt(strNewValue)].GetValue());
}

// Update the hostname if the DifficultyText_X was changed.
void DifficultyTextChanged(string &in strNewValue, string &in strOldValue){
    if(strNewValue == ""){
        Log.PrintToServerConsole(LOGTYPE_INFO, "[" + strInfoName + "] Current DifficultyText: '" +  strOldValue + "'");
    }
    else{
        Log.PrintToServerConsole(LOGTYPE_INFO, "[" + strInfoName + "] Changed DifficultyText from '" +  strOldValue + "' to '" + strNewValue + "'");
        for(uint i = 0; i < pDifficultyText.length(); i++){
            bIgnoreHostnameChanged = true;
            pHostname.SetValue(strBaseHostname + " " + strNewValue);
        }
    }
}

// Add the DifficultyText to the hostname if the hostname was changed at runtime.
void HostnameChanged(string &in strNewValue, string &in strOldValue){
    if(bIgnoreHostnameChanged) bIgnoreHostnameChanged = false;
    else{
        bIgnoreHostnameChanged = true;
        strBaseHostname = pHostname.GetValue();         // Save new BaseHostname;
        pHostname.SetValue(strBaseHostname + " " + pDifficultyText[Utils.StringToInt(pDifficulty.GetValue())].GetValue());
        Log.PrintToServerConsole(LOGTYPE_INFO, "[" + strInfoName + "] Hostname changed: '" +  strNewValue + "'");
    }
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
        for(uint i = 0; i < pDifficultyText.length(); i++){
            switch(FileSystem::Exists(pFileData, "Difficulty", strConVarName + "difftext_" + i)){
                case 0:{ pDifficultyText[i].SetValue(FileSystem::GrabString(pFileData, "Difficulty", strConVarName + "difftext_" + i)); break; }
                case 2:{ bFileBroken = true;                                                                                            break; }
                default:{                                                                                                               break; }
            }
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

    for(uint i = 0; i < pDifficultyText.length(); i++){         //Write Config Values
        FileSystem::Write( pJson, "Difficulty", strConVarName + "difftext_" + i, strDefaultDifficultyText[i]);
    }
    FileSystem::CreateFile(strFileName, pJson);
}

// Backup Broken File
void BackupFile(JsonValues@ pBackupData){
    FileSystem::CreateFile(strFileName + "_bak", pBackupData);
}
