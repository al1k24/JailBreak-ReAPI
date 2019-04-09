/** Это незаконченный мод, который нуждается в доработке.

	Что требуется реализовать:
	- Система игр.
	- Меню зэка.
	- Система дуэлей.
	
	Благодарность Freedo.m, 81x08, Mistrick, Halyavshik за примеры определённых решений.
*/

#include amxmodx
#include fakemeta
#include hamsandwich
#include reapi
#include json

#include "jb\const.inc"
#include "jb\util.inc"

#define PLUGIN	"[JB] Core"
#define VERSION	"23.08.2018"
#define AUTHOR	"ALIK"

#define IUSER1_DOOR_KEY 120219941
#define IUSER1_BUYZONE_KEY 120219942

#define DEFAULT_ICON_COLOR "#00FF00"

/** Forward */
#define _FORWARD_EXECUTE(%0) Forward_Execute(g_aForward_%0, g_iForward_%0_ItemsNum)

/** Forward, pId, bPost */
#define _FORWARD_EXECUTE_PLAYER(%0,%1,%2) Forward_Execute_Player(g_aForward_%0, g_iForward_%0_ItemsNum, %1, %2)

/** pId, iTeam, bPost */
#define _FORWARD_EXECUTE_CHOOSETEAM(%1,%2,%3) Forward_Execute_ChooseTeam(%1, %2, %3)

/** FUNCTION NAME, pId */
#define _MENU_CALLBACK_SIMON(%0,%1) ShowMenu_Simon_%0(%1, g_iMenu_Page[%1])

/** FUNCTION NAME, pId, iMenuId */
#define _MENU_CALLBACK_PLAYERS(%0,%1,%2) ShowMenu_Players_%0(%1, g_iMenu_Page[%1], %2)

enum (+= 1000)
{
	TASK_PLAYER = 777,
	
	TASK_PLAYER_INFORMER,
	TASK_PLAYER_STATUS_ICON,
	TASK_PLAYER_BLOCK_PICKUP,
	
	TOTAL_PLAYER_TASKS,
	
	TASK_RESTART,
	TASK_FREE_DAY,
	TASK_CHOOSE_SIMON,
	
	TOTAL_TASKS
};

enum _:ENUM_DATA_POSITION
{
	Float:POSITION_X,
	Float:POSITION_Y
};
new Float:g_flPosition_Informer[33][ENUM_DATA_POSITION];

enum _:ENUM_DATA_CVARS
{
	CVAR_SHOP_B,
	CVAR_SHOP_N,
	CVAR_SHOP_V,
	
	CVAR_BLOCK_RADIO,
	CVAR_BLOCK_GUARD_FF,
	
	CVAR_TIME_SIMON,
	CVAR_TIME_RESTART,
	CVAR_TIME_FREE_DAY,
	CVAR_TIME_FREE_DAY_GAME,
	
	CVAR_MAX_MONEY,

	CVAR_MIN_GUARD,

	CVAR_RATIO_GUARD_TO_PRISONER,
	
	/** [ Не менять ]  --> */
	CVAR_INT_END,
	/** [ Не менять ] <-- */
	
	CVAR_INFORMER_INFO_HEX[ENUM_DATA_COLORS]
};
new g_iCvar[ENUM_DATA_CVARS]; 
	
	/** CVAR_ */
	#define CVAR(%0) g_iCvar[CVAR_%0]

new g_iCvarId[ENUM_DATA_CVARS];

new g_iCvarId_Restart;
	
enum _:ENUM_DATA_FCVARS
{
	Float:FCVAR_TIME_UPDATE_INFORMER,

	/** [ Не менять ]  --> */
	CVAR_FLOAT_END,
	/** [ Не менять ] <-- */

	FCVAR_INFORMER_INFO_1[ENUM_DATA_POSITION],
	FCVAR_INFORMER_INFO_2[ENUM_DATA_POSITION]
};
new Float:g_flCvar[ENUM_DATA_FCVARS];
	
	/** FCVAR_ */
	#define FCVAR(%0) g_flCvar[FCVAR_%0]

new g_iflCvarId[ENUM_DATA_FCVARS];

enum _:ENUM_DATA_INFORMER
{
	INFORMER_1,
	INFORMER_2
};
new g_iSyncObject_Informer[ENUM_DATA_INFORMER];

new bool:g_bInformer[33];

enum _:ENUM_DATA_FAKEMETA
{
	FM_KVD,
	FM_SPAWN
};
new g_iFmHook[ENUM_DATA_FAKEMETA];
	
	/** FM_ */
	#define FM_FORWARD(%0) g_iFmHook[%0]

enum _:ENUM_DATA_FORWARD_OLD
{
	FORWARD_MAIN_MENU_OPEN,
	FORWARD_MAIN_MENU_ITEM_SELECT,

	FORWARD_SIMON_MENU_OPEN,
	FORWARD_PLAYERS_MENU_OPEN,
	FORWARD_PLAYERS_MENU_LOAD
};
new g_iFwdHook[ENUM_DATA_FORWARD_OLD];
	
	/** FORWARD_ */
	#define FORWARD(%0) g_iFwdHook[%0]

enum _:ENUM_DATA_FORWARD
{
	AI_FORWARD_ID,

	bool:AI_FORWARD_B_POST,
	bool:AI_FORWARD_B_DISABLE
};
new Array:g_aForward,
	
	g_iForward_ItemsNum;

new Array:g_aForward_RestartStart, Array:g_aForward_RestartEnd,
	
	Array:g_aForward_RoundStart, Array:g_aForward_RoundEnd,
	
	Array:g_aForward_Last, Array:g_aForward_ChooseTeam, 

	Array:g_aForward_FreeDayStart, Array:g_aForward_FreeDayEnd,
	
	Array:g_aForward_PlayerBecomeFree, Array:g_aForward_PlayerResetFree,

	Array:g_aForward_PlayerBecomeWanted, Array:g_aForward_PlayerResetWanted,

	Array:g_aForward_PlayerBecomeSimon, Array:g_aForward_PlayerBecomeLast;

new g_iForward_RestartStart_ItemsNum, g_iForward_RestartEnd_ItemsNum,
	
	g_iForward_RoundStart_ItemsNum, g_iForward_RoundEnd_ItemsNum,

	g_iForward_Last_ItemsNum, g_iForward_ChooseTeam_ItemsNum,

	g_iForward_FreeDayStart_ItemsNum, g_iForward_FreeDayEnd_ItemsNum,
	
	g_iForward_PlayerBecomeFree_ItemsNum, g_iForward_PlayerResetFree_ItemsNum,

	g_iForward_PlayerBecomeWanted_ItemsNum, g_iForward_PlayerResetWanted_ItemsNum,

	g_iForward_PlayerBecomeSimon_ItemsNum, g_iForward_PlayerBecomeLast_ItemsNum;

enum _:ENUM_DATA_MAIN_MENU
{
	AI_MAIN_MENU_SPACE,

	AI_MAIN_MENU_NAME[64],
	AI_MAIN_MENU_INFO[64],

	MenuItem:AI_MAIN_MENU_POSITION
};
new Array:g_aMainMenu;

enum _:ENUM_DATA_SIMON_MENU
{
	AI_SIMON_MENU_ID,
	AI_SIMON_MENU_FLAG,
	AI_SIMON_MENU_LIMIT,

    AI_SIMON_MENU_NAME[64],
	AI_SIMON_MENU_INFO[64]
};
new Array:g_aSimonMenu,
	
	g_iSimonMenu_ItemsNum, g_iSimonMenu_Limit[33][MAX_MENU_ITEMS];

new Array:g_aPlayersMenu,
	
	g_iPlayersMenu_ItemsNum;

new g_iPlayersMenu_ItemId[33];
	
new g_iForward_Result;

new g_bFix_TeamMenu[33];

new Trie:g_tRemoveEnt,

	g_iRemoveEnt_ItemsNum;

new Trie:g_tBlockMsg,
	
	g_iBlockMsg_ItemsNum;

new Trie:g_tSteamId;

new TeamName:g_iTeam[33];

new g_iMoney[32];

new g_bAlive[33],
	
	g_iAliveNum[TeamName];

new g_iPlayersNum[TeamName];

enum _:ENUM_DATA_USER
{
	USER_SIMON,

	USER_LAST,
	USER_DUEL_T,
	USER_DUEL_CT
};
new g_iUser[ENUM_DATA_USER];

	/** USER_ */
	#define USER(%0) g_iUser[%0]

	/** pId, USER_ */
	#define IsUser(%0,%1) (bool:(%0 == g_iUser[%1]))

new bool:g_bFree[33];

	/** pId */
	#define IsFree(%1) g_bFree[%1]

new bool:g_bFreeDayStarted;
	
	/** NULL */
	#define IsFreeDayStarted() g_bFreeDayStarted

new bool:g_bWanted[33];

	/** pId */
	#define IsWanted(%1) g_bWanted[%1]
	
enum _:ENUM_DATA_DUEL_STATUS
{
	DUEL_STATUS_NONE,
	DUEL_STATUS_READY,
	DUEL_STATUS_START
};

enum _: ENUM_DATA_DUEL
{
	DUEL_TYPE,
	DUEL_STATUS,
	DUEL_ATTACK,

	DUEL_GUARD_ID,
	DUEL_PRISONER_ID,
	
	DUEL_GUARD_NAME[32],
	DUEL_PRISONER_NAME[32]
};
new g_iDuel[ENUM_DATA_DUEL];

	/** DUEL_ */
	#define DUEL(%0) g_iDuel[%0]

enum _:ENUM_DATA_LANG_INFORMER
{
	LANG_INFORMER_FREE_DAY,
	LANG_INFORMER_WANTED
};
new g_iLang_Informer[ENUM_DATA_LANG_INFORMER];

new const g_szLang_Informer[ENUM_DATA_LANG_INFORMER][2][32]=
{
	{ 	"#Jb_Hud_Informer_NotFree", 	"#Jb_Hud_Informer_HasFree" 		},
	{ 	"#Jb_Hud_Informer_NotWanted", 	"#Jb_Hud_Informer_HasWanted" 	}
}

new g_szLang_Names[ENUM_DATA_LANG_INFORMER][190];

enum _:ENUM_DATA_WEEK_DAYS
{
	WEEK_DAY_MONDAY = 1,
	WEEK_DAY_TUESDAY,
	WEEK_DAY_WEDNESDAY,
	WEEK_DAY_THURSDAY,
	WEEK_DAY_FRIDAY,
	WEEK_DAY_SATURDAY,
	WEEK_DAY_SUNDAY
};
new g_iWeekDay;

	/** WEEK_DAY_ */
	#define IsWeekDay(%0) (bool:(g_iWeekDay == %0))

new g_iDay;

new DayMode:g_iDayMode;

	/** DAY_MODE_ */
	#define IsDayMode(%0) (bool:(g_iDayMode == %0))

new g_iRound;

	/** ROUND_ */
	#define IsRound(%0) (bool:(g_iRound == %0))

	/** NULL */
	#define IsRestart() (bool:(g_iRound == ROUND_RESTART))

new g_szWeekDay[32];

new Array:g_aDoor,
	
	g_iDoor_ItemsNum;

new Trie:g_tButton;

new bool:g_bDoorStatus;

	/** NULL */
	#define IsDoorOpened() g_bDoorStatus

	/** NULL */
	#define IsDoorClosed() !g_bDoorStatus

new g_iTimer_Restart, g_iTimer_ChooseSimon, g_iTimer_FreeDay;

new g_szInformer_Round[64], g_szInformer_SimonName[32];

new g_szSimonName[32];

enum _:TOTAL_ICON_TYPES
{
	ICON_HIDE,
	ICON_SHOW,
	ICON_FLASH
};
new g_iIcon_BuyZoneColor[ENUM_DATA_COLORS];

new VoiceSpeak:g_iVoiceSpeak;

new bool:g_bVoice[33];

	/** pId */
	#define IsVoice(%1) g_bVoice[%1]

new g_szMenuItem[64], g_szMenuItem_Info[64];

new bool:g_bBlockMsg_Pickup[33];

new bool:g_bHide_PlayerInfo[33];

new bool:g_bBlockEvent_StatusValue;

new Trie:g_tSound;

new HookChain:g_iRhHook_DropClient;

enum _:ENUM_DATA_SEX
{
	SEX_MALE,
	SEX_FEMALE
};
new g_iSex[33];

new g_iMenu_Page[33], g_iMenu_Target[33][32];

	/** pId, iKey, iRatio */
	#define GetMenuItemTarget(%1,%2,%3) (g_iMenu_Target[%1][(g_iMenu_Page[%1] * %3) + %2])

//MENU ID
#define MenuId_Team "ShowMenu_Team"
#define MenuId_Main "ShowMenu_Main"
#define MenuId_Simon "ShowMenu_Simon"
#define MenuId_Players "ShowMenu_Players"

/** [ `plugin_` ] 
----------------------------------------------------------------------------------------------------------------------------------------------------*/
#define DEF_DEBUG
#if defined DEF_DEBUG

	#undef DEBUG
	#undef DEBUG_LOG

	#include "jb\debug.inc"

#endif

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	FmHook_Init();

	ClCmd_Init();
	ClCmdHook_Init();
	EventHook_Init();
	MessageHook_Init();

	Forward_Init();
	ShowMenu_Init();
	
	RGHook_Init();
	RHHook_Init();
	HamHook_Init();

	Door_Init();
	Cvar_Init();

	register_dictionary("Jb_Core.txt");

	#if defined DEF_DEBUG

		Debug_Init();

	#endif
}

Cvar_Init()
{
	/** CVAR_ */
	g_iCvarId[CVAR_TIME_SIMON] = register_cvar("Jb_Core_Time_ChooseSimon", "10");
	g_iCvarId[CVAR_TIME_RESTART] = register_cvar("Jb_Core_Time_RestartGame", "30");

	g_iCvarId[CVAR_TIME_FREE_DAY] = register_cvar("Jb_Core_Time_FreeDay", "240");
	g_iCvarId[CVAR_TIME_FREE_DAY_GAME] = register_cvar("Jb_Core_Time_FreeDayGame", "480");
	
	g_iCvarId[CVAR_BLOCK_RADIO] = register_cvar("Jb_Core_Block_Radio", "1");
	g_iCvarId[CVAR_BLOCK_GUARD_FF] = register_cvar("Jb_Core_Block_GuardFrendlyFire", "1");
	
	g_iCvarId[CVAR_SHOP_B] = register_cvar("Jb_Core_Shop_B", "0");
	g_iCvarId[CVAR_SHOP_V] = register_cvar("Jb_Core_Shop_V", "0");
	g_iCvarId[CVAR_SHOP_N] = register_cvar("Jb_Core_Shop_N", "0");

	g_iCvarId[CVAR_MAX_MONEY] = register_cvar("Jb_Core_Max_Money", "50000");

	g_iCvarId[CVAR_MIN_GUARD] = register_cvar("Jb_Core_Min_Guard", "1");
	
	g_iCvarId[CVAR_RATIO_GUARD_TO_PRISONER] = register_cvar("Jb_Core_Ratio_GuardToPrisoner", "4");

	g_iCvarId[CVAR_INFORMER_INFO_HEX] = register_cvar("Jb_Core_Informer_Info_Hex", "#664500");
	
	/* Стандартные квары **/
	g_iCvarId_Restart = get_cvar_pointer("sv_restart");
	
	/** FCVAR_ */
	g_iflCvarId[FCVAR_TIME_UPDATE_INFORMER] = _:register_cvar("Jb_Core_Time_UpdateInformer", "1.0");
	
	g_iflCvarId[FCVAR_INFORMER_INFO_1][POSITION_X] = _:register_cvar("Jb_Core_Informer_Info_X_1", "0.01");
	g_iflCvarId[FCVAR_INFORMER_INFO_1][POSITION_Y] = _:register_cvar("Jb_Core_Informer_Info_Y_1", "0.27");
	
	g_iflCvarId[FCVAR_INFORMER_INFO_2][POSITION_X] = _:register_cvar("Jb_Core_Informer_Info_X_2", "0.22");
	g_iflCvarId[FCVAR_INFORMER_INFO_2][POSITION_Y] = _:register_cvar("Jb_Core_Informer_Info_Y_2", "0.01");

	/* Остальные */
	g_iIcon_BuyZoneColor = UTIL_HexToRgb(DEFAULT_ICON_COLOR);

	g_iSyncObject_Informer[INFORMER_1] = CreateHudSyncObj();
	g_iSyncObject_Informer[INFORMER_2] = CreateHudSyncObj();
}

public plugin_cfg()
{
	new szDir[32]; GET_DIR(szDir);
	server_cmd("exec %s/jailbreak/Core.cfg", szDir);

	set_task(0.1, "Task_LoadCvars");
}

public plugin_natives()
{
	Native_Init();
}

public plugin_precache()
{
	g_tButton = TrieCreate();
	g_tSteamId = TrieCreate();
	g_tBlockMsg = TrieCreate();
	g_tRemoveEnt = TrieCreate();

	g_tSound = TrieCreate();

	g_aMainMenu = ArrayCreate(ENUM_DATA_MAIN_MENU);
	g_aSimonMenu = ArrayCreate(ENUM_DATA_SIMON_MENU);

	g_aPlayersMenu = ArrayCreate(.reserved = 1);

	g_aForward = ArrayCreate(ENUM_DATA_FORWARD);

	g_aForward_Last = ArrayCreate(.reserved = 1);
	g_aForward_ChooseTeam = ArrayCreate(.reserved = 1);

	g_aForward_PlayerBecomeLast = ArrayCreate(.reserved = 1);
	g_aForward_PlayerBecomeFree = ArrayCreate(.reserved = 1);
	g_aForward_PlayerBecomeSimon = ArrayCreate(.reserved = 1);
	g_aForward_PlayerBecomeWanted = ArrayCreate(.reserved = 1);

	g_aForward_PlayerResetFree = ArrayCreate(.reserved = 1);
	g_aForward_PlayerResetWanted = ArrayCreate(.reserved = 1);
	
	g_aForward_RoundEnd = ArrayCreate(.reserved = 1);
	g_aForward_RoundStart = ArrayCreate(.reserved = 1);
	
	g_aForward_RestartEnd = ArrayCreate(.reserved = 1);
	g_aForward_RestartStart = ArrayCreate(.reserved = 1);
	
	g_aForward_FreeDayEnd = ArrayCreate(.reserved = 1);
	g_aForward_FreeDayStart = ArrayCreate(.reserved = 1);

	for(new i = 0, iCount = 9, aMainMenu[ENUM_DATA_MAIN_MENU]; i < iCount; i++)
	{
		ArrayPushArray(g_aMainMenu, aMainMenu);
	}
	
	set_entvar(rg_create_entity("func_buyzone"), var_iuser1, IUSER1_BUYZONE_KEY);
	
	JSON_Precache();
	FmHook_Precache();
}

Door_Init()
{
	g_aDoor = ArrayCreate();

	new iEnt[2], Float: vecOrigin[3], szClassName[32], szTargetName[32];

	while((iEnt[0] = rg_find_ent_by_class(iEnt[0], "info_player_deathmatch")))
	{
		get_entvar(iEnt[0], var_origin, vecOrigin);

		while((iEnt[1] = engfunc(EngFunc_FindEntityInSphere, iEnt[1], vecOrigin, 200.0)))
		{
			if(!is_entity(iEnt[1]))
				continue;
			
			get_entvar(iEnt[1], var_classname, szClassName, charsmax(szClassName));

			if(szClassName[5] != 'd' && szClassName[6] != 'o' && szClassName[7] != 'o' && szClassName[8] != 'r')
				continue;
			
			if(get_entvar(iEnt[1], var_iuser1) == IUSER1_DOOR_KEY)
				continue;
			
			get_entvar(iEnt[1], var_targetname, szTargetName, charsmax(szTargetName));

			if(TrieKeyExists(g_tButton, szTargetName))
			{
				ArrayPushCell(g_aDoor, iEnt[1]);
				
				set_entvar(iEnt[1], var_iuser1, IUSER1_DOOR_KEY);

				UTIL_SetKVD(iEnt[1], szClassName, "wait", "-1");
				UTIL_SetKVD(iEnt[1], szClassName, "spawnflags", "0");
			}
		}
	}

	g_iDoor_ItemsNum = ArraySize(g_aDoor);

	TrieDestroy(g_tButton);
}

/** [ `Froward_` ] 
----------------------------------------------------------------------------------------------------------------------------------------------------*/
Forward_Init()
{
	FORWARD(FORWARD_MAIN_MENU_OPEN) = CreateMultiForward("jb_main_menu_opened", ET_CONTINUE, FP_CELL, FP_CELL);
	FORWARD(FORWARD_MAIN_MENU_ITEM_SELECT) = CreateMultiForward("jb_main_menu_item_selected", ET_CONTINUE, FP_CELL, FP_CELL);

	FORWARD(FORWARD_SIMON_MENU_OPEN) = CreateMultiForward("jb_simon_menu_opened", ET_CONTINUE, FP_CELL, FP_CELL);

	FORWARD(FORWARD_PLAYERS_MENU_LOAD) = CreateMultiForward("jb_players_menu_loaded", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL);
	FORWARD(FORWARD_PLAYERS_MENU_OPEN) = CreateMultiForward("jb_players_menu_opened", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL);
}

Forward_Execute(const Array:aArray, const iArraySize)
{
	if(!iArraySize) return;
	
	for(new i = 0, aForward[ENUM_DATA_FORWARD], iItem; i < iArraySize; i++)
	{
		iItem = ArrayGetCell(aArray, i);

		ArrayGetArray(g_aForward, iItem, aForward);

		if(aForward[AI_FORWARD_ID] == _:INVALID_HOOKJAILBREAK)
			continue;

		if(aForward[AI_FORWARD_B_DISABLE])
			continue;

		ExecuteForward(aForward[AI_FORWARD_ID], g_iForward_Result);
	}
}

Forward_Execute_Player(const Array:aArray, const iArraySize, const pId, const bool:bPost = false)
{
	if(!iArraySize) return JB_CONTINUE;

	new bool:bBlock = false;
	for(new i = 0, aForward[ENUM_DATA_FORWARD], iItem; i < iArraySize; i++)
	{
		iItem = ArrayGetCell(aArray, i);

		ArrayGetArray(g_aForward, iItem, aForward);

		if(aForward[AI_FORWARD_ID] == _:INVALID_HOOKJAILBREAK)
			continue;

		if(aForward[AI_FORWARD_B_DISABLE] || aForward[AI_FORWARD_B_POST] != bPost)
			continue;

		ExecuteForward(aForward[AI_FORWARD_ID], g_iForward_Result, pId);
		
		if(g_iForward_Result == JB_HANDLED)
		{
			bBlock = true; break;
		}
	}

	return bBlock ? JB_HANDLED : JB_CONTINUE;
}

Forward_Execute_ChooseTeam(const pId, const TeamName:iTeam, const bool:bPost = false)
{
	if(!g_iForward_ChooseTeam_ItemsNum)
		return JB_CONTINUE;

	new bool:bBlock = false;
	for(new i = 0, aForward[ENUM_DATA_FORWARD], iItem; i < g_iForward_ChooseTeam_ItemsNum; i++)
	{
		iItem = ArrayGetCell(g_aForward_ChooseTeam, i);

		ArrayGetArray(g_aForward, iItem, aForward);

		if(aForward[AI_FORWARD_ID] == _:INVALID_HOOKJAILBREAK)
			continue;

		if(aForward[AI_FORWARD_B_DISABLE] || aForward[AI_FORWARD_B_POST] != bPost)
			continue;

		ExecuteForward(aForward[AI_FORWARD_ID], g_iForward_Result, pId, iTeam);
		
		if(g_iForward_Result == JB_HANDLED)
		{
			bBlock = true; break;
		}
	}

	return bBlock ? JB_HANDLED : JB_CONTINUE;
}

Forward_Execute_Last(const pId)
{
	if(!g_iForward_Last_ItemsNum)
		return JB_CONTINUE;

	new bool:bBlock = false;
	for(new i = 0, aForward[ENUM_DATA_FORWARD], iItem; i < g_iForward_Last_ItemsNum; i++)
	{
		iItem = ArrayGetCell(g_aForward_Last, i);

		ArrayGetArray(g_aForward, iItem, aForward);

		if(aForward[AI_FORWARD_ID] == _:INVALID_HOOKJAILBREAK)
			continue;

		ExecuteForward(aForward[AI_FORWARD_ID], g_iForward_Result, pId);
	
		if(g_iForward_Result == JB_HANDLED)
		{
			bBlock = true; break;
		}
	}

	return bBlock ? JB_HANDLED : JB_CONTINUE;
}


/** [ `client_` ] 
----------------------------------------------------------------------------------------------------------------------------------------------------*/
public client_putinserver(pId)
{
	g_bInformer[pId] = true;
	
	g_flPosition_Informer[pId][POSITION_X] = g_flCvar[FCVAR_INFORMER_INFO_1][POSITION_X];
	g_flPosition_Informer[pId][POSITION_Y] = g_flCvar[FCVAR_INFORMER_INFO_1][POSITION_Y];

	g_iSex[pId] = 0;
	g_iMoney[pId] = 0;

	if(!IsRound(ROUND_RESTART) && TrieKeyExists(g_tSteamId, UTIL_GetAuthId(pId)))
	{
		set_member(pId, m_iNumSpawns, 1);
	}

	for(new i = 0, aSimonMenu[ENUM_DATA_SIMON_MENU]; i < g_iSimonMenu_ItemsNum; i++)
	{
		ArrayGetArray(g_aSimonMenu, i, aSimonMenu);
		
		g_iSimonMenu_Limit[pId][i] = aSimonMenu[AI_SIMON_MENU_LIMIT];
	}

	set_task(FCVAR(TIME_UPDATE_INFORMER), "Task_UpdateInformer", pId + TASK_PLAYER_INFORMER, .flags = "b");
}

public client_disconnected(pId)
{
	g_bFix_TeamMenu[pId] = false;

	g_bBlockMsg_Pickup[pId] = false;

	g_bHide_PlayerInfo[pId] = false;
	
	g_iPlayersMenu_ItemId[pId] = ITEM_NULL;

	g_bVoice[pId] = false;

	if(g_bAlive[pId])
	{
		g_iAliveNum[g_iTeam[pId]]--;

		g_bAlive[pId] = false;
	}

	if(g_iTeam[pId] != TEAM_UNASSIGNED)
	{
		g_iPlayersNum[g_iTeam[pId]]--;

		g_iTeam[pId] = TEAM_UNASSIGNED;
	}
	TrieSetCell(g_tSteamId, UTIL_GetAuthId(pId), 1);

	if(IsUser(pId, USER_SIMON))
	{
		Jb_ResetSimon();
	}

	if(IsUser(pId, USER_LAST))
	{
		Jb_ResetLast();
	}

	if(IsWanted(pId))
	{
		Jb_ResetWantedPlayer(pId);
	}
	else if(IsFree(pId))
	{
		Jb_ResetFreePlayer(pId);
	}

	for(new i = TASK_PLAYER + 1000; i < TOTAL_PLAYER_TASKS; i += 1000)
	{
		remove_task(pId + i);
	}
}

/** [ `ClCmdHook_` ] 
----------------------------------------------------------------------------------------------------------------------------------------------------*/
ClCmdHook_Init()
{
	register_clcmd("jointeam", "ClCmdHook_Block");
	register_clcmd("joinclass", "ClCmdHook_Block");

	register_clcmd("buy", "ClCmdHook_Buy");
	register_clcmd("client_buy_open", "ClCmdHook_BuyVGUI");

	register_clcmd("menuselect", "ClCmdHook_MenuSelect");
	register_clcmd("nightvision", "ClCmdHook_Nightvision");
}

public ClCmdHook_Block(const pId)
{
	return PLUGIN_HANDLED;
}

public ClCmdHook_MenuSelect(const pId)
{
	Jb_UpdateInformer_Down(pId);
	
	UTIL_PlaySound(pId, "menu_click");
}

public ClCmdHook_Nightvision(const pId)
{
	switch(get_member(pId, m_iTeam))
	{
		case TEAM_PRISONER:
		{
			if(IsUser(pId, USER_LAST))
			{
				//Last Menu

				return PLUGIN_HANDLED;
			}
		}
		case TEAM_GUARD:
		{
			if(IsUser(pId, USER_SIMON))
			{
				_MENU_CALLBACK_SIMON(New, pId);
				
				return PLUGIN_HANDLED;
			}
		}
	}
	
	return PLUGIN_CONTINUE;
}

public ClCmdHook_Buy(const pId)
{
	if(!CVAR(SHOP_B)) return PLUGIN_CONTINUE;
	
	DEBUG_MSG(pId, "**** BUY !");

	return PLUGIN_HANDLED;
}

public ClCmdHook_BuyVGUI(const pId)
{
	if(!CVAR(SHOP_B)) return PLUGIN_CONTINUE;
	
	message_begin(MSG_ONE, MsgId_BuyClose, _, pId);
	message_end();

	DEBUG_MSG(pId, "**** BUY VGUI !");

	return PLUGIN_HANDLED;
}


/** [ `ClCmd_` ] 
----------------------------------------------------------------------------------------------------------------------------------------------------*/
ClCmd_Init()
{
	register_clcmd("say /team", "ClCmd_TeamMenu");
	register_clcmd("say /simon", "ClCmd_Simon");
}

public ClCmd_TeamMenu(const pId)
{
	ShowMenu_Team(pId);
}

public ClCmd_Simon(const pId)
{
	if(!IsRound(ROUND_START))
		return;

	if(!IsAlive(pId) || !IsTeam(pId, TEAM_GUARD))
		return;
	
	Jb_SetSimon(pId);
}


/** [ `EventHook_` ] 
----------------------------------------------------------------------------------------------------------------------------------------------------*/
EventHook_Init()
{
	register_event("ResetHUD", "EventHook_ResetHUD", "be", "1=2", "2!0");
	register_event("StatusIcon", "EventHook_StatusIconShow", "be", "1=1");
	register_event("StatusValue", "EventHook_StatusValueShow", "be", "1=2", "2!0");
}

public EventHook_ResetHUD(const pId)
{
	message_begin(MSG_ONE, MsgId_Money, _, pId);
	{
		write_long(g_iMoney[pId]);
		write_byte(0);
	}
	message_end();
}

public EventHook_StatusIconShow(pId)
{
	if(CVAR(SHOP_B))
	{
		UTIL_StatusIcon(pId, "buyzone", g_iIcon_BuyZoneColor, ICON_SHOW);
	}
}

public EventHook_StatusValueShow(pId)
{
	static iPlayer; iPlayer = read_data(2);

	if(g_bBlockEvent_StatusValue || g_bHide_PlayerInfo[iPlayer])
		return PLUGIN_HANDLED;

	static szMessage[128];
	formatex
	(
		szMessage, charsmax(szMessage), "%L", pId, "#Jb_StatusMsg_EnemyInfo", 
		floatround(get_entvar(iPlayer, var_health)), "%%", g_iMoney[iPlayer]
	);

	UTIL_StatusText(pId, szMessage);

	return PLUGIN_CONTINUE;
}


/** [ `MessageHook_` ] 
----------------------------------------------------------------------------------------------------------------------------------------------------*/
MessageHook_Init()
{
	register_message(MsgId_Money, "MessageHook_Money");
	register_message(MsgId_TextMsg, "MessageHook_TextMsg");

	register_message(MsgId_WeapPickup, "MessageHook_WeapPickup");
	register_message(MsgId_AmmoPickup, "MessageHook_AmmoPickup");
}

public MessageHook_Money(const iMsgId, const iMsgDest, const pId)
{
	return PLUGIN_HANDLED;
}

public MessageHook_WeapPickup(const iMsgId, const iMsgDest, const pId)
{
	return g_bBlockMsg_Pickup[pId] ? PLUGIN_HANDLED : PLUGIN_CONTINUE;
}

public MessageHook_AmmoPickup(const iMsgId, const iMsgDest, const pId)
{
	return g_bBlockMsg_Pickup[pId] ? PLUGIN_HANDLED : PLUGIN_CONTINUE;
}

public MessageHook_TextMsg(const iMsgId, const iMsgDest, const pId)
{
	static szArg2[32];
	get_msg_arg_string(2, szArg2, charsmax(szArg2));

	return TrieKeyExists(g_tBlockMsg, szArg2) ? PLUGIN_HANDLED : PLUGIN_CONTINUE;
}


/** [ `RGHook_` ] 
----------------------------------------------------------------------------------------------------------------------------------------------------*/
RHHook_Init()
{
	DisableHookChain((g_iRhHook_DropClient = RegisterHookChain(RH_SV_DropClient, "RHHook_SV_DropClient", true)));
}

public RHHook_SV_DropClient(const pId, bool:bCrash, const szFormat[])
{
	#pragma unused bCrash, szFormat

	if(IsRound(ROUND_START) && IsTeam(pId, TEAM_PRISONER))
	{
		Jb_CheckLast(.bMessage = true);
	}
}


/** [ `RGHook_` ] 
----------------------------------------------------------------------------------------------------------------------------------------------------*/
RGHook_Init()
{
	RegisterHookChain(RG_ShowVGUIMenu, "RGHook_ShowVGUIMenu", false);
	RegisterHookChain(RG_HandleMenu_ChooseTeam, "RGHook_HandleMenu_ChooseTeam", false);

	RegisterHookChain(RG_HandleMenu_ChooseTeam, "RGHook_HandleMenu_ChooseTeam_Post", true);
	
	RegisterHookChain(RG_CBasePlayer_Radio, "RGHook_CBasePlayer_Radio", false);
	RegisterHookChain(RG_CBasePlayer_Spawn, "RGHook_CBasePlayer_Spawn", false);
	RegisterHookChain(RG_CBasePlayer_Killed, "RGHook_CBasePlayer_Killed", false);
	RegisterHookChain(RG_CBasePlayer_TraceAttack, "RGHook_CBasePlayer_TraceAttack", false);
	RegisterHookChain(RG_CBasePlayer_GiveDefaultItems, "RGHook_CBasePlayer_GiveDefaultItems", false);
	
	RegisterHookChain(RG_RoundEnd, "RGHook_RoundEnd", true);
	RegisterHookChain(RG_CSGameRules_RestartRound, "RGHook_CSGameRules_RestartRound", true);

	RegisterHookChain(RG_CBasePlayer_Spawn, "RGHook_CBasePlayer_Spawn_Post", true);
	RegisterHookChain(RG_CBasePlayer_Killed, "RGHook_CBasePlayer_Killed_Post", true);
	RegisterHookChain(RG_CBasePlayer_SetClientUserInfoName, "RGHook_CBasePlayer_SetClientUserInfoName_Post", true);

	RegisterHookChain(RG_CSGameRules_CanPlayerHearPlayer, "RGHook_CSGameRules_CanPlayerHearPlayer", false);
}

public RGHook_ShowVGUIMenu(const pId, const VGUIMenu:iMenuType)
{
	if(iMenuType == VGUI_Menu_Team)
	{
		new TeamName:iTeam = get_member(pId, m_iTeam);

		if(iTeam == TEAM_SPECTATOR || iTeam == TEAM_UNASSIGNED)
		{
			if(g_bFix_TeamMenu[pId] < get_systime())
			{
				g_bFix_TeamMenu[pId] = get_systime(1);

				set_member(pId, m_bForceShowMenu, false);

				ShowMenu_Team(pId);
			}
		}
		else
		{
			ShowMenu_Main(pId);
		}
	}
	
	SetHookChainReturn(ATYPE_INTEGER, 0);

	return HC_SUPERCEDE;
}

public RGHook_CBasePlayer_GiveDefaultItems(const pId)
{
	rg_remove_all_items(pId);
	rg_give_item(pId, "weapon_knife");
	
	return HC_SUPERCEDE;
}

public RGHook_CBasePlayer_TraceAttack(const pId, const pIda, Float:flDamage)
{
	if(g_iDayMode == DAY_MODE_NORMAL || g_iDayMode == DAY_MODE_FREE_DAY)
	{
		//TODO: Duel status
		
		switch(get_member(pId, m_iTeam))
		{
			case TEAM_PRISONER:
			{
				if(IsTeam(pIda, TEAM_PRISONER))
				{
					SetHookChainReturn(ATYPE_INTEGER, 0);
					
					return HC_SUPERCEDE;
				}
			}
			case TEAM_GUARD:
			{
				switch(get_member(pIda, m_iTeam))
				{
					case TEAM_PRISONER:
					{
						Jb_SetWanted(pIda);
					}
					case TEAM_GUARD:
					{
						if(!CVAR(BLOCK_GUARD_FF))
						{
							SetHookChainReturn(ATYPE_INTEGER, 0);
							
							return HC_SUPERCEDE;
						}
					}
				}
			}
		}
	}
	return HC_CONTINUE;
}

public RGHook_HandleMenu_ChooseTeam(const pId, const MenuChooseTeam:iSlot)
{
	switch(iSlot)
	{
		case MenuChoose_CT:
		{
			if(!UTIL_IsValidGuardTeam())
			{
				SetHookChainArg(2, ATYPE_INTEGER, TEAM_UNASSIGNED);
			}
		}
		case MenuChoose_Spec:
		{
			if(IsAlive(pId))
			{
				dllfunc(DLLFunc_ClientKill, pId);
			}
		}
	}
}

public RGHook_HandleMenu_ChooseTeam_Post(const pId, const MenuChooseTeam:iSlot)
{
	if(g_iTeam[pId] != TEAM_UNASSIGNED)
	{
		g_iPlayersNum[g_iTeam[pId]]--;
	}

	switch(iSlot)
	{
        case MenuChoose_T, MenuChoose_CT: 	g_iTeam[pId] = TeamName:iSlot;
        case MenuChoose_Spec: 				g_iTeam[pId] = TEAM_SPECTATOR;
		default: 							g_iTeam[pId] = TEAM_UNASSIGNED;
    }

	if(g_iTeam[pId] != TEAM_UNASSIGNED)
	{
		g_iPlayersNum[g_iTeam[pId]]++;

		set_member(pId, m_bTeamChanged, false);
	}
}

public RGHook_CBasePlayer_Radio(const pId, const szMessageId[], const szMessageVerbose[], iPitch, bool:bShowIcon)
{
	#pragma unused pId, szMessageId, iPitch, bShowIcon
	
	if(szMessageVerbose[0] == EOS)
		return HC_CONTINUE;
	
	if(szMessageVerbose[3] == 114) // 'r'
		return HC_SUPERCEDE;
	
	return HC_CONTINUE;
}

public RGHook_CBasePlayer_Spawn(const pId)
{
	if(g_iTeam[pId] == TEAM_GUARD || g_iTeam[pId] == TEAM_PRISONER)
	{
		g_bBlockMsg_Pickup[pId] = true;

		set_task(0.1, "Task_ResetBlockPickupMessage", pId + TASK_PLAYER_BLOCK_PICKUP);
	}
}

public RGHook_CBasePlayer_Spawn_Post(const pId)
{
	if(!IsAlive(pId))
		return;

	if(!g_bAlive[pId])
	{
		g_bAlive[pId] = true;

		g_iAliveNum[g_iTeam[pId]]++;
	}
	UTIL_RoundTimeHide(pId);

	switch(get_member(pId, m_iTeam))
	{
		case TEAM_PRISONER:
		{
			if(USER(USER_LAST))
			{
				USER(USER_LAST) = 0;
			}
		}
		case TEAM_GUARD:
		{
			
		}
	}

	// UTIL_RoundTime(pId, 20, true);

	if(CVAR(SHOP_B))
	{
		set_task(0.1, "Task_SetStatusIcon", pId + TASK_PLAYER_STATUS_ICON);
	}
}

public RGHook_CBasePlayer_Killed(const pId, const pIda)
{
	if(!IsConnected(pId))
		return;

	if(g_bAlive[pId])
	{
		g_bAlive[pId] = false;

		g_iAliveNum[g_iTeam[pId]]--;
	}

	remove_task(pId + TASK_PLAYER_STATUS_ICON);

	if(IsUser(pId, USER_SIMON))
	{
		Jb_ResetSimon();
	}

	if(IsWanted(pId))
	{
		Jb_ResetWantedPlayer(pId);
	}
	else if(IsFree(pId))
	{
		Jb_ResetFreePlayer(pId);
	}
}

public RGHook_CBasePlayer_Killed_Post(const pId, const pIda)
{
	#pragma unused pIda

	if(!IsRound(ROUND_START) || !IsConnected(pId))
		return;

	Jb_CheckLast(.bMessage = true);
}

public RGHook_CBasePlayer_SetClientUserInfoName_Post(const pId, const szBuffer[], const szName[])
{
	#pragma unused szBuffer
	
	if(IsUser(pId, USER_SIMON))
	{
		formatex(g_szSimonName, charsmax(g_szSimonName), szName);

		g_szInformer_SimonName = g_szSimonName;
	}
}

public RGHook_CSGameRules_RestartRound()
{
	Jb_RoundStart();
}

public RGHook_RoundEnd()
{
	Jb_RoundEnd();
}

public RGHook_CSGameRules_CanPlayerHearPlayer(const iReceiver, const iSender)
{
	if(iReceiver == iSender)
		return HC_CONTINUE;
	
	static bool:bListen;
	
	if(IsVoice(iSender))
	{
		bListen = true;
	}
	else
	{
		bListen = true;

		switch(g_iVoiceSpeak)
		{
			case VOICE_SPEAK_GUARD:
			{
				if(IsTeam(iSender, TEAM_GUARD))
				{
					bListen = true;
				}
			}
			case VOICE_SPEAK_SIMON:
			{
				if(IsUser(iSender, USER_SIMON))
				{
					bListen = true;
				}
			}
		}
	}

	SetHookChainReturn(ATYPE_INTEGER, bListen);

	return HC_SUPERCEDE;
}


/** [ `HamHook_` ] 
----------------------------------------------------------------------------------------------------------------------------------------------------*/
HamHook_Init()
{
	for(new i = 0, szDoorClass[2][32] = {"func_door", "func_door_rotating"}; i < 2; i++)
	{
		RegisterHam(Ham_Use, szDoorClass[i], "HamHook_Use_Door", false);
		RegisterHam(Ham_Blocked, szDoorClass[i], "HamHook_Blocked_Door", false);
	}
}

public HamHook_Use_Door(const iEnt, const iCallerId, const iActivatorId)
{
	return (iCallerId != iActivatorId && get_entvar(iEnt, var_iuser1) == IUSER1_DOOR_KEY) ? HAM_SUPERCEDE : HAM_IGNORED;
}

public HamHook_Blocked_Door(const iBlockedId, const iBlockerId)
{
	if(IsPlayer(iBlockerId) && IsAlive(iBlockerId) && get_entvar(iBlockedId, var_iuser1) == IUSER1_DOOR_KEY)
	{
		ExecuteHamB(Ham_TakeDamage, iBlockerId, 0, 0, 9999.9, 0);
		
		return HAM_SUPERCEDE;
	}

	return HAM_IGNORED;
}


/** [ `FmHook_` ] 
----------------------------------------------------------------------------------------------------------------------------------------------------*/
FmHook_Init()
{
	if(g_iRemoveEnt_ItemsNum)
	{
		g_iRemoveEnt_ItemsNum = 0;

		TrieDestroy(g_tRemoveEnt);
		
		unregister_forward(FM_Spawn, FM_FORWARD(FM_SPAWN), true);
	}
	unregister_forward(FM_KeyValue, FM_FORWARD(FM_KVD), true);
}

FmHook_Precache()
{
	if(g_iRemoveEnt_ItemsNum)
	{
		FM_FORWARD(FM_SPAWN) = register_forward(FM_Spawn, "FmHook_Spawn_Post", true);
	}
	FM_FORWARD(FM_KVD) = register_forward(FM_KeyValue, "FmHook_KeyValue_Post", true);
}

public FmHook_Spawn_Post(const iEnt)
{
	if(!IsValid(iEnt)) return FMRES_IGNORED;

	new szClassName[32];
	get_entvar(iEnt, var_classname, szClassName, charsmax(szClassName));
	
	if(TrieKeyExists(g_tRemoveEnt, szClassName))
	{
		if(szClassName[5] == 'u' && get_entvar(iEnt, var_iuser1) == IUSER1_BUYZONE_KEY)
			return FMRES_IGNORED;

		set_entvar(iEnt, var_flags, get_entvar(iEnt, var_flags) | FL_KILLME);

		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

public FmHook_KeyValue_Post(const iEnt, const KVD_Handle)
{
	if(!is_entity(iEnt)) return FMRES_IGNORED;
	
	new szBuffer[32];
	get_kvd(KVD_Handle, KV_ClassName, szBuffer, charsmax(szBuffer));
	
	if((szBuffer[5] != 'b' || szBuffer[6] != 'u' || szBuffer[7] != 't') && (szBuffer[0] != 'b' || szBuffer[1] != 'u'|| szBuffer[2] != 't'))
		return FMRES_IGNORED;
	
	get_kvd(KVD_Handle, KV_KeyName, szBuffer, charsmax(szBuffer));

	if(szBuffer[0] != 't' || szBuffer[1] != 'a' || szBuffer[3] != 'g')
		return FMRES_IGNORED;
	
	get_kvd(KVD_Handle, KV_Value, szBuffer, charsmax(szBuffer));
	
	TrieSetCell(g_tButton, szBuffer, iEnt);
	
	return FMRES_HANDLED;
}

/** [ `Task_` ] 
----------------------------------------------------------------------------------------------------------------------------------------------------*/
public Task_LoadCvars()
{
	for(new i = 0; i < CVAR_INT_END; i++)
	{
		g_iCvar[i] = get_pcvar_num(g_iCvarId[i]);
	}

	new szColor[8];
	get_pcvar_string(g_iCvarId[CVAR_INFORMER_INFO_HEX], szColor, charsmax(szColor));
	
	g_iCvar[CVAR_INFORMER_INFO_HEX] = UTIL_HexToRgb(szColor);
	
	g_flCvar[FCVAR_TIME_UPDATE_INFORMER] = get_pcvar_float(_:g_iflCvarId[FCVAR_TIME_UPDATE_INFORMER]);
	
	for(new i = 0; i < ENUM_DATA_POSITION; i++)
	{
		g_flCvar[FCVAR_INFORMER_INFO_1][i] = get_pcvar_float(g_iflCvarId[FCVAR_INFORMER_INFO_1][i]);
		g_flCvar[FCVAR_INFORMER_INFO_2][i] = get_pcvar_float(g_iflCvarId[FCVAR_INFORMER_INFO_2][i]);
	}
	
	Jb_RestartGameStart();
}

public Task_ChooseSimon()
{
	if(--g_iTimer_ChooseSimon == 0)
	{
		formatex(g_szInformer_SimonName, charsmax(g_szInformer_SimonName), "%L", LANG_PLAYER, "#Jb_Hud_Informer_NoSimon");

		Jb_SetDayMode(DAY_MODE_FREE_DAY);
	}
	else
	{
		formatex
		(
			g_szInformer_SimonName, charsmax(g_szInformer_SimonName), "%L %L", 
			
			LANG_PLAYER, "#Jb_Hud_Informer_NoSimon", LANG_PLAYER, "#Jb_Hud_Informer_Timer", UTIL_FixTime(g_iTimer_ChooseSimon)
		);
	}
}

public Task_RestartGame()
{
	if(--g_iTimer_Restart == 0)
	{
		Jb_RestartEnd();
	}
	else
	{
		formatex
		(
			g_szInformer_Round, charsmax(g_szInformer_Round), "%L %L", 
			
			LANG_PLAYER, "#Jb_Hud_Informer_Restart", LANG_PLAYER, "#Jb_Hud_Informer_Timer", UTIL_FixTime(g_iTimer_Restart)
		);
	}
}

public Task_FreeDay()
{
	if(--g_iTimer_FreeDay == 0)
	{
		Jb_FreeDayEnd();
	}
	else
	{
		formatex
		(
			g_szInformer_Round, charsmax(g_szInformer_Round), "%L %L", 
			
			LANG_PLAYER, "#Jb_Hud_Informer_FreeDay", LANG_PLAYER, "#Jb_Hud_Informer_Timer", UTIL_FixTime(g_iTimer_FreeDay)
		);
	}
}

public Task_UpdateInformer(pId)
{
	if(pId > TASK_PLAYER_INFORMER) pId -= TASK_PLAYER_INFORMER;

	set_hudmessage
	(
		g_iCvar[CVAR_INFORMER_INFO_HEX][COLOR_R], g_iCvar[CVAR_INFORMER_INFO_HEX][COLOR_G], g_iCvar[CVAR_INFORMER_INFO_HEX][COLOR_B],
		g_flPosition_Informer[pId][POSITION_X], g_flPosition_Informer[pId][POSITION_Y], 0, 0.0, 0.8, 0.2, 0.2, -1
	);
	
	if(IsRound(ROUND_RESTART))
	{
		ShowSyncHudMsg(pId, g_iSyncObject_Informer[INFORMER_1], g_szInformer_Round);
	}
	else
	{
		if(IsWeekDay(WEEK_DAY_SATURDAY) || IsWeekDay(WEEK_DAY_SUNDAY))
		{
			ShowSyncHudMsg
			(
				pId, g_iSyncObject_Informer[INFORMER_1], 
				"\
					%L^n\
					%L\
				",
				
				pId, "#Jb_Hud_Informer_Day", g_iDay, g_szWeekDay,
				pId, "#Jb_Hud_Informer_Round", g_szInformer_Round
			);
		}
		else
		{
			ShowSyncHudMsg
			(
				pId, g_iSyncObject_Informer[INFORMER_1], 
				"\
					%L^n\
					%L^n\
					%L^n\
					%L^n\
					%L^n\
					\
					%L\
				",
				
				pId, "#Jb_Hud_Informer_Day", g_iDay, g_szWeekDay,
				pId, "#Jb_Hud_Informer_Round", g_szInformer_Round,
				pId, "#Jb_Hud_Informer_Simon", g_szInformer_SimonName,
				pId, "#Jb_Hud_Informer_PrisonerCount", g_iAliveNum[TEAM_PRISONER], g_iPlayersNum[TEAM_PRISONER],
				pId, "#Jb_Hud_Informer_GuardCount", g_iAliveNum[TEAM_GUARD], g_iPlayersNum[TEAM_GUARD],

				pId, g_szLang_Informer[LANG_INFORMER_WANTED][g_iLang_Informer[LANG_INFORMER_WANTED]], g_szLang_Names[LANG_INFORMER_WANTED]
			);
		}
	}
}

public Task_ResetBlockPickupMessage(pId)
{
	if(pId > TASK_PLAYER_BLOCK_PICKUP) pId -= TASK_PLAYER_BLOCK_PICKUP;

	g_bBlockMsg_Pickup[pId] = false;
}

public Task_SetStatusIcon(pId)
{
	if(pId > TASK_PLAYER_STATUS_ICON) pId -= TASK_PLAYER_STATUS_ICON;

	UTIL_StatusIcon(pId, "buyzone", g_iIcon_BuyZoneColor, ICON_SHOW);
}

/** [ `ShowMenu_` ] 
----------------------------------------------------------------------------------------------------------------------------------------------------*/
ShowMenu_Init()
{
	RegisterMenu(MenuId_Team, "ShowMenu_Team_Handler");
	RegisterMenu(MenuId_Main, "ShowMenu_Main_Handler");
	RegisterMenu(MenuId_Simon, "ShowMenu_Simon_Handler");
	RegisterMenu(MenuId_Players, "ShowMenu_Players_Handler");
}

ShowMenu_Main(const pId)
{
	Jb_UpdateInformer_Up(pId);
	
	static szMenu[512]; new iLen, bitsKeys = KEY(0);
	MENU_TITLE(szMenu, iLen, "%L^n", pId, "#Jb_Menu_Main_Title");
	
	for(new i = 0, iPosition = 0, iCount = 9, aMainMenu[ENUM_DATA_MAIN_MENU]; i < iCount; i++)
	{
		g_szMenuItem[0] = EOS;
		g_szMenuItem_Info[0] = EOS;

		ArrayGetArray(g_aMainMenu, i, aMainMenu);

		if(aMainMenu[AI_MAIN_MENU_NAME][0] == EOS && g_szMenuItem[0] == EOS)
			continue;

		iPosition = _:aMainMenu[AI_MAIN_MENU_POSITION];
		
		ExecuteForward(FORWARD(FORWARD_MAIN_MENU_OPEN), g_iForward_Result, pId, i);

		if(g_szMenuItem[0] != EOS)
		{
			if(g_szMenuItem_Info[0] != EOS)
			{
				switch(g_iForward_Result)
				{
					case JB_CONTINUE:
					{
						bitsKeys |= KEY(iPosition);
						
						MENU_ITEM(szMenu, iLen, "^n%L \w%s %s", pId, "#Jb_Menu_Number", iPosition, g_szMenuItem, g_szMenuItem_Info);
					}
					case JB_HANDLED:
					{
						MENU_ITEM(szMenu, iLen, "^n%L \d%s %s", pId, "#Jb_Menu_Number", iPosition, g_szMenuItem, g_szMenuItem_Info);
					}
				}
			}
			else
			{
				bitsKeys |= KEY(iPosition);
				
				if(aMainMenu[AI_MAIN_MENU_INFO][0] == EOS)
				{
					MENU_ITEM(szMenu, iLen, "^n%L \w%s", pId, "#Jb_Menu_Number", iPosition, g_szMenuItem);
				}
				else
				{
					MENU_ITEM(szMenu, iLen, "^n%L \w%s %L", pId, "#Jb_Menu_Number", iPosition, g_szMenuItem, pId, aMainMenu[AI_MAIN_MENU_INFO]);
				}
			}
		}
		else
		{
			if(g_szMenuItem_Info[0] != EOS)
			{
				switch(g_iForward_Result)
				{
					case JB_CONTINUE:
					{
						bitsKeys |= KEY(iPosition);
						
						MENU_ITEM(szMenu, iLen, "^n%L \w%L %s", pId, "#Jb_Menu_Number", iPosition, pId, aMainMenu[AI_MAIN_MENU_NAME], g_szMenuItem_Info);
					}
					case JB_HANDLED:
					{
						MENU_ITEM(szMenu, iLen, "^n%L \d%L %s", pId, "#Jb_Menu_Number", iPosition, pId, aMainMenu[AI_MAIN_MENU_NAME], g_szMenuItem_Info);
					}
				}
			}
			else
			{
				bitsKeys |= KEY(iPosition);
				
				if(aMainMenu[AI_MAIN_MENU_INFO][0] == EOS)
				{
					MENU_ITEM(szMenu, iLen, "^n%L \w%L", pId, "#Jb_Menu_Number", iPosition, pId, aMainMenu[AI_MAIN_MENU_NAME]);
				}
				else
				{
					MENU_ITEM(szMenu, iLen, "^n%L \w%L %L", pId, "#Jb_Menu_Number", iPosition, pId, aMainMenu[AI_MAIN_MENU_NAME], pId, aMainMenu[AI_MAIN_MENU_INFO]);
				}
			}
		}
		
		if(aMainMenu[AI_MAIN_MENU_SPACE] > 0)
		{
			for(new j = 0; j < aMainMenu[AI_MAIN_MENU_SPACE]; j++)
			{
				MENU_ITEM(szMenu, iLen, "^n");
			}
		}
	}
	
	MENU_ITEM(szMenu, iLen, "^n^n%L \w%L", pId, "#Jb_Menu_Number", 0, pId, "#Jb_Menu_Exit");
	
	SHOW_MENU(pId, bitsKeys, szMenu, MenuId_Main);
}

public ShowMenu_Main_Handler(const pId, const iKey)
{
	if(!IsConnected(pId) || KEY_HANDLER(iKey) == 0)
		return;

	ExecuteForward(FORWARD(FORWARD_MAIN_MENU_ITEM_SELECT), g_iForward_Result, pId, MenuItem:KEY_HANDLER(iKey));

	// switch(g_iForward_Result)
	// {
	// 	case JB_HANDLED: {}
	// 	case JB_CONTINUE: {}
	// }
}

ShowMenu_Team(const pId)
{
	if(!IsConnected(pId)) return;

	Jb_UpdateInformer_Up(pId);
	
	static szMenu[512]; new iLen, bitsKeys;
	MENU_TITLE(szMenu, iLen, "%L^n", pId, "#Jb_Menu_Team_Title");
	
	MENU_ITEM(szMenu, iLen, "%L^n", pId, "#Jb_Menu_Team_Title_Info", CVAR(RATIO_GUARD_TO_PRISONER));
	
	new TeamName:iTeam = get_member(pId, m_iTeam);

	// get_member_game(m_iNumCT)
	// get_member_game(m_iNumTerrorist)
	if(iTeam == TEAM_PRISONER)
	{
		MENU_ITEM(szMenu, iLen, "^n%L \d%L %L", pId, "#Jb_Menu_Number", 1, pId, "#Jb_Menu_Team_Item_1", pId, "#Jb_Menu_Selected_2");
	}
	else
	{
		bitsKeys |= KEY(1);

		MENU_ITEM(szMenu, iLen, "^n%L \w%L %L", pId, "#Jb_Menu_Number", 1, pId, "#Jb_Menu_Team_Item_1", pId, "#Jb_Menu_Cell", g_iPlayersNum[TEAM_PRISONER]);
	}

	
	if(iTeam == TEAM_GUARD)
	{
		MENU_ITEM(szMenu, iLen, "^n%L \d%L %L", pId, "#Jb_Menu_Number", 2, pId, "#Jb_Menu_Team_Item_2", pId, "#Jb_Menu_Selected_2");
	}
	else if(!UTIL_IsValidGuardTeam())
	{
		MENU_ITEM(szMenu, iLen, "^n%L \d%L %L", pId, "#Jb_Menu_Number", 2, pId, "#Jb_Menu_Team_Item_2", pId,"#Jb_Menu_Limit_3");
	}
	else
	{
		bitsKeys |= KEY(2);

		MENU_ITEM(szMenu, iLen, "^n%L \w%L %L %L", pId, "#Jb_Menu_Number", 2, pId, "#Jb_Menu_Team_Item_2", pId, "#Jb_Menu_Cell", g_iPlayersNum[TEAM_GUARD], pId, "#Jb_Menu_Team_Item_2_Info");
	}

	if(iTeam == TEAM_SPECTATOR)
	{
		MENU_ITEM(szMenu, iLen, "^n^n%L \d%L", pId, "#Jb_Menu_Number", 6, pId, "#Jb_Menu_Team_Item_6");
	}
	else
	{
		bitsKeys |= KEY(6);

		MENU_ITEM(szMenu, iLen, "^n^n%L \w%L", pId, "#Jb_Menu_Number", 6, pId, "#Jb_Menu_Team_Item_6");
	}
	
	if(IsPlayerJoined(pId))
	{
		bitsKeys |= KEY(0);

		MENU_ITEM(szMenu, iLen, "^n^n%L \w%L", pId, "#Jb_Menu_Number", 0, pId, "#Jb_Menu_Exit");
	}
	
	SHOW_MENU(pId, bitsKeys, szMenu, MenuId_Team);
}

public ShowMenu_Team_Handler(const pId, const iKey)
{
	if(!IsConnected(pId)) return;

	new TeamName:iTeam = TEAM_UNASSIGNED;
	switch(KEY_HANDLER(iKey))
	{
		case 1: iTeam = TEAM_PRISONER;
		case 2: iTeam = TEAM_GUARD;
		case 6: iTeam = TEAM_SPECTATOR;
	}

	if(iTeam == TEAM_UNASSIGNED)
		return;

	if(_FORWARD_EXECUTE_CHOOSETEAM(pId, iTeam, .bPost = false) == JB_HANDLED)
		return;

	switch(iTeam)
	{
		case TEAM_PRISONER:
		{
			rg_internal_cmd(pId, "jointeam", "1");
			rg_internal_cmd(pId, "joinclass", "5");
		}
		case TEAM_GUARD:
		{
			if(!UTIL_IsValidGuardTeam()) return;

			rg_internal_cmd(pId, "jointeam", "2");
			rg_internal_cmd(pId, "joinclass", "5");
		}
		case TEAM_SPECTATOR:
		{
			rg_internal_cmd(pId, "jointeam", "6");
		}
	}

	_FORWARD_EXECUTE_CHOOSETEAM(pId, iTeam, .bPost = true);
}

ShowMenu_Last(const pId)
{
	PRINT_CHAT(pId, "*** Last MEnu [2]");
}

ShowMenu_Simon_Next(const pId, &iPage)
{
	ShowMenu_Simon(pId, ++iPage);
}

ShowMenu_Simon_Back(const pId, &iPage)
{
	ShowMenu_Simon(pId, --iPage);
}

stock ShowMenu_Simon_Saved(const pId, const iPage)
{
	ShowMenu_Simon(pId, iPage);
}

ShowMenu_Simon_New(const pId, &iPage)
{
	ShowMenu_Simon(pId, iPage = 0);
}

ShowMenu_Simon(const pId, const iPage)
{
	new iItemsNum = g_iSimonMenu_ItemsNum;
	
	for(new i = 0; i < iItemsNum; i++)
	{
		g_iMenu_Target[pId][i] = i;
	}
	
	new iStart = min(iPage * 7, iItemsNum); 
	iStart -= (iStart % 7);
	
	g_iMenu_Page[pId] = iStart / 7;
	
	new iEnd = min(iStart + 7, iItemsNum);
	
	static szMenu[512]; new iLen, iPages = (iItemsNum / 7 + ((iItemsNum % 7) ? 1 : 0));
	switch(iPages)
	{
		case 0:
		{
			PRINT_CENTER(pId, "%L", pId, "#Jb_Msg_Error_NoItems_Simon"); return;
		}
		case 1:
		{
			MENU_TITLE(szMenu, iLen, "%L^n", pId, "#Jb_Menu_Simon_Title");
		}
		default:
		{
			MENU_TITLE(szMenu, iLen, "%L %L^n", pId, "#Jb_Menu_Simon_Title", pId, "#Jb_Menu_Numbers", iPage + 1, iPages);
		}
	}
	Jb_UpdateInformer_Up(pId);
	
	new bitsKeys = KEY(0);
	for(new i = iStart, iItem = 1, aSimonMenu[ENUM_DATA_SIMON_MENU], iItemId; i < iEnd; i++, iItem++)
	{
		g_szMenuItem[0] = EOS;
		g_szMenuItem_Info[0] = EOS;

		ArrayGetArray(g_aSimonMenu, (iItemId = g_iMenu_Target[pId][i]), aSimonMenu);

		ExecuteForward(FORWARD(FORWARD_SIMON_MENU_OPEN), g_iForward_Result, pId, iItemId);
		
		if(g_szMenuItem[0] != EOS)
		{
			if(g_szMenuItem_Info[0] != EOS)
			{
				if(g_iForward_Result == JB_CONTINUE)
				{
					if(aSimonMenu[AI_SIMON_MENU_FLAG] == -1)
					{
						switch(g_iSimonMenu_Limit[pId][iItemId])
						{
							case -1:
							{
								bitsKeys |= KEY(iItem);

								MENU_ITEM(szMenu, iLen, "^n%L \w%s %s", pId, "#Jb_Menu_Number", iItem, g_szMenuItem, g_szMenuItem_Info);
							}
							case 0:
							{
								MENU_ITEM(szMenu, iLen, "^n%L \d%s %L", pId, "#Jb_Menu_Number", iItem, g_szMenuItem, pId, "#Jb_Menu_Limit_3");
							}
							default:
							{
								bitsKeys |= KEY(iItem);
								
								MENU_ITEM(szMenu, iLen, "^n%L \w%s %s %L", pId, "#Jb_Menu_Number", iItem, g_szMenuItem, g_szMenuItem_Info, pId, "#Jb_Menu_Limit_1_1", g_iSimonMenu_Limit[pId][iItemId]);
							}
						}
					}
					else
					{
						if(IsFlag(pId, aSimonMenu[AI_SIMON_MENU_FLAG]))
						{
							switch(g_iSimonMenu_Limit[pId][iItemId])
							{
								case -1:
								{
									bitsKeys |= KEY(iItem);
									
									MENU_ITEM(szMenu, iLen, "^n%L \w%s", pId, "#Jb_Menu_Number", iItem, g_szMenuItem);
								}
								case 0:
								{
									MENU_ITEM(szMenu, iLen, "^n%L \d%s %L", pId, "#Jb_Menu_Number", iItem, g_szMenuItem, pId, "#Jb_Menu_Limit_3");
								}
								default:
								{
									bitsKeys |= KEY(iItem);
									
									MENU_ITEM(szMenu, iLen, "^n%L \w%s %L", pId, "#Jb_Menu_Number", iItem, g_szMenuItem, pId, "#Jb_Menu_Limit_1_1", g_iSimonMenu_Limit[pId][iItemId]);
								}
							}
						}
						else
						{
							MENU_ITEM(szMenu, iLen, "^n%L \d%s %L", pId, "#Jb_Menu_Number", iItem, g_szMenuItem, pId, "#Jb_Menu_Limit_2");
						}
					}
				}
				else
				{
					MENU_ITEM(szMenu, iLen, "^n%L \d%s %s", pId, "#Jb_Menu_Number", iItem, g_szMenuItem, g_szMenuItem_Info);
				}
			}
			else
			{
				bitsKeys |= KEY(iItem);
				
				if(aSimonMenu[AI_SIMON_MENU_INFO][0] == EOS)
				{
					MENU_ITEM(szMenu, iLen, "^n%L \w%s", pId, "#Jb_Menu_Number", iItem, g_szMenuItem);
				}
				else
				{
					MENU_ITEM(szMenu, iLen, "^n%L \w%s %L", pId, "#Jb_Menu_Number", iItem, g_szMenuItem, pId, aSimonMenu[AI_SIMON_MENU_INFO]);
				}
			}
		}
		else
		{
			if(g_szMenuItem_Info[0] != EOS)
			{
				if(g_iForward_Result == JB_CONTINUE)
				{
					if(aSimonMenu[AI_SIMON_MENU_FLAG] == -1)
					{
						switch(g_iSimonMenu_Limit[pId][iItemId])
						{
							case -1:
							{
								bitsKeys |= KEY(iItem);
								
								MENU_ITEM(szMenu, iLen, "^n%L \w%L %s", pId, "#Jb_Menu_Number", iItem, pId, aSimonMenu[AI_SIMON_MENU_NAME], g_szMenuItem_Info);
							}
							case 0:
							{
								MENU_ITEM(szMenu, iLen, "^n%L \d%L %L", pId, "#Jb_Menu_Number", iItem, pId, aSimonMenu[AI_SIMON_MENU_NAME], pId, "#Jb_Menu_Limit_3");
							}
							default:
							{
								bitsKeys |= KEY(iItem);
								
								MENU_ITEM(szMenu, iLen, "^n%L \w%L %s %L", pId, "#Jb_Menu_Number", iItem, pId, aSimonMenu[AI_SIMON_MENU_NAME], g_szMenuItem_Info, pId, "#Jb_Menu_Limit_1_1", g_iSimonMenu_Limit[pId][iItemId]);
							}
						}
					}
					else
					{
						if(IsFlag(pId, aSimonMenu[AI_SIMON_MENU_FLAG]))
						{
							
							switch(g_iSimonMenu_Limit[pId][iItemId])
							{
								case -1:
								{
									bitsKeys |= KEY(iItem);
									
									MENU_ITEM(szMenu, iLen, "^n%L \w%L %s", pId, "#Jb_Menu_Number", iItem, pId, aSimonMenu[AI_SIMON_MENU_NAME], g_szMenuItem_Info);
								}
								case 0:
								{
									MENU_ITEM(szMenu, iLen, "^n%L \d%L %L", pId, "#Jb_Menu_Number", iItem, pId, aSimonMenu[AI_SIMON_MENU_NAME], pId, "#Jb_Menu_Limit_3");
								}
								default:
								{
									bitsKeys |= KEY(iItem);
									
									MENU_ITEM(szMenu, iLen, "^n%L \w%L %s %L", pId, "#Jb_Menu_Number", iItem, pId, aSimonMenu[AI_SIMON_MENU_NAME], g_szMenuItem_Info, pId, "#Jb_Menu_Limit_1_1", g_iSimonMenu_Limit[pId][iItemId]);
								}
							}
						}
						else
						{
							MENU_ITEM(szMenu, iLen, "^n%L \d%L %L", pId, "#Jb_Menu_Number", iItem, pId, aSimonMenu[AI_SIMON_MENU_NAME], pId, "#Jb_Menu_Limit_2");
						}
					}
				}
				else
				{
					MENU_ITEM(szMenu, iLen, "^n%L \d%L %s", pId, "#Jb_Menu_Number", iItem, pId, aSimonMenu[AI_SIMON_MENU_NAME], g_szMenuItem_Info);
				}
			}
			else
			{
				if(aSimonMenu[AI_SIMON_MENU_FLAG] == -1)
				{
					switch(g_iSimonMenu_Limit[pId][iItemId])
					{
						case -1:
						{
							bitsKeys |= KEY(iItem);
							
							if(aSimonMenu[AI_SIMON_MENU_INFO][0] == EOS)
							{
								MENU_ITEM(szMenu, iLen, "^n%L \w%L", pId, "#Jb_Menu_Number", iItem, pId, aSimonMenu[AI_SIMON_MENU_NAME]);
							}
							else
							{
								MENU_ITEM(szMenu, iLen, "^n%L \w%L %L", pId, "#Jb_Menu_Number", iItem, pId, aSimonMenu[AI_SIMON_MENU_NAME], pId, aSimonMenu[AI_SIMON_MENU_INFO]);
							}
						}
						case 0:
						{
							MENU_ITEM(szMenu, iLen, "^n%L \d%L %L", pId, "#Jb_Menu_Number", iItem, pId, aSimonMenu[AI_SIMON_MENU_NAME], pId, "#Jb_Menu_Limit_3");
						}
						default:
						{
							bitsKeys |= KEY(iItem);
							
							if(aSimonMenu[AI_SIMON_MENU_INFO][0] == EOS)
							{
								MENU_ITEM(szMenu, iLen, "^n%L \w%L %L", pId, "#Jb_Menu_Number", iItem, pId, aSimonMenu[AI_SIMON_MENU_NAME], pId, "#Jb_Menu_Limit_1_1", g_iSimonMenu_Limit[pId][iItemId]);
							}
							else
							{
								MENU_ITEM(szMenu, iLen, "^n%L \w%L %L %L", pId, "#Jb_Menu_Number", iItem, pId, aSimonMenu[AI_SIMON_MENU_NAME], pId, aSimonMenu[AI_SIMON_MENU_INFO], pId, "#Jb_Menu_Limit_1_1", g_iSimonMenu_Limit[pId][iItemId]);
							}
						}
					}
				}
				else
				{
					if(IsFlag(pId, aSimonMenu[AI_SIMON_MENU_FLAG]))
					{
						switch(g_iSimonMenu_Limit[pId][iItemId])
						{
							case -1:
							{
								bitsKeys |= KEY(iItem);
								
								if(aSimonMenu[AI_SIMON_MENU_INFO][0] == EOS)
								{
									MENU_ITEM(szMenu, iLen, "^n%L \w%L", pId, "#Jb_Menu_Number", iItem, pId, aSimonMenu[AI_SIMON_MENU_NAME]);
								}
								else
								{
									MENU_ITEM(szMenu, iLen, "^n%L \w%L %L", pId, "#Jb_Menu_Number", iItem, pId, aSimonMenu[AI_SIMON_MENU_NAME], pId, aSimonMenu[AI_SIMON_MENU_INFO]);
								}
							}
							case 0:
							{
								MENU_ITEM(szMenu, iLen, "^n%L \d%L %L", pId, "#Jb_Menu_Number", iItem, pId, aSimonMenu[AI_SIMON_MENU_NAME], pId, "#Jb_Menu_Limit_3");
							}
							default:
							{
								bitsKeys |= KEY(iItem);
								
								if(aSimonMenu[AI_SIMON_MENU_INFO][0] == EOS)
								{
									MENU_ITEM(szMenu, iLen, "^n%L \w%L %L", pId, "#Jb_Menu_Number", iItem, pId, aSimonMenu[AI_SIMON_MENU_NAME], pId, "#Jb_Menu_Limit_1_1", g_iSimonMenu_Limit[pId][iItemId]);
								}
								else
								{
									MENU_ITEM(szMenu, iLen, "^n%L \w%L %L %L", pId, "#Jb_Menu_Number", iItem, pId, aSimonMenu[AI_SIMON_MENU_NAME], pId, aSimonMenu[AI_SIMON_MENU_INFO], pId, "#Jb_Menu_Limit_1_1", g_iSimonMenu_Limit[pId][iItemId]);
								}
							}
						}
					}
					else
					{
						MENU_ITEM(szMenu, iLen, "^n%L \d%L %L", pId, "#Jb_Menu_Number", iItem, pId, aSimonMenu[AI_SIMON_MENU_NAME], pId, "#Jb_Menu_Limit_2");
					}
				}
			}
		}
	}
	
	MENU_ITEM(szMenu, iLen, "^n");
	
	if(iPage)
	{
		bitsKeys |= KEY(8);
	
		MENU_ITEM(szMenu, iLen, "^n%L \w%L", pId, "#Jb_Menu_Number", 8, pId, "#Jb_Menu_Back");
	}
	
	if(iPages > 1 && iPage + 1 < iPages)
	{
		bitsKeys |= KEY(9);
		
		MENU_ITEM(szMenu, iLen, "^n%L \w%L", pId, "#Jb_Menu_Number", 9, pId, "#Jb_Menu_Next");
	}
	
	MENU_ITEM(szMenu, iLen, "^n%L \w%L", pId, "#Jb_Menu_Number", 0, pId, "#Jb_Menu_Exit");
	
	SHOW_MENU(pId, bitsKeys, szMenu, MenuId_Simon);
}

public ShowMenu_Simon_Handler(const pId, const iKey)
{
	if(IsRound(ROUND_END) || !IsConnected(pId) || !IsUser(pId, USER_SIMON))
		return;

	switch(KEY_HANDLER(iKey))
	{
		case 0: return;
		case 8: _MENU_CALLBACK_SIMON(Back, pId);
		case 9: _MENU_CALLBACK_SIMON(Next, pId);
		default:
		{
			new iItem = GetMenuItemTarget(pId, iKey, 7);

			if(!g_iSimonMenu_Limit[pId][iItem])
				return;

			new aSimonMenu[ENUM_DATA_SIMON_MENU];
			ArrayGetArray(g_aSimonMenu, iItem, aSimonMenu);

			if(aSimonMenu[AI_SIMON_MENU_FLAG] != -1 && !IsFlag(pId, aSimonMenu[AI_SIMON_MENU_FLAG]))
				return;

			ExecuteForward(aSimonMenu[AI_SIMON_MENU_ID], g_iForward_Result, pId);

			switch(g_iForward_Result)
			{
				case JB_CONTINUE:
				{
					if(aSimonMenu[AI_SIMON_MENU_LIMIT] != -1)
					{
						--g_iSimonMenu_Limit[pId][iItem];
					}
				}
				case JB_HANDLED: {}
			}
		}
	}
}

ShowMenu_Players_Next(const pId, &iPage, const iMenuId)
{
	ShowMenu_Players(pId, ++iPage, iMenuId);
}

ShowMenu_Players_Back(const pId, &iPage, const iMenuId)
{
	ShowMenu_Players(pId, --iPage, iMenuId);
}

stock ShowMenu_Players_Saved(const pId, const iPage, const iMenuId)
{
	ShowMenu_Players(pId, iPage, iMenuId);
}

ShowMenu_Players_New(const pId, &iPage, const iMenuId)
{
	ShowMenu_Players(pId, iPage = 0, iMenuId);
}

ShowMenu_Players(const pId, const iPage, const iMenuId)
{
	if((g_iPlayersMenu_ItemId[pId] = iMenuId) == ITEM_NULL)
		return;

	new iItemsNum;
	for(new iPlayer = 1; iPlayer < MaxClients; iPlayer++)
	{
		if(!IsConnected(iPlayer))
			continue;
		
		ExecuteForward(FORWARD(FORWARD_PLAYERS_MENU_LOAD), g_iForward_Result, pId, iPlayer, iMenuId);

		if(g_iForward_Result != JB_CONTINUE)
			continue;
		
		g_iMenu_Target[pId][iItemsNum++] = iPlayer;
	}
	
	new iStart = min(iPage * 7, iItemsNum); 
	iStart -= (iStart % 7);
	
	g_iMenu_Page[pId] = iStart / 7;
	
	new iEnd = min(iStart + 7, iItemsNum);
	
	static szMenu[512]; new iLen, iPages = (iItemsNum / 7 + ((iItemsNum % 7) ? 1 : 0));
	switch(iPages)
	{
		case 0:
		{
			PRINT_CENTER(pId, "%L", pId, "#Jb_Msg_Error_NoPlayers"); return;
		}
		case 1:
		{
			MENU_TITLE(szMenu, iLen, "%L^n", pId, "#Jb_Menu_Players_Title");
		}
		default:
		{
			MENU_TITLE(szMenu, iLen, "%L %L^n", pId, "#Jb_Menu_Players_Title", pId, "#Jb_Menu_Numbers", iPage + 1, iPages);
		}
	}
	Jb_UpdateInformer_Up(pId);
	
	new bitsKeys = KEY(0);
	for(new i = iStart, iItem = 1, szName[32], iPlayer; i < iEnd; i++, iItem++)
	{
		g_szMenuItem[0] = EOS;
		g_szMenuItem_Info[0] = EOS;

		iPlayer = g_iMenu_Target[pId][i];

		rg_get_user_name2(iPlayer, szName);

		ExecuteForward(FORWARD(FORWARD_PLAYERS_MENU_OPEN), g_iForward_Result, pId, iPlayer, iMenuId);
		
		if(g_szMenuItem[0] != EOS)
		{
			if(g_szMenuItem_Info[0] != EOS)
			{
				if(g_iForward_Result == JB_CONTINUE)
				{
					bitsKeys |= KEY(iItem);
					
					MENU_ITEM(szMenu, iLen, "^n%L \w%s", pId, "#Jb_Menu_Number", iItem, g_szMenuItem);
				}
				else
				{
					MENU_ITEM(szMenu, iLen, "^n%L \d%s %s", pId, "#Jb_Menu_Number", iItem, g_szMenuItem, g_szMenuItem_Info);
				}
			}
			else
			{
				bitsKeys |= KEY(iItem);
				
				MENU_ITEM(szMenu, iLen, "^n%L \w%s", pId, "#Jb_Menu_Number", iItem, g_szMenuItem);
			}
		}
		else
		{
			if(g_szMenuItem_Info[0] != EOS)
			{
				if(g_iForward_Result == JB_CONTINUE)
				{
					bitsKeys |= KEY(iItem);
					
					MENU_ITEM(szMenu, iLen, "^n%L \w%s %s", pId, "#Jb_Menu_Number", iItem, szName, g_szMenuItem_Info);
				}
				else
				{
					MENU_ITEM(szMenu, iLen, "^n%L \d%s %s", pId, "#Jb_Menu_Number", iItem, szName, g_szMenuItem_Info);
				}
			}
			else
			{
				bitsKeys |= KEY(iItem);
				
				MENU_ITEM(szMenu, iLen, "^n%L \w%s", pId, "#Jb_Menu_Number", iItem, szName);
			}
		}
	}
	
	MENU_ITEM(szMenu, iLen, "^n");
	
	if(iPage)
	{
		bitsKeys |= KEY(8);
	
		MENU_ITEM(szMenu, iLen, "^n%L \w%L", pId, "#Jb_Menu_Number", 8, pId, "#Jb_Menu_Back");
	}
	
	if(iPages > 1 && iPage + 1 < iPages)
	{
		bitsKeys |= KEY(9);
		
		MENU_ITEM(szMenu, iLen, "^n%L \w%L", pId, "#Jb_Menu_Number", 9, pId, "#Jb_Menu_Next");
	}
	
	MENU_ITEM(szMenu, iLen, "^n%L \w%L", pId, "#Jb_Menu_Number", 0, pId, "#Jb_Menu_Exit");
	
	SHOW_MENU(pId, bitsKeys, szMenu, MenuId_Players);
}

public ShowMenu_Players_Handler(pId, iKey)
{
	if(IsRound(ROUND_END) || !IsConnected(pId))
		return;
	
	switch(KEY_HANDLER(iKey))
	{
		case 0: return;
		case 8: _MENU_CALLBACK_PLAYERS(Back, pId, g_iPlayersMenu_ItemId[pId]);
		case 9: _MENU_CALLBACK_PLAYERS(Next, pId, g_iPlayersMenu_ItemId[pId]);
		default:
		{
			new iPlayer = GetMenuItemTarget(pId, iKey, 7);
			new iFunctionId = ArrayGetCell(g_aPlayersMenu, g_iPlayersMenu_ItemId[pId]);

			ExecuteForward(iFunctionId, g_iForward_Result, pId, iPlayer);
		}
	}
}

/** [ `Jb_` ] 
----------------------------------------------------------------------------------------------------------------------------------------------------*/
Jb_UpdateInformer_Up(const pId)
{
	new bool:bUpdate = false;

	if(g_flPosition_Informer[pId][POSITION_X] != g_flCvar[FCVAR_INFORMER_INFO_2][POSITION_X])
	{
		bUpdate = true;

		g_flPosition_Informer[pId][POSITION_X] = g_flCvar[FCVAR_INFORMER_INFO_2][POSITION_X];
	}

	if(g_flPosition_Informer[pId][POSITION_Y] != g_flCvar[FCVAR_INFORMER_INFO_2][POSITION_Y])
	{
		bUpdate = true;
		
		g_flPosition_Informer[pId][POSITION_Y] = g_flCvar[FCVAR_INFORMER_INFO_2][POSITION_Y];
	}

	if(g_bInformer[pId] && bUpdate)
	{
		Task_UpdateInformer(pId);
	}
}

Jb_UpdateInformer_Down(const pId)
{
	g_flPosition_Informer[pId][POSITION_X] = g_flCvar[FCVAR_INFORMER_INFO_1][POSITION_X];
	g_flPosition_Informer[pId][POSITION_Y] = g_flCvar[FCVAR_INFORMER_INFO_1][POSITION_Y];
	
	// if(g_bInformer[pId])
	// {
	// 	Task_UpdateInformer(pId);
	// }
}

Jb_RoundStart()
{
	g_iRound = ROUND_START;

	if(++g_iWeekDay > WEEK_DAY_SUNDAY)
	{
		g_iWeekDay = WEEK_DAY_MONDAY;
	}
	++g_iDay;

	g_iVoiceSpeak = VOICE_SPEAK_GUARD;

	new szLang_WeekDay[32];
	formatex(szLang_WeekDay, charsmax(szLang_WeekDay), "#Jb_WeekDay_%d", g_iWeekDay);
	formatex(g_szWeekDay, charsmax(g_szWeekDay), "%L", LANG_PLAYER, szLang_WeekDay);

	switch(g_iWeekDay)
	{
		case WEEK_DAY_MONDAY:
		{
			Jb_SetDayMode(DAY_MODE_FREE_DAY);
		}
		case WEEK_DAY_SATURDAY, WEEK_DAY_SUNDAY:
		{
			Jb_SetDayMode(DAY_MODE_GAME);
		}
		default:
		{
			Jb_SetDayMode(DAY_MODE_NORMAL);

			if(CVAR(TIME_SIMON) > 0)
			{
				set_task(1.0, "Task_ChooseSimon", TASK_CHOOSE_SIMON, .flags = "a", .repeat = (g_iTimer_ChooseSimon = CVAR(TIME_SIMON) + 1));
			}

			Jb_CheckLast();
		}
	}
	TrieClear(g_tSteamId);

	_FORWARD_EXECUTE(RoundStart);
}

Jb_RoundEnd()
{
	g_iRound = ROUND_END;
	g_iDayMode = DAY_MODE_NULL;
	
	if(IsDoorOpened())
	{
		UTIL_CloseDoors();
	}
	
	remove_task(TASK_FREE_DAY);
	remove_task(TASK_CHOOSE_SIMON);

	formatex(g_szInformer_Round, charsmax(g_szInformer_Round), "%L", LANG_PLAYER, "#Jb_Hud_Informer_RoundEnd");
	formatex(g_szInformer_SimonName, charsmax(g_szInformer_SimonName), "%L", LANG_PLAYER, "#Jb_Hud_Informer_NoSimon");

	//TODO: GameEnd -> g_szInformer_DayMode[0] = EOS;

	for(new i = 0; i < _:ENUM_DATA_LANG_INFORMER; i++)
	{
		g_iLang_Informer[i] = 0;
		g_szLang_Names[i][0] = EOS;
	}

	for(new pId = 1; pId <= MaxClients; pId++)
	{
		if(!IsAlive(pId)) continue;

		if(IsWanted(pId))
		{
			Jb_ResetWantedPlayer(pId);
		}
		else if(IsFree(pId))
		{
			Jb_ResetFreePlayer(pId);
		}
	}

	if(USER(USER_SIMON))
	{
		g_szSimonName[0] = EOS;
		
		formatex(g_szInformer_SimonName, charsmax(g_szInformer_SimonName), "%L", LANG_PLAYER, "#Jb_Hud_Informer_NoSimon");
	}

	for(new i = 0; i < _:ENUM_DATA_USER; i++)
	{
		USER(i) = 0;
	}
	
	_FORWARD_EXECUTE(RoundEnd);
}

Jb_RestartGameStart()
{
	if(!CVAR(TIME_RESTART))
	{
		Jb_RestartEnd(.bForward = false);
	}
	else
	{
		g_iRound = ROUND_RESTART;

		_FORWARD_EXECUTE(RestartStart);

		set_task(1.0, "Task_RestartGame", TASK_RESTART, .flags = "a", .repeat = (g_iTimer_Restart = CVAR(TIME_RESTART) + 1));
	}
}

Jb_RestartEnd(const bool:bForward = true)
{
	g_iRound = ROUND_START;

	EnableHookChain(g_iRhHook_DropClient);

	formatex(g_szWeekDay, charsmax(g_szWeekDay), "%L", LANG_PLAYER, "#Jb_WeekDay_0");
	formatex(g_szInformer_Round, charsmax(g_szInformer_Round), "%L", LANG_PLAYER, "#Jb_Hud_Informer_RestartEnd");
	formatex(g_szInformer_SimonName, charsmax(g_szInformer_SimonName), "%L", LANG_PLAYER, "#Jb_Hud_Informer_NoSimon");

	set_pcvar_num(g_iCvarId_Restart, 1);

	if(bForward)
	{
		_FORWARD_EXECUTE(RestartEnd);
	}
}

Jb_SetDayMode(DayMode:iDayMode)
{
	switch((g_iDayMode = iDayMode))
	{
		case DAY_MODE_NORMAL:
		{
			formatex(g_szInformer_Round, charsmax(g_szInformer_Round), "%L", LANG_PLAYER, "#Jb_Hud_Informer_NormalDay");
		}
		case DAY_MODE_FREE_DAY:
		{
			Jb_FreeDayStart();
		}
		case DAY_MODE_GAME:
		{
			formatex
			(
				g_szInformer_Round, charsmax(g_szInformer_Round), "%L %L", 
				
				LANG_PLAYER, "#Jb_Hud_Informer_Game", LANG_PLAYER, "#Jb_Hud_Informer_GameWait"
			);
		}
		default: g_iDayMode = DAY_MODE_NULL;
	}
}

Jb_ResetDayMode(DayMode:iDayMode)
{
	switch(iDayMode)
	{
		case DAY_MODE_FREE_DAY:
		{
			Jb_ResetFreeAll();
		}
	}

	Jb_SetDayMode(DAY_MODE_NORMAL);
}

Jb_FreeDayStart()
{
	formatex(g_szInformer_Round, charsmax(g_szInformer_Round), "%L", LANG_PLAYER, "#Jb_Hud_Informer_FreeDay");

	if(IsWeekDay(WEEK_DAY_MONDAY))
	{
		set_task(1.0, "Task_FreeDay", TASK_FREE_DAY, .flags = "a", .repeat = (g_iTimer_FreeDay = CVAR(TIME_FREE_DAY_GAME) + 1));
	}
	else
	{
		set_task(1.0, "Task_FreeDay", TASK_FREE_DAY, .flags = "a", .repeat = (g_iTimer_FreeDay = CVAR(TIME_FREE_DAY) + 1));
	}

	Jb_SetFreeAll();
}

Jb_FreeDayEnd()
{
	Jb_ResetDayMode(DAY_MODE_FREE_DAY);
}

bool:Jb_SetSimon(const pId)
{
	if(_FORWARD_EXECUTE_PLAYER(PlayerBecomeSimon, pId, .bPost = false) == JB_HANDLED)
		return false;

	USER(USER_SIMON) = pId;

	remove_task(TASK_CHOOSE_SIMON);

	g_szSimonName = rg_get_user_name(pId);
	g_szInformer_SimonName = g_szSimonName;

	_FORWARD_EXECUTE_PLAYER(PlayerBecomeSimon, pId, .bPost = true);

	return true;
}

Jb_ResetSimon()
{
	USER(USER_SIMON) = 0;

	g_szSimonName[0] = EOS;

	formatex(g_szInformer_SimonName, charsmax(g_szInformer_SimonName), "%L", LANG_PLAYER, "#Jb_Hud_Informer_NoSimon");
}

Jb_ResetLast()
{
	//TODO: Add forward: Jb_ResetLast
	USER(USER_LAST) = 0;
}

Jb_CheckLast(const bool:bMessage = false)
{
	if(USER(USER_LAST))
		return;

	if(_:g_iAliveNum[TEAM_PRISONER] != 1 || _:g_iAliveNum[TEAM_GUARD] < CVAR(MIN_GUARD))
		return;

	new iLastId;
	for(new pId = 1; pId <= MaxClients; pId++)
	{
		if(!IsAlive(pId) || !IsTeam(pId, TEAM_PRISONER))
			continue;
		
		iLastId = pId; break;
	}
	
	if(Forward_Execute_Last(iLastId) == JB_HANDLED)
		return;

	USER(USER_LAST) = iLastId;

	if(bMessage)
	{
		PRINT_CHAT(0, "%L", LANG_PLAYER, "#Jb_Msg_Last", rg_get_user_name(USER(USER_LAST)));
	}

	_FORWARD_EXECUTE_PLAYER(PlayerBecomeLast, iLastId, .bPost = true);
}

Jb_SetWanted(const pId)
{
	if(IsWanted(pId)) return;
	
	if(g_szLang_Names[LANG_INFORMER_WANTED][0] == EOS)
	{
		UTIL_PlaySound(0, "riot");
		
		//TODO: First wandted -> add money
	}

	Jb_SetWantedPlayer(pId);
}

Jb_SetWantedPlayer(const pId)
{
	if(_FORWARD_EXECUTE_PLAYER(PlayerBecomeWanted, pId, .bPost = false) == JB_HANDLED)
		return;

	if(IsFree(pId))
	{
		Jb_ResetFreePlayer(pId);
	}

	g_bWanted[pId] = true;

	//TODO: Forward -> set user wanted

	formatex
	(
		g_szLang_Names[LANG_INFORMER_WANTED], charsmax(g_szLang_Names[]), "%s^n%s", 
		
		g_szLang_Names[LANG_INFORMER_WANTED], rg_get_user_name(pId)
	);
	g_iLang_Informer[LANG_INFORMER_WANTED] = 1;

	_FORWARD_EXECUTE_PLAYER(PlayerBecomeWanted, pId, .bPost = true);
}

Jb_ResetWantedPlayer(const pId)
{
	g_bWanted[pId] = false;

	if(g_szLang_Names[LANG_INFORMER_WANTED][0] != EOS)
	{
		new szName[32 + 2];
		formatex(szName, charsmax(szName), "^n%s", rg_get_user_name(pId));

		while(replace(g_szLang_Names[LANG_INFORMER_WANTED], charsmax(g_szLang_Names[]), szName, "")) {}

		g_iLang_Informer[LANG_INFORMER_WANTED] = _:(g_szLang_Names[LANG_INFORMER_WANTED][0] != EOS);
	}

	_FORWARD_EXECUTE_PLAYER(PlayerResetWanted, pId, .bPost = true);
}

Jb_SetFreePlayer(const pId)
{
	if(IsFree(pId))
		return;

	if(_FORWARD_EXECUTE_PLAYER(PlayerBecomeFree, pId, .bPost = false) == JB_HANDLED)
		return;

	g_bFree[pId] = true;

	_FORWARD_EXECUTE_PLAYER(PlayerBecomeFree, pId, .bPost = true);
}

Jb_ResetFreePlayer(const pId)
{
	g_bFree[pId] = false;

	_FORWARD_EXECUTE_PLAYER(PlayerResetFree, pId, .bPost = true);
}

Jb_SetFreeAll()
{
	for(new pId = 1; pId <= MaxClients; pId++)
	{
		if(!IsAlive(pId) || !IsTeam(pId, TEAM_PRISONER))
			continue;
		
		Jb_SetFreePlayer(pId);
	}
	g_bFreeDayStarted = true;

	_FORWARD_EXECUTE(FreeDayStart);
}

Jb_ResetFreeAll()
{
	remove_task(TASK_FREE_DAY);
	
	for(new pId = 1; pId <= MaxClients; pId++)
	{
		if(!IsAlive(pId) || !IsFree(pId))
			continue;

		Jb_ResetFreePlayer(pId);
	}
	g_bFreeDayStarted = false;

	_FORWARD_EXECUTE(FreeDayEnd);
}


/** [ `UTIL` ] 
----------------------------------------------------------------------------------------------------------------------------------------------------*/
UTIL_SetMoney(const pId, const iMoney = 0, const bool:bMoney = true)
{
	if(bMoney)
	{
		g_iMoney[pId] = min(max(0, iMoney), CVAR(MAX_MONEY));
	}
	
	message_begin(MSG_ONE, MsgId_Money, _, pId);
	{
		write_long(g_iMoney[pId]);
		write_byte(_:IsAlive(pId));
	}
	message_end();
}

UTIL_StatusIcon(const pId, const szIcon[], const iColor[ENUM_DATA_COLORS], const iType, const bool:bReliable = false)
{
	message_begin(bReliable ? MSG_ONE : MSG_ONE_UNRELIABLE, MsgId_StatusIcon, _, pId);
	{
		write_byte(iType); //0-Hide | 1-Show | 2-Flash
		write_string(szIcon);
		write_byte(iColor[COLOR_R]);
		write_byte(iColor[COLOR_G]);
		write_byte(iColor[COLOR_B]);
	}
	message_end();
}

UTIL_RoundTime(const pId, const iSeconds = 0, const bool:bReliable = false)
{
	set_member(pId, m_iHideHUD, get_member(pId, m_iHideHUD) & ~BIT(4));

	emessage_begin(bReliable ? MSG_ONE : MSG_ONE_UNRELIABLE, MsgId_RoundTime, _, pId);
	{
		ewrite_short(iSeconds);
	}
	emessage_end();
}

UTIL_RoundTimeHide(const pId)
{
	set_member(pId, m_iHideHUD, get_member(pId, m_iHideHUD) | BIT(4));
}

UTIL_OpenDoors()
{
	for(new i = 0; i < g_iDoor_ItemsNum; i++)
	{
		dllfunc(DLLFunc_Use, ArrayGetCell(g_aDoor, i), 0);
	}

	g_bDoorStatus = true;
}

UTIL_CloseDoors()
{
	for(new i = 0; i < g_iDoor_ItemsNum; i++)
	{
		dllfunc(DLLFunc_Think, ArrayGetCell(g_aDoor, i));
	}
	
	g_bDoorStatus = false;
}

UTIL_SetKVD(const iEnt, const szClassName[], const szKeyName[], const szValue[])
{
	set_kvd(0, KV_ClassName, szClassName);
	set_kvd(0, KV_KeyName, szKeyName);
	set_kvd(0, KV_Value, szValue);
	set_kvd(0, KV_fHandled, 0);

	return dllfunc(DLLFunc_KeyValue, iEnt, 0);
}

bool:UTIL_IsValidGuardTeam()
{
	if(((abs(_:g_iPlayersNum[TEAM_PRISONER] - 1) / CVAR(RATIO_GUARD_TO_PRISONER)) + 1) <= _:g_iPlayersNum[TEAM_GUARD])
		return false;

	return true;
}

UTIL_PlaySound(const pId, const szKey[])
{
	if(!TrieKeyExists(g_tSound, szKey))
		return;
	
	new szBuffer[64];
	TrieGetString(g_tSound, szKey, szBuffer, charsmax(szBuffer));
	
	new szSound[64];
	formatex(szSound, charsmax(szSound), "sound/%s", szBuffer);

	if(IsMp3Format(szSound))
	{
		UTIL_PlayMp3(pId, szSound);
	}
	else
	{
		UTIL_PlayWav(pId, szSound);
	}
}

/** [ `PRECACHE_` ] 
----------------------------------------------------------------------------------------------------------------------------------------------------*/
stock PRECACHE_MODEL(const szModel[], any:...)
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

stock PRECACHE_SOUND(const szSound[], any:...)
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

stock PRECACHE_GENERIC(const szGeneric[], any:...)
{
	new szFile[64], iReturn = -1;
	vformat(szFile, charsmax(szFile), szGeneric, 2);
	
	if(file_exists(szFile))
	{
		iReturn = engfunc(EngFunc_PrecacheGeneric, szFile);
	}
	else
	{
		UTIL_Log("Error", "%s | PRECACHEx000: %s", PLUGIN, szFile);
	}
	
	return iReturn;
}

/** [ `JSON_` ] 
----------------------------------------------------------------------------------------------------------------------------------------------------*/
JSON_Precache()
{
	new szFile[64], szDir[32]; GET_DIR(szDir);
	formatex
	(
		szFile, charsmax(szFile), "%s/jailbreak/json/Core.json", szDir
	);

	if(!file_exists(szFile))
	{
		JSON_CreateFile(szFile);
	}
	else
	{
		JSON_ReadFile(szFile);
	}
}

JSON_CreateFile(const szFile[])
{
	new JSON:oJSON = json_init_object();
	
	/** Sound */
	JSON_CreateObject_Sound(oJSON);

	/** RemoveEnt */
	JSON_CreateObject_RemoveEnt(oJSON);

	/** BlockMessage */
	JSON_CreateObject_BlockMessage(oJSON);

	// [Конец]
	json_serial_to_file(oJSON, szFile, true);
	json_free(oJSON);
}

JSON_CreateObject_BlockMessage(&JSON:oJSON)
{
	new const szBlockMsg[][]=
	{
		"#Game_teammate_attack",
		"#Game_join_terrorist",
		"#Game_join_ct",
		"#Game_scoring",
		"#Game_will_restart_in",
		"#Game_Commencing",
		"#Only_1_Team_Change",
		"#Weapon_Cannot_Be_Dropped"
	}
	
	new JSON:oJSON_Value = json_init_object();
	for(new i = 0, iSize = sizeof(szBlockMsg); i < iSize; i++)
	{
		json_object_set_bool(oJSON_Value, szBlockMsg[i], bool:TrieSetCell(g_tBlockMsg, szBlockMsg[i], g_iBlockMsg_ItemsNum++));
	}

	json_object_set_value(oJSON, "BlockMessage", oJSON_Value);
	json_free(oJSON_Value);
}

JSON_CreateObject_RemoveEnt(&JSON:oJSON)
{
	new const szRemoveEnt[][]=
	{
		"func_hostage_rescue",
		"info_hostage_rescue",
		"func_bomb_target",
		"info_bomb_target",
		"func_vip_safetyzone",
		"info_vip_start",
		"func_escapezone",
		"hostage_entity",
		"monster_scientist",
		"func_buyzone"
	}
	
	new JSON:oJSON_Value = json_init_object();
	for(new i = 0, iSize = sizeof(szRemoveEnt); i < iSize; i++)
	{
		json_object_set_bool(oJSON_Value, szRemoveEnt[i], bool:TrieSetCell(g_tRemoveEnt, szRemoveEnt[i], g_iRemoveEnt_ItemsNum++));
	}
	
	json_object_set_value(oJSON, "RemoveEnt", oJSON_Value);
	json_free(oJSON_Value);
}

JSON_CreateObject_Sound(&JSON:oJSON)
{
	new szBuffer[64];

	new JSON:oJSON_Value_Object, JSON:oJSON_Value = json_init_object();

	/** FreeDay */
	oJSON_Value_Object = json_init_object();

	formatex(szBuffer, charsmax(szBuffer), "jailbreak\fd_start.wav");
	
	if(PRECACHE_SOUND(szBuffer) != -1)
	{
		TrieSetString(g_tSound, "fd_start", szBuffer);
	}
	json_object_set_string(oJSON_Value_Object, "Start", szBuffer);
	

	formatex(szBuffer, charsmax(szBuffer), "jailbreak\fd_end.wav");
	
	if(PRECACHE_SOUND(szBuffer) != -1)
	{
		TrieSetString(g_tSound, "fd_end", szBuffer);
	}
	json_object_set_string(oJSON_Value_Object, "End", szBuffer);

	json_object_set_value(oJSON_Value, "FreeDay", oJSON_Value_Object);
	json_free(oJSON_Value_Object);

	/** Game */
	oJSON_Value_Object = json_init_object();

	formatex(szBuffer, charsmax(szBuffer), "jailbreak\game\game_start.wav");
	
	if(PRECACHE_SOUND(szBuffer) != -1)
	{
		TrieSetString(g_tSound, "game_start", szBuffer);
	}
	json_object_set_string(oJSON_Value_Object, "Start", szBuffer);
	

	formatex(szBuffer, charsmax(szBuffer), "jailbreak\game\game_wait.wav");
	
	if(PRECACHE_SOUND(szBuffer) != -1)
	{
		TrieSetString(g_tSound, "game_wait", szBuffer);
	}
	json_object_set_string(oJSON_Value_Object, "Wait", szBuffer);

	json_object_set_value(oJSON_Value, "Game", oJSON_Value_Object);
	json_free(oJSON_Value_Object);

	/** Riot */
	formatex(szBuffer, charsmax(szBuffer), "jailbreak\prison_riot.wav");
	
	if(PRECACHE_SOUND(szBuffer) != -1)
	{
		TrieSetString(g_tSound, "riot", szBuffer);
	}
	json_object_set_string(oJSON_Value, "Riot", szBuffer);

	/** Shop */
	formatex(szBuffer, charsmax(szBuffer), "jailbreak\shop\purchase.wav");
	
	if(PRECACHE_SOUND(szBuffer) != -1)
	{
		TrieSetString(g_tSound, "purchase", szBuffer);
	}
	json_object_set_string(oJSON_Value, "Shop", szBuffer);

	/** Menu */
	formatex(szBuffer, charsmax(szBuffer), "jailbreak\menu_click.wav");
	
	if(PRECACHE_SOUND(szBuffer) != -1)
	{
		TrieSetString(g_tSound, "menu_click", szBuffer);
	}
	json_object_set_string(oJSON_Value, "Menu", szBuffer);
	

	json_object_set_value(oJSON, "Sound", oJSON_Value);
	json_free(oJSON_Value);
}

JSON_ReadFile(const szFile[])
{
	new JSON:oJSON_Parse = json_parse(szFile, true);

	if(oJSON_Parse == Invalid_JSON)
	{
		json_free(oJSON_Parse);

		UTIL_Log("Error", "%s | JSONx000: %s", PLUGIN, szFile); return;
	}

	/** RemoveEnt */
	JSON_ReadObject_RemoveEnt(oJSON_Parse);

	/** BlockMessage */
	JSON_ReadObject_BlockMessage(oJSON_Parse);

	/** Sound */
	JSON_ReadObject_Sound(oJSON_Parse);


	json_free(oJSON_Parse);
}

JSON_ReadObject_BlockMessage(const JSON:oJSON_Parse)
{
	if(json_object_has_value(oJSON_Parse, "BlockMessage", JSONObject, true))
	{
		new JSON:oJSON_Key = json_object_get_value(oJSON_Parse, "BlockMessage", true);

		for(new i = 0, iAmount = json_object_get_count(oJSON_Key), szKey[32]; i < iAmount; i++)
		{
			json_object_get_name(oJSON_Key, i, szKey, charsmax(szKey));

			if(json_is_true(json_object_get_value(oJSON_Key, szKey, false)))
			{
				TrieSetCell(g_tBlockMsg, szKey, g_iBlockMsg_ItemsNum++);
			}
		}
		json_free(oJSON_Key);
	}
	else
	{
		UTIL_Log("Error", "%s | JSONx001: BlockMessage", PLUGIN);
	}
}

JSON_ReadObject_RemoveEnt(const JSON:oJSON_Parse)
{
	if(json_object_has_value(oJSON_Parse, "RemoveEnt", JSONObject, true))
	{
		new JSON:oJSON_Key = json_object_get_value(oJSON_Parse, "RemoveEnt", true);

		for(new i = 0, iAmount = json_object_get_count(oJSON_Key), szKey[32]; i < iAmount; i++)
		{
			json_object_get_name(oJSON_Key, i, szKey, charsmax(szKey));

			if(json_is_true(json_object_get_value(oJSON_Key, szKey, false)))
			{
				TrieSetCell(g_tRemoveEnt, szKey, g_iRemoveEnt_ItemsNum++);
			}
		}
		json_free(oJSON_Key);
	}
	else
	{
		UTIL_Log("Error", "%s | JSONx001: RemoveEnt", PLUGIN);
	}
}

JSON_ReadObject_Sound(const JSON:oJSON_Parse)
{
	if(json_object_has_value(oJSON_Parse, "Sound", JSONObject, true))
	{
		new szSound[64];

		new JSON:oJSON_Key_Object;
		new JSON:oJSON_Key = json_object_get_value(oJSON_Parse, "Sound", true);

		// FreeDay
		if(json_object_has_value(oJSON_Key, "FreeDay", JSONBoolean, true))
		{
			if(json_object_get_bool(oJSON_Key, "FreeDay", false))
			{
				UTIL_Log("Error", "%s | JSONx002: Sound->FreeDay", PLUGIN);
			}
		}
		else if(json_object_has_value(oJSON_Key, "FreeDay", JSONObject, true))
		{
			oJSON_Key_Object = json_object_get_value(oJSON_Key, "FreeDay", true);

			if(json_object_has_value(oJSON_Key_Object, "Start", JSONString, true))
			{
				json_object_get_string(oJSON_Key_Object, "Start", szSound, charsmax(szSound), false);

				if(strlen(szSound) > 4 && (IsMp3Format(szSound) || IsWavFormat(szSound)))
				{
					while(replace(szSound, charsmax(szSound), "\", "/")) {}

					if(PRECACHE_SOUND(szSound) != -1)
					{
						TrieSetString(g_tSound, "fd_start", szSound);
					}
				}
				else
				{
					UTIL_Log("Error", "%s | JSONx003: Sound->FreeDay->Start", PLUGIN);
				}
			}
			else
			{
				UTIL_Log("Error", "%s | JSONx001: Sound->FreeDay->Start", PLUGIN);
			}

			if(json_object_has_value(oJSON_Key_Object, "End", JSONString, true))
			{
				json_object_get_string(oJSON_Key_Object, "End", szSound, charsmax(szSound), false);

				if(strlen(szSound) > 4 && (IsMp3Format(szSound) || IsWavFormat(szSound)))
				{
					while(replace(szSound, charsmax(szSound), "\", "/")) {}

					if(PRECACHE_SOUND(szSound) != -1)
					{
						TrieSetString(g_tSound, "fd_end", szSound);
					}
				}
				else
				{
					UTIL_Log("Error", "%s | JSONx003: Sound->FreeDay->End", PLUGIN);
				}
			}
			else
			{
				UTIL_Log("Error", "%s | JSONx001: Sound->FreeDay->End", PLUGIN);
			}

			json_free(oJSON_Key_Object);
		}
		else
		{
			UTIL_Log("Error", "%s | JSONx001: Sound->FreeDay", PLUGIN);
		}

		// Game
		if(json_object_has_value(oJSON_Key, "Game", JSONBoolean, true))
		{
			if(json_object_get_bool(oJSON_Key, "Game", false))
			{
				UTIL_Log("Error", "%s | JSONx002: Sound->Game", PLUGIN);
			}
		}
		else if(json_object_has_value(oJSON_Key, "Game", JSONObject, true))
		{
			oJSON_Key_Object = json_object_get_value(oJSON_Key, "Game", true);

			if(json_object_has_value(oJSON_Key_Object, "Start", JSONString, true))
			{
				json_object_get_string(oJSON_Key_Object, "Start", szSound, charsmax(szSound), false);

				if(strlen(szSound) > 4 && (IsMp3Format(szSound) || IsWavFormat(szSound)))
				{
					while(replace(szSound, charsmax(szSound), "\", "/")) {}

					if(PRECACHE_SOUND(szSound) != -1)
					{
						TrieSetString(g_tSound, "game_start", szSound);
					}
				}
				else
				{
					UTIL_Log("Error", "%s | JSONx003: Sound->Game->Start", PLUGIN);
				}
			}
			else
			{
				UTIL_Log("Error", "%s | JSONx001: Sound->Game->Start", PLUGIN);
			}

			if(json_object_has_value(oJSON_Key_Object, "Wait", JSONString, true))
			{
				json_object_get_string(oJSON_Key_Object, "Wait", szSound, charsmax(szSound), false);

				if(strlen(szSound) > 4 && (IsMp3Format(szSound) || IsWavFormat(szSound)))
				{
					while(replace(szSound, charsmax(szSound), "\", "/")) {}

					if(PRECACHE_SOUND(szSound) != -1)
					{
						TrieSetString(g_tSound, "game_wait", szSound);
					}
				}
				else
				{
					UTIL_Log("Error", "%s | JSONx003: Sound->Game->Wait", PLUGIN);
				}
			}
			else
			{
				UTIL_Log("Error", "%s | JSONx001: Sound->Game->Wait", PLUGIN);
			}

			json_free(oJSON_Key_Object);
		}
		else
		{
			UTIL_Log("Error", "%s | JSONx001: Sound->Game", PLUGIN);
		}

		// Riot
		if(json_object_has_value(oJSON_Key, "Riot", JSONBoolean, true))
		{
			if(json_object_get_bool(oJSON_Key, "Riot", false))
			{
				UTIL_Log("Error", "%s | JSONx002: Sound->Riot", PLUGIN);
			}
		}
		else if(json_object_has_value(oJSON_Key, "Riot", JSONString, true))
		{
			json_object_get_string(oJSON_Key, "Riot", szSound, charsmax(szSound), false);

			if(strlen(szSound) > 4 && (IsMp3Format(szSound) || IsWavFormat(szSound)))
			{
				while(replace(szSound, charsmax(szSound), "\", "/")) {}

				if(PRECACHE_SOUND(szSound) != -1)
				{
					TrieSetString(g_tSound, "riot", szSound);
				}
			}
			else
			{
				UTIL_Log("Error", "%s | JSONx003: Sound->Riot", PLUGIN);
			}
		}
		else
		{
			UTIL_Log("Error", "%s | JSONx001: Sound->Riot", PLUGIN);
		}

		// Shop
		if(json_object_has_value(oJSON_Key, "Shop", JSONBoolean, true))
		{
			if(json_object_get_bool(oJSON_Key, "Shop", false))
			{
				UTIL_Log("Error", "%s | JSONx002: Sound->Shop", PLUGIN);
			}
		}
		else if(json_object_has_value(oJSON_Key, "Shop", JSONString, true))
		{
			json_object_get_string(oJSON_Key, "Shop", szSound, charsmax(szSound), false);

			if(strlen(szSound) > 4 && (IsMp3Format(szSound) || IsWavFormat(szSound)))
			{
				while(replace(szSound, charsmax(szSound), "\", "/")) {}

				if(PRECACHE_SOUND(szSound) != -1)
				{
					TrieSetString(g_tSound, "purchase", szSound);
				}
			}
			else
			{
				UTIL_Log("Error", "%s | JSONx003: Sound->Shop", PLUGIN);
			}
		}
		else
		{
			UTIL_Log("Error", "%s | JSONx001: Sound->Shop", PLUGIN);
		}

		// Menu
		if(json_object_has_value(oJSON_Key, "Menu", JSONBoolean, true))
		{
			if(json_object_get_bool(oJSON_Key, "Menu", false))
			{
				UTIL_Log("Error", "%s | JSONx002: Sound->Menu", PLUGIN);
			}
		}
		else if(json_object_has_value(oJSON_Key, "Menu", JSONString, true))
		{
			json_object_get_string(oJSON_Key, "Menu", szSound, charsmax(szSound), false);

			if(strlen(szSound) > 4 && (IsMp3Format(szSound) || IsWavFormat(szSound)))
			{
				while(replace(szSound, charsmax(szSound), "\", "/")) {}

				if(PRECACHE_SOUND(szSound) != -1)
				{
					TrieSetString(g_tSound, "menu_click", szSound);
				}
			}
			else
			{
				UTIL_Log("Error", "%s | JSONx003: Sound->Menu", PLUGIN);
			}
		}
		else
		{
			UTIL_Log("Error", "%s | JSONx001: Sound->Menu", PLUGIN);
		}

		json_free(oJSON_Key);
	}
	else
	{
		UTIL_Log("Error", "%s | JSONx001: Sound", PLUGIN);
	}
}


/** [ `Native_` ] 
----------------------------------------------------------------------------------------------------------------------------------------------------*/
Native_Init()
{
	register_library("jailbreak");

	register_native("RegisterPlayersMenu", "Native_RegisterPlayersMenu", 1);
	register_native("RegisterMainMenuItem", "Native_RegisterMainMenuItem", 1);
	register_native("RegisterSimonMenuItem", "Native_RegisterSimonMenuItem", 1);

	register_native("RegisterHookJailBreak", "Native_RegisterHookJailBreak", 1);

	register_native("EnableHookJailBreak", "Native_EnableHookJailBreak", 1);
	register_native("DisableHookJailBreak", "Native_DisableHookJailBreak", 1);
	register_native("DestroyHookJailBreak", "Native_DestroyHookJailBreak", 1);

	register_native("jb_open_doors", "Native_OpenDoors", 1);
	register_native("jb_close_doors", "Native_CloseDoors", 1);

	register_native("jb_get_day", "Native_GetDay", 1);
	register_native("jb_get_round", "Native_GetRound", 1);
	register_native("jb_get_last_id", "Native_GetLastId", 1);
	register_native("jb_get_simon_id", "Native_GetSimonId", 1);
	register_native("jb_get_day_mode", "Native_GetDayMode", 1);
	register_native("jb_get_doors_status", "Native_GetDoorsStatus", 1);

	register_native("jb_set_day_mode", "Native_SetDayMode", 1);
	register_native("jb_set_voice_speak", "Native_SetVoiceSpeak", 1);

	register_native("jb_reset_day_mode", "Native_ResetDayMode", 1);

	register_native("jb_is_user_last", "Native_IsLast", 1);
	register_native("jb_is_user_simon", "Native_IsSimon", 1);
	register_native("jb_is_user_voice", "Native_IsVoice", 1);

	register_native("jb_get_user_sex", "Native_GetUserSex", 1);
	register_native("jb_get_user_money", "Native_GetUserMoney", 1);

	register_native("jb_transfer_simon", "Native_TransferSimon", 1);

	register_native("jb_set_user_sex", "Native_SetUserSex", 1);
	register_native("jb_set_user_team", "Native_SetUserTeam", 1);
	register_native("jb_set_user_money", "Native_SetUserMoney", 1);
	register_native("jb_set_user_simon", "Native_SetUserSimon", 1);
	register_native("jb_set_user_voice", "Native_SetUserVoice", 1);

	register_native("jb_reset_user_voice", "Native_ResetUserVoice", 1);

	register_native("jb_show_menu_main", "Native_ShowMenuMain", 1);
	register_native("jb_show_menu_team", "Native_ShowMenuTeam", 1);
	register_native("jb_show_menu_last", "Native_ShowMenuLast", 1);
	register_native("jb_show_menu_simon", "Native_ShowMenuSimon", 1);
	register_native("jb_show_menu_players", "Native_ShowMenuPlayers", 1);

	register_native("jb_update_informer_up", "Native_UpdateInformerUp", 1);
	register_native("jb_update_informer_down", "Native_UpdateInformerDown", 1);

	register_native("jb_update_menu_item", "Native_UpdateMenuItem", 0);
	register_native("jb_update_menu_item_info", "Native_UpdateMenuItemInfo", 0);
}

public bool:Native_TransferSimon(const pId, const iPlayer)
{
	new iSimon = pId;

	//Ставим модель кт

	if(!Jb_SetSimon(iPlayer))
	{
		Jb_ResetSimon(); return false;
	}

	return true;
}

public Native_ResetDayMode(const DayMode:iDayMode)
{
	Jb_ResetDayMode(iDayMode);
}

public Native_GetDay()
{
	return g_iDay;
}

public Native_SetDayMode(const DayMode:iDayMode)
{
	Jb_SetDayMode(iDayMode);
}

public Native_SetVoiceSpeak(const VoiceSpeak:iType)
{
	g_iVoiceSpeak = iType;
}

public DayMode:Native_GetDayMode()
{
	return g_iDayMode;
}

public bool:Native_IsLast(const pId)
{
	return IsUser(pId, USER_LAST);
}

public bool:Native_IsSimon(const pId)
{
	return IsUser(pId, USER_SIMON);
}

public bool:Native_IsVoice(const pId)
{
	return IsVoice(pId);
}

public Native_GetUserMoney(const pId)
{
	return g_iMoney[pId];
}

public Native_SetUserMoney(const pId, const iMoney, const bool:bMoney)
{
	UTIL_SetMoney(pId, iMoney, bMoney);
}

public Native_GetUserSex(const pId)
{
	return g_iSex[pId];
}

public Native_SetUserSex(const pId, const iSex)
{
	g_iSex[pId] = iSex;
}

public Native_SetUserTeam(const pId, const TeamName:iTeam, bool:bKill)
{
	if(iTeam == TEAM_UNASSIGNED)
		return;
	
	if(bKill)
	{
		if(g_bAlive[pId])
		{
			g_iAliveNum[g_iTeam[pId]]--;

			g_bAlive[pId] = false;
		}

		if(IsAlive(pId))
		{
			dllfunc(DLLFunc_ClientKill, pId);
		}
	}
	else
	{
		if(g_bAlive[pId])
		{
			g_iAliveNum[g_iTeam[pId]]--;
		}
	}

	if(g_iTeam[pId] != TEAM_UNASSIGNED)
	{
		g_iPlayersNum[g_iTeam[pId]]--;
	}

	rg_set_user_team(pId, (g_iTeam[pId] = iTeam));

	if(g_iTeam[pId] != TEAM_UNASSIGNED)
	{
		g_iPlayersNum[g_iTeam[pId]]++;
	}

	if(!bKill)
	{
		if(g_bAlive[pId])
		{
			g_iAliveNum[g_iTeam[pId]]++;
		}
	}

	//TODO: Set models
}

public Native_OpenDoors()
{
	UTIL_OpenDoors();
}

public Native_CloseDoors()
{
	UTIL_CloseDoors();
}

public bool:Native_SetUserSimon(const pId)
{
	return Jb_SetSimon(pId);
}

public bool:Native_GetDoorsStatus()
{
	return g_bDoorStatus;
}

public Native_SetUserVoice(const pId)
{
	g_bVoice[pId] = true;
}

public Native_ResetUserVoice(const pId)
{
	g_bVoice[pId] = false;
}

public Native_GetSimonId()
{
	return USER(USER_SIMON);
}

public Native_GetLastId()
{
	return USER(USER_LAST);
}

public HookJailBreak:Native_RegisterHookJailBreak(const {JailBreak}:iFunctionId, const szCallBack[], const bool:bPost)
{
	param_convert(2);

	new aForward[ENUM_DATA_FORWARD];
	switch(iFunctionId)
	{
		case JB_RestartStart:
		{
			if(!bPost) return INVALID_HOOKJAILBREAK;

			aForward[AI_FORWARD_B_POST] = true;
			aForward[AI_FORWARD_B_DISABLE] = false;
			
			aForward[AI_FORWARD_ID] = CreateMultiForward(szCallBack, ET_IGNORE);

			ArrayPushArray(g_aForward, aForward);

			ArrayPushCell(g_aForward_RestartStart, (++g_iForward_ItemsNum - 1));
			
			g_iForward_RestartStart_ItemsNum++;
		}
		case JB_RestartEnd:
		{
			if(!bPost) return INVALID_HOOKJAILBREAK;

			aForward[AI_FORWARD_B_POST] = true;
			aForward[AI_FORWARD_B_DISABLE] = false;
			
			aForward[AI_FORWARD_ID] = CreateMultiForward(szCallBack, ET_IGNORE);

			ArrayPushArray(g_aForward, aForward);

			ArrayPushCell(g_aForward_RestartEnd, (++g_iForward_ItemsNum - 1));
			
			g_iForward_RestartEnd_ItemsNum++;
		}
		case JB_RoundStart:
		{
			if(!bPost) return INVALID_HOOKJAILBREAK;

			aForward[AI_FORWARD_B_POST] = true;
			aForward[AI_FORWARD_B_DISABLE] = false;
			
			aForward[AI_FORWARD_ID] = CreateMultiForward(szCallBack, ET_IGNORE);

			ArrayPushArray(g_aForward, aForward);

			ArrayPushCell(g_aForward_RoundStart, (++g_iForward_ItemsNum - 1));
			
			g_iForward_RoundStart_ItemsNum++;
		}
		case JB_RoundEnd:
		{
			if(!bPost) return INVALID_HOOKJAILBREAK;

			aForward[AI_FORWARD_B_POST] = true;
			aForward[AI_FORWARD_B_DISABLE] = false;
			
			aForward[AI_FORWARD_ID] = CreateMultiForward(szCallBack, ET_IGNORE);

			ArrayPushArray(g_aForward, aForward);

			ArrayPushCell(g_aForward_RoundEnd, (++g_iForward_ItemsNum - 1));
			
			g_iForward_RoundEnd_ItemsNum++;
		}
		case JB_Last:
		{
			if(bPost) return INVALID_HOOKJAILBREAK;

			aForward[AI_FORWARD_B_POST] = false;
			aForward[AI_FORWARD_B_DISABLE] = false;
			aForward[AI_FORWARD_ID] = CreateMultiForward(szCallBack, ET_CONTINUE, FP_CELL);

			ArrayPushArray(g_aForward, aForward);

			ArrayPushCell(g_aForward_Last, (++g_iForward_ItemsNum - 1));
			
			g_iForward_Last_ItemsNum++;
		}
		case JB_PlayerBecomeLast:
		{
			if(!bPost) return INVALID_HOOKJAILBREAK;

			aForward[AI_FORWARD_B_POST] = true;
			aForward[AI_FORWARD_B_DISABLE] = false;
			aForward[AI_FORWARD_ID] = CreateMultiForward(szCallBack, ET_IGNORE, FP_CELL);

			ArrayPushArray(g_aForward, aForward);

			ArrayPushCell(g_aForward_PlayerBecomeLast, (++g_iForward_ItemsNum - 1));
			
			g_iForward_PlayerBecomeLast_ItemsNum++;
		}
		case JB_PlayerBecomeSimon:
		{
			if((aForward[AI_FORWARD_B_POST] = bPost))
			{
				aForward[AI_FORWARD_ID] = CreateMultiForward(szCallBack, ET_IGNORE, FP_CELL);
			}
			else
			{
				aForward[AI_FORWARD_ID] = CreateMultiForward(szCallBack, ET_CONTINUE, FP_CELL);
			}
			aForward[AI_FORWARD_B_DISABLE] = false;

			ArrayPushArray(g_aForward, aForward);

			ArrayPushCell(g_aForward_PlayerBecomeSimon, (++g_iForward_ItemsNum - 1));
			
			++g_iForward_PlayerBecomeSimon_ItemsNum;
		}
		case JB_FreeDayStart:
		{
			if(!bPost) return INVALID_HOOKJAILBREAK;

			aForward[AI_FORWARD_B_POST] = true;
			aForward[AI_FORWARD_B_DISABLE] = false;
			aForward[AI_FORWARD_ID] = CreateMultiForward(szCallBack, ET_CONTINUE);

			ArrayPushArray(g_aForward, aForward);

			ArrayPushCell(g_aForward_FreeDayStart, (++g_iForward_ItemsNum - 1));
			
			g_iForward_FreeDayStart_ItemsNum++;
		}
		case JB_FreeDayEnd:
		{
			if(!bPost) return INVALID_HOOKJAILBREAK;

			aForward[AI_FORWARD_B_POST] = true;
			aForward[AI_FORWARD_B_DISABLE] = false;
			aForward[AI_FORWARD_ID] = CreateMultiForward(szCallBack, ET_IGNORE);

			ArrayPushArray(g_aForward, aForward);

			ArrayPushCell(g_aForward_FreeDayEnd, (++g_iForward_ItemsNum - 1));
			
			g_iForward_FreeDayEnd_ItemsNum++;
		}
		case JB_PlayerBecomeFree:
		{
			if((aForward[AI_FORWARD_B_POST] = bPost))
			{
				aForward[AI_FORWARD_ID] = CreateMultiForward(szCallBack, ET_IGNORE, FP_CELL);
			}
			else
			{
				aForward[AI_FORWARD_ID] = CreateMultiForward(szCallBack, ET_CONTINUE, FP_CELL);
			}
			aForward[AI_FORWARD_B_DISABLE] = false;

			ArrayPushArray(g_aForward, aForward);

			ArrayPushCell(g_aForward_PlayerBecomeFree, (++g_iForward_ItemsNum - 1));
			
			g_iForward_PlayerBecomeFree_ItemsNum++;
		}
		case JB_PlayerResetFree:
		{
			if(!bPost) return INVALID_HOOKJAILBREAK;

			aForward[AI_FORWARD_B_POST] = true;
			aForward[AI_FORWARD_B_DISABLE] = false;
			aForward[AI_FORWARD_ID] = CreateMultiForward(szCallBack, ET_IGNORE, FP_CELL);

			ArrayPushArray(g_aForward, aForward);

			ArrayPushCell(g_aForward_PlayerResetFree, (++g_iForward_ItemsNum - 1));
			
			g_iForward_PlayerResetFree_ItemsNum++;
		}
		case JB_PlayerBecomeWanted:
		{
			if((aForward[AI_FORWARD_B_POST] = bPost))
			{
				aForward[AI_FORWARD_ID] = CreateMultiForward(szCallBack, ET_IGNORE, FP_CELL);
			}
			else
			{
				aForward[AI_FORWARD_ID] = CreateMultiForward(szCallBack, ET_CONTINUE, FP_CELL);
			}
			aForward[AI_FORWARD_B_DISABLE] = false;

			ArrayPushArray(g_aForward, aForward);

			ArrayPushCell(g_aForward_PlayerBecomeWanted, (++g_iForward_ItemsNum - 1));
			
			g_iForward_PlayerBecomeWanted_ItemsNum++;
		}
		case JB_PlayerResetWanted:
		{
			if(!bPost) return INVALID_HOOKJAILBREAK;

			aForward[AI_FORWARD_B_POST] = true;
			aForward[AI_FORWARD_B_DISABLE] = false;
			aForward[AI_FORWARD_ID] = CreateMultiForward(szCallBack, ET_IGNORE, FP_CELL);

			ArrayPushArray(g_aForward, aForward);

			ArrayPushCell(g_aForward_PlayerResetWanted, (++g_iForward_ItemsNum - 1));
			
			g_iForward_PlayerResetWanted_ItemsNum++;
		}
		case JB_ChooseTeam:
		{
			if((aForward[AI_FORWARD_B_POST] = bPost))
			{
				aForward[AI_FORWARD_ID] = CreateMultiForward(szCallBack, ET_IGNORE, FP_CELL, FP_CELL);
			}
			else
			{
				aForward[AI_FORWARD_ID] = CreateMultiForward(szCallBack, ET_CONTINUE, FP_CELL, FP_CELL);
			}
			aForward[AI_FORWARD_B_DISABLE] = false;

			ArrayPushArray(g_aForward, aForward);

			ArrayPushCell(g_aForward_ChooseTeam, (++g_iForward_ItemsNum - 1));
			
			g_iForward_ChooseTeam_ItemsNum++;
		}
	}
	DEBUG_LOG("*** Forward Hook -> %s = %d", szCallBack, aForward[AI_FORWARD_ID]);

	if(aForward[AI_FORWARD_ID])
	{
		return HookJailBreak:aForward[AI_FORWARD_ID];
	}

	return INVALID_HOOKJAILBREAK;
}

public bool:Native_DisableHookJailBreak(const HookJailBreak:iHookId)
{
	if(iHookId == INVALID_HOOKJAILBREAK)
		return false;
	
	for(new i = 0, aForward[ENUM_DATA_FORWARD]; i < g_iForward_ItemsNum; i++)
	{
		ArrayGetArray(g_aForward, i, aForward);

		if(aForward[AI_FORWARD_ID] == _:iHookId)
		{
			aForward[AI_FORWARD_B_DISABLE] = true;

			ArraySetArray(g_aForward, i, aForward);

			return true;
		}
	}

	return false;
}

public bool:Native_EnableHookJailBreak(const HookJailBreak:iHookId)
{
	if(iHookId == INVALID_HOOKJAILBREAK)
		return false;
	
	for(new i = 0, aForward[ENUM_DATA_FORWARD]; i < g_iForward_ItemsNum; i++)
	{
		ArrayGetArray(g_aForward, i, aForward);

		if(aForward[AI_FORWARD_ID] == _:iHookId)
		{
			aForward[AI_FORWARD_B_DISABLE] = false;

			ArraySetArray(g_aForward, i, aForward);

			return true;
		}
	}

	return false;
}

public bool:Native_DestroyHookJailBreak(const HookJailBreak:iHookId)
{
	if(iHookId == INVALID_HOOKJAILBREAK)
		return false;
	
	for(new i = 0, aForward[ENUM_DATA_FORWARD]; i < g_iForward_ItemsNum; i++)
	{
		ArrayGetArray(g_aForward, i, aForward);

		if(aForward[AI_FORWARD_ID] == _:iHookId)
		{
			DestroyForward(aForward[AI_FORWARD_ID]);

			aForward[AI_FORWARD_ID] = _:INVALID_HOOKJAILBREAK;
			
			ArraySetArray(g_aForward, i, aForward);
			
			// ArrayDeleteItem(g_aForward, i); g_iForward_ItemsNum--;
			
			// g_iForward_ItemsNum = ArraySize(g_aForward);

			return true;
		}
	}

	return false;
}

public Native_RegisterMainMenuItem(const MenuItem:iPosition, const szName[], const szInfo[], const iSpace)
{
	if(iPosition < MENU_ITEM_1 || iPosition > MENU_ITEM_9)
		return ITEM_NULL;

	param_convert(2); param_convert(3);
	
	new aMainMenu[ENUM_DATA_MAIN_MENU];
	copy(aMainMenu[AI_MAIN_MENU_NAME], charsmax(aMainMenu[AI_MAIN_MENU_NAME]), szName);
	copy(aMainMenu[AI_MAIN_MENU_INFO], charsmax(aMainMenu[AI_MAIN_MENU_INFO]), szInfo);
	
	aMainMenu[AI_MAIN_MENU_SPACE] = iSpace;
	aMainMenu[AI_MAIN_MENU_POSITION] = iPosition;

	new iIndex = _:iPosition - 1;
	ArraySetArray(g_aMainMenu, iIndex, aMainMenu);

	return iIndex;
}

public Native_RegisterSimonMenuItem(const szFunction[], const szName[], const szInfo[], const iLimit, const bitsFlag)
{
	if(g_iSimonMenu_ItemsNum == MAX_MENU_ITEMS)
		return ITEM_NULL;

	param_convert(1); param_convert(2); param_convert(3);

	new aSimonMenu[ENUM_DATA_SIMON_MENU];
	copy(aSimonMenu[AI_SIMON_MENU_NAME], charsmax(aSimonMenu[AI_SIMON_MENU_NAME]), szName);
	copy(aSimonMenu[AI_SIMON_MENU_INFO], charsmax(aSimonMenu[AI_SIMON_MENU_INFO]), szInfo);

	aSimonMenu[AI_SIMON_MENU_FLAG] = bitsFlag;

	aSimonMenu[AI_SIMON_MENU_LIMIT] = iLimit;

	aSimonMenu[AI_SIMON_MENU_ID] = CreateMultiForward(szFunction, ET_CONTINUE, FP_CELL);

	ArrayPushArray(g_aSimonMenu, aSimonMenu);

	return ++g_iSimonMenu_ItemsNum - 1;
}

//TODO: Native Advantage
/* public Native_RegisterSimonMenuItemAdvantage(const szFunction[], const szName[], const szInfo[], const iLimit, const bitsFlag)
{
	if(g_iSimonMenu_ItemsNum == MAX_MENU_ITEMS)
		return ITEM_NULL;

	param_convert(1); param_convert(2); param_convert(3);

	new aSimonMenu[ENUM_DATA_SIMON_MENU];
	copy(aSimonMenu[AI_SIMON_MENU_NAME], charsmax(aSimonMenu[AI_SIMON_MENU_NAME]), szName);
	copy(aSimonMenu[AI_SIMON_MENU_INFO], charsmax(aSimonMenu[AI_SIMON_MENU_INFO]), szInfo);

	aSimonMenu[AI_SIMON_MENU_FLAG] = bitsFlag;

	aSimonMenu[AI_SIMON_MENU_LIMIT] = iLimit;

	aSimonMenu[AI_SIMON_MENU_ID] = CreateMultiForward(szFunction, ET_CONTINUE, FP_CELL);

	ArrayPushArray(g_aSimonMenu, aSimonMenu);

	return ++g_iSimonMenu_ItemsNum - 1;
} */

public Native_RegisterPlayersMenu(const szFunction[], const bitsTeam, const bitsAlive)
{
	if(g_iPlayersMenu_ItemsNum == MAX_MENU_ITEMS)
		return ITEM_NULL;

	param_convert(1);

	ArrayPushCell(g_aPlayersMenu, CreateMultiForward(szFunction, ET_IGNORE, FP_CELL, FP_CELL));

	return ++g_iPlayersMenu_ItemsNum - 1;
}

public Native_UpdateInformerUp(const pId)
{
	Jb_UpdateInformer_Up(pId);
}

public Native_UpdateInformerDown(const pId)
{
	Jb_UpdateInformer_Down(pId);
}

public Native_UpdateMenuItem(/* const szText[], any:... */)
{
	vdformat(g_szMenuItem, charsmax(g_szMenuItem), 1, 2);
}

public Native_UpdateMenuItemInfo(/* const szText[], any:... */)
{
	vdformat(g_szMenuItem_Info, charsmax(g_szMenuItem_Info), 1, 2);
}

public Native_GetRound()
{
	return g_iRound;
}

public Native_ShowMenuMain(const pId)
{
	new TeamName:iTeam = get_member(pId, m_iTeam);

	if(iTeam == TEAM_SPECTATOR || iTeam == TEAM_UNASSIGNED)
	{
		ShowMenu_Team(pId);
	}
	else
	{
		ShowMenu_Main(pId);
	}
}

public Native_ShowMenuTeam(const pId)
{
	ShowMenu_Team(pId);
}

public Native_ShowMenuSimon(const pId, const bool:bSaved)
{
	if(bSaved)
	{
		_MENU_CALLBACK_SIMON(Saved, pId);
	}
	else
	{
		_MENU_CALLBACK_SIMON(New, pId);
	}
}

public Native_ShowMenuPlayers(const pId, const iMenuId, const bool:bSaved)
{
	if(bSaved)
	{
		_MENU_CALLBACK_PLAYERS(Saved, pId, iMenuId);
	}
	else
	{
		_MENU_CALLBACK_PLAYERS(New, pId, iMenuId);
	}
}

public Native_ShowMenuLast(const pId, const bool:bSaved)
{
	if(bSaved)
	{
		// _MENU_CALLBACK_LAST(Saved, pId);
	}
	else
	{
		// _MENU_CALLBACK_LAST(New, pId);
	}
}