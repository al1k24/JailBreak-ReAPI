#include amxmodx
#include hamsandwich
#include reapi
#include chatprint

#include jailbreak

#define PLUGIN  "[JB] Simon menu item: Transfer simon"
#define VERSION "07.02.2019"
#define AUTHOR  "ALIK"

new g_iItemId;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    
    RegisterSimonMenuItem("Jb_SimonMenuItem_TransferSimon", "#Jb_Menu_Simon_Item_8");

    g_iItemId = RegisterPlayersMenu("Jb_PlayersMenu_TransferSimon");
}

public jb_players_menu_loaded(const pId, const iPlayer, const iItemId)
{
    if(g_iItemId == iItemId)
    {
        if(iPlayer == pId || !IsTeam(iPlayer, TEAM_GUARD) || !IsAlive(iPlayer))
            return JB_HANDLED;
    }
    return JB_CONTINUE;
}

public Jb_SimonMenuItem_TransferSimon(const pId)
{
    jb_show_menu_players(pId, g_iItemId);

    return JB_CONTINUE;
}

public Jb_PlayersMenu_TransferSimon(const pId, const iPlayer)
{
    if(iPlayer == pId || !IsTeam(iPlayer, TEAM_GUARD) || !IsAlive(iPlayer))
    {
        jb_show_menu_simon(pId, .bSaved = true);
        
        return JB_HANDLED;
    }

    if(jb_transfer_simon(pId, iPlayer))
    {
        new iActiveItem = get_member(pId, m_pActiveItem);

        if(iActiveItem > 0 && get_member(iActiveItem, m_iId) == CSW_KNIFE)
        {
            ExecuteHamB(Ham_Item_Deploy, iActiveItem);
        }

        UTIL_SayText(0, "%L %L", LANG_PLAYER, "#Jb_Msg_Prefix", LANG_PLAYER, "#Jb_Msg_SimoMenuItem_TransferSimon", rg_get_user_name(iPlayer));

        jb_show_menu_simon(iPlayer, .bSaved = true);
    }
    else
    {
        jb_show_menu_simon(pId, .bSaved = true);
    }

    return JB_CONTINUE;
}