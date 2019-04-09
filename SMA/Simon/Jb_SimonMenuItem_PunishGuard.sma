#include amxmodx
#include reapi
#include chatprint

#include jailbreak

#define PLUGIN  "[JB] Simon menu item: Punish guard"
#define VERSION "20.01.2019"
#define AUTHOR  "ALIK"

new g_iItemId;

new bool:g_bBlockChangeTeam[33]

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    RegisterHookJailBreak(JB_ChooseTeam, "JBHook_ChooseTeam", false);

    RegisterHookJailBreak(JB_RoundEnd, "JBHook_RoundEnd_Post", true);
    
    RegisterSimonMenuItem("Jb_SimonMenuItem_PunishGuard", "#Jb_Menu_Simon_Item_5");

    g_iItemId = RegisterPlayersMenu("Jb_PlayersMenu_PunishGuard");
}

public JBHook_ChooseTeam(const pId, const TeamName:iChooseTeam)
{
    if(iChooseTeam == TEAM_GUARD && g_bBlockChangeTeam[pId])
    {
        UTIL_SayText(pId, "%L %L", pId, "#Jb_Msg_Prefix", pId, "#Jb_Msg_SimoMenuItem_PunishGuard_IsBlocked");

        return JB_HANDLED;
    }
        
    return JB_CONTINUE;
}

public JBHook_RoundEnd_Post()
{
    arrayset(g_bBlockChangeTeam, false, sizeof(g_bBlockChangeTeam));
}

public client_disconnected(pId)
{
    g_bBlockChangeTeam[pId] = false;
}

public jb_players_menu_loaded(const pId, const iPlayer, const iItemId)
{
    if(g_iItemId == iItemId)
    {
        if(iPlayer == pId || !IsTeam(iPlayer, TEAM_GUARD))
            return JB_HANDLED;
    }
    return JB_CONTINUE;
}

public Jb_SimonMenuItem_PunishGuard(const pId)
{
    jb_show_menu_players(pId, g_iItemId);

    return JB_CONTINUE;
}

public Jb_PlayersMenu_PunishGuard(const pId, const iPlayer)
{
    if(iPlayer == pId || !IsTeam(iPlayer, TEAM_GUARD))
    {
        jb_show_menu_simon(pId, .bSaved = true);
        
        return JB_HANDLED;
    }
    g_bBlockChangeTeam[iPlayer] = true;

    jb_set_user_team(iPlayer, TEAM_PRISONER, .bKill = IsAlive(iPlayer));

    UTIL_SayText(0, "%L %L", LANG_PLAYER, "#Jb_Msg_Prefix", LANG_PLAYER, "#Jb_Msg_SimoMenuItem_PunishGuard", rg_get_user_name(iPlayer));

    jb_show_menu_simon(pId, .bSaved = true);

    return JB_CONTINUE;
}