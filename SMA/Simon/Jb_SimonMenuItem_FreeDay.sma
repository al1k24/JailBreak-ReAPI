#include amxmodx
#include reapi

#include jailbreak

#define PLUGIN  "[JB] Simon menu item: FreeDay"
#define VERSION "07.02.2019"
#define AUTHOR  "ALIK"

#define CVAR_DELAY 3

new g_iItemId;

new g_iTime;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    
    g_iItemId = RegisterSimonMenuItem("Jb_SimonMenuItem_FreeDay", "#Jb_Menu_Simon_Item_4");
}

public jb_simon_menu_opened(const pId, const iItemId)
{
    if(g_iItemId == iItemId)
    {
        if(!IsRound(ROUND_START))
        {
            jb_update_menu_item_info("%L", pId, "#Jb_Menu_Disable_3");

            return JB_HANDLED;
        }

        new DayMode:iDayMode = jb_get_day_mode();
        switch(iDayMode)
        {
            case DAY_MODE_NORMAL: jb_update_menu_item_info("%L", pId, "#Jb_Menu_Simon_Item_4_1");
            case DAY_MODE_FREE_DAY: jb_update_menu_item_info("%L", pId, "#Jb_Menu_Simon_Item_4_2");
            default: return JB_HANDLED;
        }
    }

    return JB_CONTINUE;
}

public Jb_SimonMenuItem_FreeDay(const pId)
{
    if(!IsRound(ROUND_START))
        return JB_HANDLED;

    if(g_iTime > get_systime())
    {
        PRINT_CENTER(pId, "%L", pId, "#Jb_Msg_Error_Wait", g_iTime - get_systime());

        jb_show_menu_simon(pId, .bSaved = true);
        
        return JB_HANDLED;
    }
    g_iTime = get_systime(CVAR_DELAY);

    new DayMode:iDayMode = jb_get_day_mode();
    switch(iDayMode)
    {
        case DAY_MODE_NORMAL:
        {
            jb_set_day_mode(DAY_MODE_FREE_DAY);
        }
        case DAY_MODE_FREE_DAY:
        {
            jb_reset_day_mode(DAY_MODE_FREE_DAY);
        }
        default: return JB_HANDLED;
    }
    
    jb_show_menu_simon(pId, .bSaved = true);

    return JB_CONTINUE;
}