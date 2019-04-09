#include amxmodx
#include reapi

#include jailbreak

#define PLUGIN  "[JB] Simon menu item: Weapon Search"
#define VERSION "07.02.2019"
#define AUTHOR  "ALIK"

#define CVAR_RADIUS_SEARCH 60

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    
    RegisterSimonMenuItem("Jb_SimonMenuItem_WeaponSearch", "#Jb_Menu_Simon_Item_3");
}

public Jb_SimonMenuItem_WeaponSearch(const pId)
{
    new iPrisonersNum = UTIL_GetPlayers((1<<_:TEAM_PRISONER), 1);
    if(!iPrisonersNum)
    {
        PRINT_CENTER(pId, "%L", pId, "#Jb_Msg_Error_NoPlayers");

        jb_show_menu_simon(pId, .bSaved = true);
        
        return JB_HANDLED;
    }

    new iTarget, iBody;
    get_user_aiming(pId, iTarget, iBody, CVAR_RADIUS_SEARCH);

    if(!IsPlayer(iTarget) || !IsAlive(iTarget))
    {
        PRINT_CENTER(pId, "%L", pId, "#Jb_Msg_Error_ComeToAlivePlayer");

        jb_show_menu_simon(pId, .bSaved = true);
        
        return JB_HANDLED;
    }

    new TeamName:iTeam = get_member(iTarget, m_iTeam);
    if(iTeam != TEAM_PRISONER)
    {
        PRINT_CENTER(pId, "%L", pId, "#Jb_Msg_Error_IvalidPlayer");

        jb_show_menu_simon(pId, .bSaved = true);
        
        return JB_HANDLED;
    }

    new bitsWeapons = get_entvar(iTarget, var_weapons);
    if(bitsWeapons &= ~(1<<CSW_HEGRENADE|1<<CSW_SMOKEGRENADE|1<<CSW_FLASHBANG|1<<CSW_KNIFE|1<<31))
    {
        PRINT_CENTER(pId, "%L", pId, "#Jb_Msg_Success_PlayerHaveWeapon");
    }
    else
    {
        PRINT_CENTER(pId, "%L", pId, "#Jb_Msg_Error_PlayerNoWeapon");
    }

    jb_show_menu_simon(pId, .bSaved = true);

    return JB_CONTINUE;
}

/**
	iType
	0 - мёртвые
	1 - живые
	-1 - все
 */
stock UTIL_GetPlayers(const bitsTeam, const iType = -1)
{
    new iNum = 0;
    for(new pId = 1; pId <= MaxClients; pId++)
    {
        switch(iType)
        {
            case -1: if(!IsConnected(pId)) continue;
            case 0: if(IsAlive(pId)) continue;
            case 1: if(!IsAlive(pId)) continue;
        }

        if(~bitsTeam & (1<<get_member(pId, m_iTeam)))
            continue;

        ++iNum;
    }

    return iNum;
}