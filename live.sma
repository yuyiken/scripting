#include <amxmodx>

#define ACCESS_FLAG ADMIN_LEVEL_H // Usar constantes definidas

new g_Count;
new bool:g_Data;

public plugin_init() 
{
    register_plugin("CooL_Live", "1.1", "M3taph0riK");
    
    register_event("TextMsg", "game_commencing", "a", "2&#Game_C");
    register_event("HLTV", "new_round", "a", "1=0", "2=0");
    register_clcmd("say /live", "say_live", ACCESS_FLAG, "Inicia un partido oficial");
    
    set_hudmessage(
        170, 255, 255,        // RGB
        -1.0, 0.25,           // X, Y
        1, 6.0, 6.0,           // Efectos
        0.5, 3.0,              // Tiempos
        -1
    );
}

public game_commencing()
{
    g_Data = true;
}

public new_round(id)
{
    if(g_Data)
    {
        if(++g_Count == 1)
        {
            show_hudmessage(0, "Good Luck & Have Fun !!");
        }
        else if(g_Count >= 2)
        {
            server_cmd("sv_restart 3");
            set_task(3.0, "msg1", id);
        }
    }
}

public say_live(id)
{
    if(!(get_user_flags(id) & ACCESS_FLAG))
        return PLUGIN_HANDLED;
    
    server_cmd("sv_restart 3");
    set_task(3.0, "msg2", id);
    return PLUGIN_HANDLED;
}

public msg1(id)
{
    client_cmd(0, "spk %clife in three seconds%c", 34, 34);
        
    client_print_color(id, print_team_default, "[GOLD] |---------- LiVE ! ---------------|");
    
    new name[32];
    get_user_name(id, name, charsmax(name));
    client_print_color(id, print_team_default, "Echipa GOLD va ureaza spor la fraguri!", name);
}

public msg2(id)
{
  //  client_cmd(0, "spk \"life in three seconds\"");
    client_cmd(0, "spk %clife in three seconds%c", 34, 34);
    
    client_print_color(0, print_team_default, "[GOLD] |--------------- LiVE ! ---------------|");
    
    new name[32];
    get_user_name(id, name, charsmax(name));
    client_print_color(0, print_team_default, "Adminul %s va ureaza spor la fraguri!", name);
}