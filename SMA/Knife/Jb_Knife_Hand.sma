#include amxmodx
#include fakemeta
#include hamsandwich
#include reapi

#include jailbreak

#define PLUGIN  "[JB] Knife: Hand"
#define VERSION "06.10.2018"
#define AUTHOR  "ALIK"

#define WEAPON_NAME			"weapon_hand"
#define WEAPON_REFERANCE 	"weapon_knife"

/** iWeapon */
#define IsCustomItem(%0) (get_entvar(%0, var_impulse) == g_iszWeaponKey)

/** Cvar ---> */
#define MODEL_V             "models/jailbreak/knife/v_hand.mdl"
#define MODEL_P             "models/jailbreak/knife/p_hand.mdl"

#define SOUND_HIT           "jailbreak/knife/hand_hit.wav"
#define SOUND_SLASH         "jailbreak/knife/hand_slash.wav"
#define SOUND_DEPLOY        "jailbreak/knife/hand_deploy.wav"

#define NEXT_ATTACK1        1.0
#define NEXT_ATTACK2        1.75
/** <--- */

new g_iszWeaponKey;

new g_iFmHook_EmitSound;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    RegisterHam(Ham_Item_Deploy, WEAPON_REFERANCE, "HamHook_Item_Deploy_Post", true);
    RegisterHam(Ham_Item_AddToPlayer, WEAPON_REFERANCE, "HamHook_Item_AddToPlayer_Post", true);

    RegisterHam(Ham_Weapon_PrimaryAttack, WEAPON_REFERANCE, "HamHook_Weapon_PrimaryAttack_Post", true);
    RegisterHam(Ham_Weapon_SecondaryAttack, WEAPON_REFERANCE, "HamHook_Weapon_SecondaryAttack_Post", true);

    g_iFmHook_EmitSound = register_forward(FM_EmitSound, "FmHook_EmitSound", false);
}

public plugin_precache()
{
    g_iszWeaponKey = engfunc(EngFunc_AllocString, WEAPON_NAME);

    PRECACHE_MODEL(MODEL_V);
    PRECACHE_MODEL(MODEL_P);

    PRECACHE_SOUND(SOUND_HIT);
    PRECACHE_SOUND(SOUND_SLASH);
    PRECACHE_SOUND(SOUND_DEPLOY);
}

public HamHook_Item_AddToPlayer_Post(const iItem, const pId)
{
    if(IsTeam(pId, TEAM_PRISONER))
    {
        set_entvar(iItem, var_impulse, g_iszWeaponKey);
    }
}

public HamHook_Item_Deploy_Post(const iItem)
{
    static pId; 
	
    if(CheckItem(iItem, pId))
    {
        set_entvar(pId, var_viewmodel, MODEL_V);
        set_entvar(pId, var_weaponmodel, MODEL_P);
    }
}

public HamHook_Weapon_PrimaryAttack_Post(const iItem)
{
    if(IsCustomItem(iItem))
    {
        set_member(iItem, m_Weapon_flNextPrimaryAttack, NEXT_ATTACK1);
        set_member(iItem, m_Weapon_flNextSecondaryAttack, NEXT_ATTACK1);
    }
}

public HamHook_Weapon_SecondaryAttack_Post(const iItem)
{
    if(IsCustomItem(iItem))
    {
        set_member(iItem, m_Weapon_flNextPrimaryAttack, NEXT_ATTACK2);
        set_member(iItem, m_Weapon_flNextSecondaryAttack, NEXT_ATTACK2);
    }
}

public FmHook_EmitSound(pId, iChannel, const szSound[], Float:flVolume, Float:flAttn, iFlags, iPitch)
{
    if(!IsPlayer(pId)) return FMRES_IGNORED;

    if(szSound[8] == 'k' && szSound[9] == 'n' && szSound[12] == 'e' && szSound[13] == '_')
    {
        new iItem = get_member(pId, m_pActiveItem);

        if(!IsCustomItem(iItem))
            return FMRES_IGNORED;

        #define _EMIT_SOUND(%1,%2) emit_sound(%1, iChannel, %2, flVolume, flAttn, iFlags, iPitch)

        switch(szSound[17])
        {
            case 'l':   _EMIT_SOUND(pId, SOUND_DEPLOY);
            case 's':   _EMIT_SOUND(pId, SOUND_SLASH);
            default:    _EMIT_SOUND(pId, SOUND_HIT);
        }
        return FMRES_SUPERCEDE;
    }
    return FMRES_IGNORED;
}

bool:CheckItem(const iItem, &iPlayer)
{
    if(!IsCustomItem(iItem))
        return false;

    iPlayer = get_member(iItem, m_pPlayer);

    return true;
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