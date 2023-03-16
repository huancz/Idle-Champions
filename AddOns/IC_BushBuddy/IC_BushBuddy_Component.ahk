#include %A_LineFile%\..\IC_BushBuddy_Functions.ahk

g_TabControlHeight := g_TabControlHeight >= 700 ? g_TabControlHeight : 700
GUIFunctions.AddTab("BushBuddy")

;g_SF := new IC_SharedFunctions_Class

global g_BushSettings := g_SF.LoadObjectFromJSON( A_LineFile . "\..\BushSettings.json" )
global bushRunning := false
global activeMonsters := 0
global MaxMonsters := 999
global bushFormationTXT := "unknown"

;check if first run
If !IsObject( g_BushSettings )
{
    g_BushSettings := {}
}

if ( g_BushSettings.Ult == "" )
{
    g_BushSettings.Ult := {}
    loop, 10
    {
        g_BushSettings.Ult[A_Index] := 0
    }
}

if ( g_BushSettings.UltDelay == "" )
{
    g_BushSettings.UltDelay := {}
    loop, 10
    {
        g_BushSettings.UltDelay[A_Index] := 0
    }
}

Gui, ICScriptHub:Tab, BushBuddy
Gui, ICScriptHub:Font, w700
Gui, ICScriptHub:Add, Text, x15 y70 w50, Status:
Gui, ICScriptHub:Font, w400
Gui, ICScriptHub:Add, Text, x+10 y70 w300 vBushStatus, Off
Gui, ICScriptHub:Add, Text, x15 y90 w300 vBushMonsters, Monsters in area: unknown
Gui, ICScriptHub:Add, Text, x15 y110 w300 vBushFormation, Formation in use: %bushFormationTXT%

Gui, ICScriptHub:Add, Text, x15 y145 w95, Use ultimates:
loop, 10
{
    chk := g_BushSettings.Ult[A_Index]
    Gui, ICScriptHub:Add, Checkbox, vUlt_CB%A_Index% Checked%chk% x+5, % A_Index
}

Gui, ICScriptHub:Add, Text, x15 y160, Saved:
loop, 10
{
    chk := g_BushSettings.Ult[A_Index]
    xval = % 85 + A_Index * 33
    Gui, ICScriptHub:Add, Text, x%xval% y160 vUlt_CB%A_Index%_Saved, % chk == 1 ? "X":""
}

Gui, ICScriptHub:Add, Text, x15 y182 w89, Delay after 1st ult:
loop, 10
{
    chk := g_BushSettings.UltDelay[A_Index]
    Gui, ICScriptHub:Add, Edit, vUlt_Delay%A_Index% x+5 y179 w28, % g_BushSettings.UltDelay[A_Index]
}

Gui, ICScriptHub:Add, Text, x+5 y190, game seconds


Gui, ICScriptHub:Add, Text, x15 y200, Saved:
loop, 10
{
    chk := g_BushSettings.UltDelay[A_Index]
    xval = % 85 + A_Index * 33
    Gui, ICScriptHub:Add, Text, x%xval% y200 vUlt_Delay%A_Index%_Saved w20, % g_BushSettings.UltDelay[A_Index]
}

if ( g_BushSettings.MaxMonsters == "" )
    g_BushSettings.MaxMonsters := 2
Gui, ICScriptHub:Add, Text, x15 y+15, Max active monsters before clicking bushes:
Gui, ICScriptHub:Add, Edit, vBushMaxMonsters y+5 w50, % g_BushSettings.MaxMonsters
Gui, ICScriptHub:Add, Text, y+5 vBushMaxMonstersSaved, % "Saved: " . g_BushSettings.MaxMonsters

if ( g_BushSettings.bushDelay == "" )
    g_BushSettings.bushDelay := 60
Gui, ICScriptHub:Add, Text, x15 y+15, Cooldown (game seconds) to keep in E formation:
Gui, ICScriptHub:Add, Edit, vBushDelay y+5 w50, % g_BushSettings.bushDelay
Gui, ICScriptHub:Add, Text, y+5 vBushDelaySaved w250, % "Saved: " . g_BushSettings.bushDelay
    
Gui, ICScriptHub:Add, Button, x15 y+15 gBush_Save_Clicked, Save
Gui, ICScriptHub:Add, Button, x15 y+15 w50 gBush_Run_Clicked, Start
Gui, ICScriptHub:Add, Button, x15 y+5 w50 gBush_Stop_Clicked, Stop

;Gui, ICScriptHub:Add, Button, x15 y+5 w50 gTest_Clicked, Test
;Gui, ICScriptHub:Add, Text, x+10 vTestTXT, test

Test_Clicked()
{
    useUltimates()
}

Bush_Save_Clicked()
{
    global
    Gui, ICScriptHub:Submit, NoHide
    g_BushSettings.MaxMonsters := BushMaxMonsters
    g_BushSettings.bushDelay := BushDelay
    loop, 10
    {
        g_BushSettings.Ult[A_Index] := Ult_CB%A_Index%
        GuiControl, ICScriptHub:, Ult_CB%A_Index%_Saved, % Ult_CB%A_Index% == 1 ? "X":""
    }
    loop, 10
    {
        g_BushSettings.UltDelay[A_Index] := Ult_Delay%A_Index%
        GuiControl, ICScriptHub:, Ult_Delay%A_Index%_Saved, % Ult_Delay%A_Index%
    }
    g_bush.UpdateSettings(g_BushSettings)
    g_SF.WriteObjectToJSON( A_LineFile . "\..\BushSettings.json" , g_BushSettings )
    GuiControl, ICScriptHub:, BushMaxMonstersSaved, % "Saved: " . g_BushSettings.MaxMonsters
    GuiControl, ICScriptHub:, BushDelaySaved, % "Saved: " . g_BushSettings.bushDelay
    return
}

Bush_Run_Clicked()
{
    bushRunning = true
    GuiControl, ICScriptHub:, BushStatus, On
    Bush_Run()
    return
}

Bush_Stop_Clicked()
{
    global bushRunning = false
    GuiControl, ICScriptHub:, BushStatus, Off
    GuiControl, ICScriptHub:, BushMonsters, Monsters in area: unknown
}