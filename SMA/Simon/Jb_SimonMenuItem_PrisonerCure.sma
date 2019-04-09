#include amxmodx
#include fakemeta
#include reapi
#include chatprint

#include jailbreak

#define PLUGIN  "[JB] Simon menu item: Prisoner cure"
#define VERSION "15.01.2019"
#define AUTHOR  "ALIK"

#define CVAR_HEALTH         100
#define CVAR_SOUND_HEAL     "jailbreak/effect/heal_mini.wav"
#define CVAR_SPRITE_HEAL    "sprites/jailbreak/effect/heal_mini.spr"

new g_iItemId;

new g_iSpriteIndex_Heal;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    
    RegisterSimonMenuItem("Jb_SimonMenuItem_PrisonerCure", "#Jb_Menu_Simon_Item_6");

    g_iItemId = RegisterPlayersMenu("Jb_PlayersMenu_PrisonerCure");
}

public plugin_precache()
{
    g_iSpriteIndex_Heal = PRECACHE_MODEL(CVAR_SPRITE_HEAL);

    PRECACHE_SOUND(CVAR_SOUND_HEAL);
}

public jb_players_menu_loaded(const pId, const iPlayer, const iItemId)
{
    if(g_iItemId == iItemId)
    {
        if(!IsAlive(iPlayer) || !IsTeam(iPlayer, TEAM_PRISONER) || rg_get_user_health(iPlayer) >= CVAR_HEALTH)
            return JB_HANDLED;
    }
    return JB_CONTINUE;
}

public jb_players_menu_opened(const pId, const iPlayer, const iItemId)
{
    if(g_iItemId == iItemId)
    {
        jb_update_menu_item_info("%L", pId, "#Jb_Menu_Cell", rg_get_user_health(iPlayer));
    }

    return JB_CONTINUE;
}

public Jb_SimonMenuItem_PrisonerCure(const pId)
{
    jb_show_menu_players(pId, g_iItemId);

    return JB_CONTINUE;
}

public Jb_PlayersMenu_PrisonerCure(const pId, const iPlayer)
{
    if(!IsAlive(iPlayer) || !IsTeam(iPlayer, TEAM_PRISONER) || rg_get_user_health(iPlayer) >= CVAR_HEALTH)
    {
        jb_show_menu_simon(pId, .bSaved = true);
        
        return JB_HANDLED;
    }

    rg_set_user_health(iPlayer, CVAR_HEALTH);

    new Float:vecOrigin[3];
    get_entvar(iPlayer, var_origin, vecOrigin);

    //Effect
    message_begin(MSG_ALL, SVC_TEMPENTITY, {0,0,0});
    {
        write_byte(TE_SPRITETRAIL);
        write_coord(floatround(vecOrigin[0]));
        write_coord(floatround(vecOrigin[1]));
        write_coord(floatround(vecOrigin[2]) + 20);
        write_coord(floatround(vecOrigin[0]));
        write_coord(floatround(vecOrigin[1]));
        write_coord(floatround(vecOrigin[2]) + 30);
        write_short(g_iSpriteIndex_Heal);
        write_byte(10); //количество
        write_byte(10); //время отображения спрайта в секундах
        write_byte(4); //масштаб отрисовки модели спрайта
        write_byte(10); //скорость
        write_byte(10); //произвольность в скорости
    }
    message_end();

    new szSound[64];
    formatex(szSound, charsmax(szSound), "sound/%s", CVAR_SOUND_HEAL);

    UTIL_PlayWav(iPlayer, szSound);

    UTIL_SayText(0, "%L %L", LANG_PLAYER, "#Jb_Msg_Prefix", LANG_PLAYER, "#Jb_Msg_SimoMenuItem_PrisonCure", rg_get_user_name(iPlayer));

    jb_show_menu_simon(pId, .bSaved = true);

    return JB_CONTINUE;
}

PRECACHE_MODEL(const szModel[], any:...)
{
	new szFile[64], iReturn = -1;
	vformat(szFile, charsmax(szFile), szModel, 2);
	
	if(file_exists(szFile))
	{
		iReturn = engfunc(EngFunc_PrecacheModel, szFile);
	}
	else
	{
		UTIL_Log("Error", "%s | PRECACHEx000: %s", PLUGIN, szFile);
	}
	
	return iReturn;
}

PRECACHE_SOUND(const szSound[], any:...)
{
	new szFile[64], iReturn = -1;
	vformat(szFile, charsmax(szFile), szSound, 2);
	
	new szBuffer[64];
	formatex(szBuffer, charsmax(szBuffer), "sound/%s", szFile);
	
	if(file_exists(szBuffer))
	{
		iReturn = engfunc(EngFunc_PrecacheSound, szFile);
	}
	else
	{
		UTIL_Log("Error", "%s | PRECACHEx000: %s", PLUGIN, szBuffer);
	}
	
	return iReturn;
}