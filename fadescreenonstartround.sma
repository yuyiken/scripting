#define KFADE_HOLD_TIME			0.8
#define KFADE_FX_TIME			0.5
#define MESSAGE_TYPE			MSG_ONE_UNRELIABLE
// #define DEBUG

#define PL_VERSION 		"0.1"

#include <amxmodx>
#include <reapi>
#include <fadescreen>

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
}

public plugin_init()
{
	register_plugin("FadeScreenOnStartRound", PL_VERSION, "yuyi");
        RegisterHookChain(RG_CSGameRules_RestartRound, "OnGameRestart");
}

public OnGameRestart(const pPlayer)
{
    if(is_user_bot(pPlayer) || is_user_hltv(pPlayer) || !is_user_connected(pPlayer)){
        return;
    }
    __UTIL_ScreenFade(pPlayer, FADE_COLORS[random_num(1, sizeof(FADE_COLORS) - 1)], 50,	KFADE_FX_TIME, KFADE_HOLD_TIME);
}