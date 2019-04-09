#if defined _jailbreak_core_included
	#endinput
#endif
#define _jailbreak_core_included

#include "jb\const.inc"
#include "jb\util_const.inc"

native HookJailBreak:RegisterHookJailBreak({JailBreak}:iFunctionId, const szFunction[], const bool:bPost = false);

native bool:EnableHookJailBreak(HookJailBreak:iHookId);
native bool:DisableHookJailBreak(HookJailBreak:iHookId);
native bool:DestroyHookJailBreak(HookJailBreak:iHookId);

native jb_get_round();

    /** ROUND_ */
    #define IsRound(%0) (bool:(jb_get_round() == %0))

native bool:jb_set_user_simon(const pId);

native bool:jb_transfer_simon(const pId, const iPlayer);

native jb_get_user_sex(const pId);
native jb_set_user_sex(const pId, const UserSex:iSex);
native jb_set_user_team(const pId, const TeamName:iTeam, const bool:bKill = true);

//Виртуальные деньги / bMoney -> true - Обновляется переменная, false - обновляется только худ
native jb_get_user_money(const pId);
native jb_set_user_money(const pId, const iMoney, const bool:bMoney = true);

native jb_open_doors();
native jb_close_doors();
native bool:jb_get_doors_status();

native jb_update_informer_up(const pId);
native jb_update_informer_down(const pId);

native jb_get_last_id();
native jb_get_simon_id();

native bool:jb_is_user_last(const pId);
native bool:jb_is_user_simon(const pId);
native bool:jb_is_user_voice(const pId);

native jb_show_menu_main(const pId);
native jb_show_menu_team(const pId);
native jb_show_menu_last(const pId, const bool:bSaved = false);
native jb_show_menu_simon(const pId, const bool:bSaved = false);
native jb_show_menu_players(const pId, const iMenuId, const bool:bSaved = false);

native jb_get_day();

native DayMode:jb_get_day_mode();
    
    /** DAY_MODE_ */
    #define IsDayMode(%0) (bool:(jb_get_day_mode() == %0))

native jb_set_day_mode(DayMode:iDayMode);
native jb_reset_day_mode(DayMode:iDayMode);

native jb_reset_free_day();

native jb_set_user_voice(const pId);
native jb_reset_user_voice(const pId);

native jb_set_voice_speak(const VoiceSpeak:iType);

forward jb_main_menu_opened(const pId, const iItemId);
forward jb_main_menu_item_selected(const pId, const MenuItem:iPosition);

forward jb_simon_menu_opened(const pId, const iItemId);

forward jb_players_menu_loaded(const pId, const iPlayer, const iItemId);
forward jb_players_menu_opened(const pId, const iPlayer, const iItemId);

native jb_update_menu_item(const szText[64], any:...);
native jb_update_menu_item_info(const szText[64], any:...);

native RegisterMainMenuItem(const MenuItem:iPosition, const szName[64], const szInfo[64] = STRING_NULL, const iSpace = 0);

native RegisterSimonMenuItem(const szFunction[], const szName[64], const szInfo[64] = STRING_NULL, const iLimit = -1, const bitsFlag = -1);

native RegisterPlayersMenu(const szFunction[]);