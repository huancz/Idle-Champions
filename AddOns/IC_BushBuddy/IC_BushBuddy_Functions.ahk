global ultused := {}
global startTime := 0

BushInitialize()
{
    ; g_SF.Hwnd := WinExist("ahk_exe IdleDragons.exe")
    ; g_SF.Memory.OpenProcessReader()
    g_SF.Hwnd := WinExist("ahk_exe " . g_userSettings[ "ExeName"])
    g_SF.Memory.OpenProcessReader()
    return
}

Bush_Run()
{
    BushInitialize()
    ; 1 = fams on field (trying to spawn monsters) = Q
    ; 0 = no fams, killing mobs = E
    famFormation := 0
    startTime := A_TickCount - g_BushSettings.bushDelay * 1000
    g_SF.DirectedInput(,, ["{e}"]*)
    loop, 10
        {
            ultUsed[A_Index] := 1
        }

    while (bushRunning)
    {
        sleep 10
        activeMonsters := % g_SF.Memory.ReadActiveMonstersCount()

        timeScale := g_SF.Memory.ReadTimeScaleMultiplier()
        currentTime := ( A_TickCount - startTime ) / 1000 * timeScale
        cooldown := floor(g_BushSettings.bushDelay - currentTime)
        GuiControl, ICScriptHub:, BushDelaySaved, % cooldown > 0 ? "Cooldown left: " . cooldown:"Cooldown left: " . "Ready"
;, % BushDelay < 1 ? bushDelay:"Waiting for monsters to die..."
        GuiControl, ICScriptHub:, BushMonsters, Monsters in area: %activeMonsters%
        GuiControl, ICScriptHub:, BushFormation, % famFormation == 1 ? "Formation in use: familiars on field":"Formation in use: no familiars on field"

        if (activeMonsters > g_BushSettings.MaxMonsters )
            {
            if ( famFormation == 0 )
                {
                    useUltimates()
                }
            else if (famFormation == 1) ; have 1/Q/spawn and we are over desired number of monsters, switch to 0/E/clear
                {
                    famFormation = 0
                    g_SF.DirectedInput(,, ["{e}"]* )                
                    startTime := A_TickCount
                }
            } else if (activeMonsters == 1 and famFormation == 0) {
                ; only boss remains, we want to spawn more mobs
                famFormation = 1
                g_SF.DirectedInput(,, ["{q}"]* )
            }

        ;   GuiControl, ICScriptHub:, TestTXT, % ultUsed[3]

        ; 0 = disabled for now
        if (0 and famFormation == 0 AND activeMonsters <= g_BushSettings.MaxMonsters and g_BushSettings.bushDelay < currentTime ) ;set to Q formation
            {
            famFormation = 1
            g_SF.DirectedInput(,, ["{q}"]* )
            loop, 10
                {
                    ultUsed[A_Index] := 0
                }
            }
            ; 48 = jim. Jim is crucial to the formation that clears spawned mobs = 'E' = famFormation 0. In famFormation = 1 (spawn) we want him to not be on field
            else if (famFormation == 1 && g_SF.Memory.ReadChampBenchedByID(48) == 0)
            {
                ; jim still on field (formation switch failed), try again
                g_SF.DirectedInput(,, ["{q}"]* )
            }
            else if (famFormation == 0 && g_SF.Memory.ReadChampBenchedByID(48) <> 0)
            {
                g_SF.DirectedInput(,, ["{e}"]* )
            }
    }
return
}

useUltimates()
{
    timeScale := g_SF.Memory.ReadTimeScaleMultiplier()
  ; GuiControl, ICScriptHub:, TestTXT, % currentTime
   loop, 10
        {
            if ( g_BushSettings.Ult[A_Index] and g_BushSettings.UltDelay[A_Index] < currentTime and !ultused[A_Index])
                {
                    ultUsed[A_Index] := 1
                    g_SF.DirectedInput(,, A_Index )
                }
        }
}
