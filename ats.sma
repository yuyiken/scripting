new const PLUGIN_VERSION[] = "1.1"

// Перечислить буквы amxx-флагов, при наличии любого из которых игрок получает
//		при первом спавне в раунде щипцы и броню
new const VIP_FLAGS[] = "c"

#include <amxmodx>
#include <reapi>


#pragma semicolon 1

new g_iRoundNumber = 0;
new g_pCvarAtsRounds, g_pCvarMode, g_bitVipFlags;

public plugin_init() 
{
    register_plugin("Auto Team Switcher/Map Changer", PLUGIN_VERSION, "nikhilgupta345");
    
    g_bitVipFlags = read_flags(VIP_FLAGS);

    register_clcmd("say /roundnumber", "ClCmd_RoundNumber");

    register_concmd("amx_roundrestart", "Cmd_RoundRestart", ADMIN_KICK);
    
    RegisterHookChain(RG_RoundEnd, "OnRoundEnd_Post", true);
    //register_event("TextMsg", "OnGameRestart", "a", "2&#Game_C", "2&#Game_W");
    RegisterHookChain(RG_CSGameRules_RestartRound, "OnGameRestart");
    
    g_pCvarAtsRounds = create_cvar("amx_atsrounds", "15" , .description = "Number of rounds before action is taken");
    g_pCvarMode = create_cvar("amx_ats_mode", "0", .description = "0=Swap teams, 1=Change to dust2");
}

public ClCmd_RoundNumber(const id)
{
    client_print(id, print_chat, "Current round: %d/%d", 
        g_iRoundNumber, 
        get_pcvar_num(g_pCvarAtsRounds)
    );
    return PLUGIN_HANDLED;
}

public OnRoundEnd_Post()
{
    g_iRoundNumber++;
    
    if(g_iRoundNumber >= get_pcvar_num(g_pCvarAtsRounds))
    {
        if(get_pcvar_num(g_pCvarMode) == 0)
        {
            // Modo swap de equipos
            server_cmd("swapteams 0");
            client_print(0, print_chat, "[ATS] Los equipos han sido cambiados automáticamente");
        }
        else
        {
            // Modo cambio de mapa
            new currentMap[32];
            get_mapname(currentMap, charsmax(currentMap));
            
            if(!equal(currentMap, "de_dust2"))
            {
                client_print(0, print_chat, "[ATS] Cambiando a mapa de_dust2");
                engine_changelevel("changelevel de_dust2");
            }
            else
            {
                client_print(0, print_chat, "[ATS] El mapa ya es de_dust2, no se realiza acción");
            }
        }
        
        g_iRoundNumber = 0;
    }
}

public Cmd_RoundRestart(const id)
{
    if(!(get_user_flags(id) & g_bitVipFlags))
        return PLUGIN_HANDLED;
    
    g_iRoundNumber = 0;
    client_print(id, print_chat, "[ATS] Contador de rondas reiniciado");
    return PLUGIN_HANDLED;
}

public OnGameRestart()
{
    g_iRoundNumber = 0;
}