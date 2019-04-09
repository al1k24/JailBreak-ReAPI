#include amxmodx
#include fakemeta

#include jailbreak

#define PLUGIN  "[JB] Simon menu item: Counter"
#define VERSION "07.02.2019"
#define AUTHOR  "ALIK"

#define TASK_COUNTER 15112018

#define MenuId_Counter "ShowMenu_Counter"

new g_iTimer;

new bool:g_bCounter;

new HookJailBreak:g_iJBHook;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    RegisterMenu(MenuId_Counter, "ShowMenu_Counter_Handler");

    DisableHookJailBreak((g_iJBHook = RegisterHookJailBreak(JB_RoundEnd, "JBHook_RoundEnd_Post", true)));

    RegisterSimonMenuItem("Jb_SimonMenuItem_Counter", "#Jb_Menu_Simon_Item_2");
}

public plugin_precache()
{
    for(new i = 0, szSound[64]; i < 11; i++)
    {
        formatex(szSound, charsmax(szSound), "jailbreak/counter/%d.wav", i);
        
        PRECACHE_SOUND(szSound);
    }

    PRECACHE_SOUND("jailbreak/counter/reset.wav");
}

public JBHook_RoundEnd_Post()
{
    g_bCounter = false;

    remove_task(TASK_COUNTER);

    DisableHookJailBreak(g_iJBHook);
}

public Jb_SimonMenuItem_Counter(const pId)
{
    ShowMenu_Counter(pId)
}

ShowMenu_Counter(const pId)
{
    jb_update_informer_up(pId);

    new szMenu[190], iLen, bitsKeys = KEY(0);
    MENU_TITLE(szMenu, iLen, "%L^n", pId, "#Jb_Menu_Counter_Title");

    if(g_bCounter)
    {
        MENU_ITEM(szMenu, iLen, "^n%L \d%L", pId, "#Jb_Menu_Number", 1, pId, "#Jb_Menu_Counter_Item_1");
        MENU_ITEM(szMenu, iLen, "^n%L \d%L", pId, "#Jb_Menu_Number", 2, pId, "#Jb_Menu_Counter_Item_2");
        MENU_ITEM(szMenu, iLen, "^n%L \d%L", pId, "#Jb_Menu_Number", 3, pId, "#Jb_Menu_Counter_Item_3");
        MENU_ITEM(szMenu, iLen, "^n%L \d%L", pId, "#Jb_Menu_Number", 4, pId, "#Jb_Menu_Counter_Item_4");
        MENU_ITEM(szMenu, iLen, "^n%L \d%L", pId, "#Jb_Menu_Number", 5, pId, "#Jb_Menu_Counter_Item_5");
    }
    else
    {
        bitsKeys |= KEY(1)|KEY(2)|KEY(3)|KEY(4)|KEY(5);

        MENU_ITEM(szMenu, iLen, "^n%L \w%L", pId, "#Jb_Menu_Number", 1, pId, "#Jb_Menu_Counter_Item_1");
        MENU_ITEM(szMenu, iLen, "^n%L \w%L", pId, "#Jb_Menu_Number", 2, pId, "#Jb_Menu_Counter_Item_2");
        MENU_ITEM(szMenu, iLen, "^n%L \w%L", pId, "#Jb_Menu_Number", 3, pId, "#Jb_Menu_Counter_Item_3");
        MENU_ITEM(szMenu, iLen, "^n%L \w%L", pId, "#Jb_Menu_Number", 4, pId, "#Jb_Menu_Counter_Item_4");
        MENU_ITEM(szMenu, iLen, "^n%L \w%L", pId, "#Jb_Menu_Number", 5, pId, "#Jb_Menu_Counter_Item_5");
    }
    MENU_ITEM(szMenu, iLen, "^n");

    if(g_bCounter)
    {
        bitsKeys |= KEY(7);

        MENU_ITEM(szMenu, iLen, "^n%L \y%L", pId, "#Jb_Menu_Number", 7, pId, "#Jb_Menu_Counter_Item_7");
    }
    else
    {
        MENU_ITEM(szMenu, iLen, "^n%L \d%L", pId, "#Jb_Menu_Number", 7, pId, "#Jb_Menu_Counter_Item_7");
    }
    MENU_ITEM(szMenu, iLen, "^n");

    MENU_ITEM(szMenu, iLen, "^n%L \w%L", pId, "#Jb_Menu_Number", 0, pId, "#Jb_Menu_Exit");

    SHOW_MENU(pId, bitsKeys, szMenu, MenuId_Counter);
}

public ShowMenu_Counter_Handler(const pId, const iKey)
{
	if(!IsConnected(pId)) return;

	switch(KEY_HANDLER(iKey))
	{
		case 1: Jb_StartCounter(3);
		case 2: Jb_StartCounter(5);
		case 3: Jb_StartCounter(10);
		case 4: Jb_StartCounter(20);
		case 5: Jb_StartCounter(30);
        case 7: Jb_RemoveCounter();
	}
}

public Task_CheckCounter()
{
    if(--g_iTimer > 0)
    {
        if(g_iTimer < 11)
        {
            new szSound[64];
            formatex(szSound, charsmax(szSound), "sound/jailbreak/counter/%d.wav", g_iTimer);

            UTIL_PlayWav(0, szSound);
        }
        
        PRINT_CENTER(0, "%L", LANG_PLAYER, "#Jb_Msg_Counter", g_iTimer);
    }
    else
    {
        g_bCounter = false;

        DisableHookJailBreak(g_iJBHook);

        UTIL_PlayWav(0, "sound/jailbreak/counter/0.wav");

        PRINT_CENTER(0, "%L", LANG_PLAYER, "#Jb_Msg_Counter_End");
    }
}

Jb_StartCounter(const iCount)
{
    if(g_bCounter)
        return;
    
    g_bCounter = true;

    remove_task(TASK_COUNTER);

    EnableHookJailBreak(g_iJBHook);

    jb_show_menu_simon(jb_get_simon_id(), .bSaved = true);

    set_task(1.0, "Task_CheckCounter", TASK_COUNTER, .flags = "a", .repeat = (g_iTimer = iCount + 1));
}

Jb_RemoveCounter()
{
    if(!g_bCounter)
        return;
    
    g_bCounter = false;

    remove_task(TASK_COUNTER);

    DisableHookJailBreak(g_iJBHook);

    UTIL_PlayWav(0, "sound/jailbreak/counter/reset.wav");

    PRINT_CENTER(0, "%L", LANG_PLAYER, "#Jb_Msg_Counter_Reset");
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