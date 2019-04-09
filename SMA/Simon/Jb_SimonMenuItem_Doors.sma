#include amxmodx

#include jailbreak

#define PLUGIN  "[JB] Simon menu item: Doors"
#define VERSION "07.02.2019"
#define AUTHOR  "ALIK"

#define CVAR_DELAY 2

new g_iItemId;

new g_iTime;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    g_iItemId = RegisterSimonMenuItem("Jb_SimonMenuItem_Doors", "#Jb_Menu_Simon_Item_1");
}

public jb_simon_menu_opened(const pId, const iItemId)
{
	if(g_iItemId == iItemId)
	{
        jb_update_menu_item_info("%L", pId, jb_get_doors_status() ? "#Jb_Menu_Simon_Item_1_2" : "#Jb_Menu_Simon_Item_1_1");
	}
}

public Jb_SimonMenuItem_Doors(const pId)
{
    if(g_iTime > get_systime())
    {
        PRINT_CENTER(pId, "%L", pId, "#Jb_Msg_Error_Wait", g_iTime - get_systime());

        jb_show_menu_simon(pId, .bSaved = true);
        
        return JB_HANDLED;
    }

    if(jb_get_doors_status())
    {
        jb_close_doors();
    }
    else
    {
        jb_open_doors();
    }
    g_iTime = get_systime(CVAR_DELAY);

    jb_show_menu_simon(pId, .bSaved = true);

    return JB_CONTINUE;
}