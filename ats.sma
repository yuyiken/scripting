#define KFADE_HOLD_TIME			0.8
#define KFADE_FX_TIME			0.5
#define MESSAGE_TYPE			MSG_ONE_UNRELIABLE
// #define DEBUG
#pragma semicolon 1

#include <amxmodx>
#include <reapi>

//#define IsBot(%1)						(!g_aPlayerData[%1][AuthId][0])

const FADE_COLORS_RANDOM = 0;

enum color_e { R, G, B };

new const FADE_COLORS[][color_e] = 
{
	{0, 0, 0},		// random
    {0, 127, 255}, 	// blue 
    {255, 127, 0}, 	// orange 
    {127, 0, 255}, 	// purple
    {0, 255, 0}, 	// green
    {255, 100, 150}, // pink
    {255, 255, 255},  // white
    {239, 184, 16},  // gold
    {255, 0, 0} 	// red
};


new const PLUGIN_VERSION[] = "1.1";

new const VIP_FLAGS[] = "c";

new g_iRoundNumber;
new g_pCvarAtsRounds, g_pCvarMode, g_bitVipFlags, g_bitRestart;

public plugin_init() 
{
    register_plugin("Auto Team Switcher/Map Changer", PLUGIN_VERSION, "yuyi");
    
    g_bitVipFlags = read_flags(VIP_FLAGS);

    register_clcmd("say /roundnumber", "ClCmd_RoundNumber");
    register_concmd("amx_roundrestart", "Cmd_RoundRestart", ADMIN_KICK);
    
    RegisterHookChain(RG_RoundEnd, "OnRoundEnd_Post", true);
    RegisterHookChain(RG_CSGameRules_RestartRound, "OnGameRestart");
    
    g_pCvarAtsRounds = create_cvar("amx_atsrounds", "5" , .description = "Number of rounds before action is taken");
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
            
            client_print(0, print_chat, "[ATS] Restart en 3 segundos");
            restart();
        }
        else
        {
            // Modo cambio de mapa
            new currentMap[32];
            get_mapname(currentMap, charsmax(currentMap));
            
            if(!equal(currentMap, "de_dust2"))
            {
                client_print(0, print_chat, "[ATS] Cambiando a mapa de_dust2");
                //set_task(3.0, "changelevel");
                
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

public changelevel()
{
    engine_changelevel("de_dust2");
}

public OnGameRestart(const pPlayer)
{
    if (g_bitRestart){

        if (!is_user_alive(pPlayer)){
            rg_remove_items_by_slot(pPlayer, PRIMARY_WEAPON_SLOT);
        }
        client_cmd(0, "spk life");
        client_print_color(0, print_team_default, "[^3GOLD^1] ^4|---------- LiVE ! ---------------|");
        __UTIL_ScreenFade(pPlayer, FADE_COLORS[random_num(1, sizeof(FADE_COLORS) - 1)], 60, KFADE_FX_TIME, KFADE_HOLD_TIME);
    }
    g_bitRestart = false;
}

public restart()
{
    g_bitRestart = true;
    server_cmd("sv_restart 3");
}

stock __UTIL_ScreenFade(const pPlayer, iColor[color_e], iAlpha, Float:flFxTime = 1.0, Float:flHoldTime = 1.0)
{
	if(IsBlind(pPlayer))
		return;

	static iMsgIdScreenFade;

	if(iMsgIdScreenFade > 0 || (iMsgIdScreenFade = get_user_msgid("ScreenFade")))
	{
		message_begin(MESSAGE_TYPE, iMsgIdScreenFade, .player = pPlayer);
		write_short(FixedUnsigned16(flFxTime));
		write_short(FixedUnsigned16(flHoldTime));
		write_short(0x0000);
		write_byte(iColor[R]);
		write_byte(iColor[G]);
		write_byte(iColor[B]);
		write_byte(iAlpha);
		message_end();
	}
}

stock FixedUnsigned16(Float:flValue, iScale = (1 << 12)) {
	return clamp(floatround(flValue * iScale), 0, 0xFFFF);
}

stock bool:IsBlind(const pPlayer) {
	return bool:(Float:get_member(pPlayer, m_blindStartTime) + Float:get_member(pPlayer, m_blindFadeTime) >= get_gametime());
}
