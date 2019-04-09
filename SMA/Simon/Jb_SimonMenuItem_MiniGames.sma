#include amxmodx

#include jailbreak

#define PLUGIN  "[JB] Simon menu item: Mini games"
#define VERSION "05.02.2019"
#define AUTHOR  "ALIK"

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    
    RegisterSimonMenuItem("Jb_SimonMenuItem_MiniGames", "#Jb_Menu_Simon_Item_7");
}

public Jb_SimonMenuItem_MiniGames(const pId)
{
    PRINT_CHAT(pId, "* Jb_SimonMenuItem_MiniGames");

    return JB_CONTINUE;
}