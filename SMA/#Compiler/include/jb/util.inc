#if defined _jailbreak_util_included
	#endinput
#endif
#define _jailbreak_util_included

#include "jb\util_const.inc"

#define DEBUG() return true
#define DEBUG_LOG() return true

//--------------------------------------------------------------------------------------------------------------------------------------------------

/** pId */
#define IsAlive(%1) (bool:(is_user_alive(%1)))

/** pId */
#define IsConnected(%1) (bool:(is_user_connected(%1)))

/** pId */
#define IsPlayer(%1) (bool:(%1 && %1 <= MaxClients))

/** pId, ADMIN_ */
#define IsFlag(%1,%2) (bool:(get_user_flags(%1) & %2))

/** pId, szMessage */
#define PRINT_CENTER(%1,%2) client_print(%1, print_center, %2)

/** pId, szMessage */
#define PRINT_CONSOLE(%1,%2) client_print(%1, print_console, %2)

/** pId, szMessage */
#define PRINT_CHAT(%1,%2) client_print(%1, print_chat, %2)

/** szSound */
#define IsMp3Format(%0) (bool:(equal(%0[strlen(%0)-4], ".mp3")))

/** szSound */
#define IsWavFormat(%0) (bool:(equal(%0[strlen(%0)-4], ".wav")))

/** szSound */
#define IsModelFormat(%0) (bool:(equal(%0[strlen(%0)-4], ".mdl")))

/** szDir */
#define GET_DIR(%0) get_localinfo("amxx_configsdir", %0, charsmax(%0))

/** szCurrentTime */
#define GET_TIME(%0) get_time("%m/%d/%Y", %0, charsmax(%0))

/** szMenu, iLen, szMenuTitle */
#define MENU_TITLE(%1,%2,%3) (%2 = formatex(%1[%2], charsmax(%1), %3))

/** szMenu[], iLen, szItemName */
#define MENU_ITEM(%1,%2,%3) (%2 += formatex(%1[%2], charsmax(%1) - %2, %3))

/** pId, bitsKeys, szMenu, szMenuId */
#define SHOW_MENU(%1,%2,%3,%4) show_menu(%1, %2, %3, -1, %4)

/** pId */
#define HIDE_MENU(%1) show_menu(%1, NULL, "^n")

/** iMenuKey */
#define KEY(%0) (1 << ((%0 + 9) % 10))

/** iMenuKey */
#define KEY_HANDLER(%0) ((%0 + 1) % 10)

/** szMenuId, szMenu_Handler */
#define RegisterMenu(%1,%2) register_menucmd(register_menuid(%1), 1023, %2)

#if defined _reapi_included
	
	const TeamName:TEAM_GUARD = TEAM_CT;
	const TeamName:TEAM_PRISONER = TEAM_TERRORIST;

	/** iEnt */
	#define IsValid is_entity

    /** pId, TEAM_ */
    #define IsTeam(%1,%2) (bool:(get_member(%1, m_iTeam) == %2))

    /** pId */
    #define IsPlayerJoined(%1) (bool:(get_member(%1, m_iJoiningState) == JOINED))

	stock rg_get_user_name(const pId)
	{
		new szName[32];
		get_entvar(pId, var_netname, szName, charsmax(szName));

		return szName;
	}

	/** pId, szName[] */
	#define rg_get_user_name2(%1,%2) get_entvar(%1, var_netname, %2, charsmax(%2))
	
	/** pId, szName[], iLen */
	#define rg_get_user_name3(%1,%2,%3) get_entvar(%1, var_netname, %2, %3)

	/** pId */
	#define rg_get_user_team(%1) get_member(%1, m_iTeam)
	
	/** pId */
	#define rg_get_user_health(%1) floatround(get_entvar(%1, var_health))

	/** pId, iHealth */
	#define rg_set_user_health(%1,%2) set_entvar(%1, var_health, float(%2))

#endif

#if defined _CHATPRINT_INCLUDED

	/** [ UTIL_SayText ]
	
		* Отсылает сообщение игроку в чат.
	
		@pId - Айди игрока.
		@szMessage - Сообщение игроку.
		
		[ 'szMessage' ]
		* '\g' - Зелёный цвет.
		* '\r' - Красный цвет.
		* '\n' - Простой цвет.
		* '\b' - Синий цвет.
		* '\w' - Белый цвет.
		* '\t' - Цвет команды.
		
		@return iMessageLen
	*/
	
	/** pId, szMessage */
	#define UTIL_SayText ChatPrint

#endif

stock UTIL_GetAuthId(pId)
{
	new szAuthId[32];
	get_user_authid(pId, szAuthId, charsmax(szAuthId));
	
	return szAuthId;
}

stock UTIL_Log(const szPrefix[], const szMessage[], any:...)
{
	if(!dir_exists(DIR_LOG))
	{
		mkdir(DIR_LOG);
	}
	
	new szCurrentTime[16]; GET_TIME(szCurrentTime);
	
	while(replace(szCurrentTime, charsmax(szCurrentTime), "/", "-")) {}
	
	new szDir[64];
	formatex
	(
		szDir, charsmax(szDir), "%s/%s_%s.log", DIR_LOG, szPrefix, szCurrentTime
	);
	
	static szLog[256];
	vformat(szLog, charsmax(szLog), szMessage, 3);
	
	log_to_file(szDir, szLog);
	
	// return strlen(szLog);
}

stock UTIL_FixTime(&iTimer)
{
	iTimer = iTimer > 0 ? min(3600, iTimer) : 0;
	
	new szTime[7], iMin = iTimer / 60, iSec = iTimer % 60;
	formatex
	(
		szTime, charsmax(szTime), "%02d:%02d", iMin, iSec
	);
	
	return szTime;
}

stock UTIL_IntToString(iValue)
{
	new szString[8];
	num_to_str(iValue, szString, charsmax(szString));
	
	return szString;
}

stock UTIL_HexToRgb(const szHex[])
{
	new szColor[ENUM_DATA_COLORS];
	
	if(szHex[0] != '#' && strlen(szHex) != 7)
	{
		szColor = {255, 255, 255}; return szColor;
	}
	
	szColor[COLOR_R] = UTIL_Parse16(szHex[1], szHex[2]);
	szColor[COLOR_G] = UTIL_Parse16(szHex[3], szHex[4]);
	szColor[COLOR_B] = UTIL_Parse16(szHex[5], szHex[6]);
	
	return szColor;
}

stock UTIL_Parse16(iValue1, iValue2)
{
	return UTIL_ParseHex(iValue1) * 16 + UTIL_ParseHex(iValue2);
}

stock UTIL_ParseHex(iValue)
{
	switch(iValue)
	{
		case '0'..'9': return iValue - '0';
		case 'a'..'z': return 10 + iValue - 'a';
		case 'A'..'Z': return 10 + iValue - 'A';
	}
	return 0;
}

stock UTIL_PlayWav(const pId, const szSound[])
{
	message_begin(pId ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, MsgId_SendAudio, _, pId);
	{
		write_byte(pId);
		write_string(szSound);
		write_short(PITCH_NORM);
	}
	message_end();
}

stock UTIL_PlayMp3(const pId, const szSound[], const bool:bReset = false)
{
	if(bReset)
	{
		client_cmd(pId, "mp3 stop");
	}
	
	client_cmd(pId, "mp3 play ^"sound/%s^"", szSound);
}

stock UTIL_StatusText(pId, const szMessage[], bool:bReliable = false)
{
	message_begin(bReliable ? MSG_ONE : MSG_ONE_UNRELIABLE, MsgId_StatusText, _, pId);
	{
		write_byte(0);
		write_string(szMessage);
	}
	message_end();
}