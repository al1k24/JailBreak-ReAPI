#include amxmodx
#include reapi

#include jailbreak

#define PLUGIN 	"[JB] Addon: Restart"
#define VERSION	"14.02.2019"
#define AUTHOR	"ALIK"

enum _:ENUM_DATA_CVAR_ID
{
    CVAR_ID_GRAVITY,
    CVAR_ID_RESPAWN,
    
    CVAR_ID_ROUND
};
new g_iCvarId[ENUM_DATA_CVAR_ID];

enum _:ENUM_DATA_CVAR
{
    CVAR_GRAVITY,
    CVAR_RESPAWN,
    
    CVAR_ROUND[8]
};
new g_eCvar[ENUM_DATA_CVAR];

new HookJailBreak:g_iJBHook_RestartStart, HookJailBreak:g_iJBHook_RestartEnd;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    g_iJBHook_RestartEnd = RegisterHookJailBreak(JB_RestartEnd, "JBHook_RestartEnd_Post", true);
    g_iJBHook_RestartStart = RegisterHookJailBreak(JB_RestartStart, "JBHook_RestartStart_Post", true);

    g_iCvarId[CVAR_ID_GRAVITY] = get_cvar_pointer("sv_gravity");

    g_iCvarId[CVAR_ID_ROUND] = get_cvar_pointer("mp_round_infinite");
    g_iCvarId[CVAR_ID_RESPAWN] = get_cvar_pointer("mp_forcerespawn");

    g_eCvar[CVAR_GRAVITY] = get_pcvar_num(g_iCvarId[CVAR_ID_GRAVITY]);
    g_eCvar[CVAR_RESPAWN] = get_pcvar_num(g_iCvarId[CVAR_ID_RESPAWN]);

    get_pcvar_string(g_iCvarId[CVAR_ID_ROUND], g_eCvar[CVAR_ROUND], charsmax(g_eCvar[CVAR_ROUND]));
}

public JBHook_RestartStart_Post()
{
    jb_open_doors();

    set_pcvar_num(g_iCvarId[CVAR_ID_ROUND], 1);
    set_pcvar_num(g_iCvarId[CVAR_ID_RESPAWN], 1);
    set_pcvar_num(g_iCvarId[CVAR_ID_GRAVITY], 250);
}

public JBHook_RestartEnd_Post()
{
    set_pcvar_string(g_iCvarId[CVAR_ID_ROUND], g_eCvar[CVAR_ROUND]);

    set_pcvar_num(g_iCvarId[CVAR_ID_RESPAWN], g_eCvar[CVAR_RESPAWN]);
    set_pcvar_num(g_iCvarId[CVAR_ID_GRAVITY], g_eCvar[CVAR_GRAVITY]);

    DestroyHookJailBreak(g_iJBHook_RestartEnd);
    DestroyHookJailBreak(g_iJBHook_RestartStart);

    for(new pId = 1; pId < MaxClients; pId++)
    {
        if(!IsAlive(pId)) continue;

        rg_remove_all_items(pId);
    }
}