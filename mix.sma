#define KFADE_HOLD_TIME			0.8
#define KFADE_FX_TIME			0.5
#define MESSAGE_TYPE			MSG_ONE_UNRELIABLE
// #define DEBUG

#define PL_VERSION 		"0.1"

#include <amxmodx>
#include <reapi>

//#define IsBot(%1)						(!g_aPlayerData[%1][AuthId][0])

const FADE_COLORS_RANDOM = 0

enum color_e { R, G, B }

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
	register_plugin("ats", PL_VERSION, "yuyi");
    RegisterHookChain(RG_CSGameRules_RestartRound, "OnGameRestart");

}

public OnGameRestart(const pPlayer)
{

		__UTIL_ScreenFade(pPlayer, FADE_COLORS[random_num(1, sizeof(FADE_COLORS) - 1)], 50,	KFADE_FX_TIME, KFADE_HOLD_TIME);

//	return HC_CONTINUE
}

stock __UTIL_ScreenFade(const pPlayer, iColor[color_e], iAlpha, Float:flFxTime = 1.0, Float:flHoldTime = 1.0)
{
	if(IsBlind(pPlayer))
		return

	const FFADE_IN = 0x0000
	static iMsgIdScreenFade

	if(iMsgIdScreenFade > 0 || (iMsgIdScreenFade = get_user_msgid("ScreenFade")))
	{
		message_begin(MESSAGE_TYPE, iMsgIdScreenFade, .player = pPlayer)
		write_short(FixedUnsigned16(flFxTime))
		write_short(FixedUnsigned16(flHoldTime))
		write_short(FFADE_IN)
		write_byte(iColor[R])
		write_byte(iColor[G])
		write_byte(iColor[B])
		write_byte(iAlpha)
		message_end()
	}
}

stock FixedUnsigned16(Float:flValue, iScale = (1 << 12)) {
	return clamp(floatround(flValue * iScale), 0, 0xFFFF)
}

stock bool:IsBlind(const pPlayer) {
	return bool:(Float:get_member(pPlayer, m_blindStartTime) + Float:get_member(pPlayer, m_blindFadeTime) >= get_gametime())
}