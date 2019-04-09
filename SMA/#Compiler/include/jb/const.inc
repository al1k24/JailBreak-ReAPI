#if defined _jailbreak_const_included
	#endinput
#endif
#define _jailbreak_const_included

/**
* HookJailBreak тип возврата
*/

#define JB_CONTINUE 0
#define JB_HANDLED 1

enum HookJailBreak
{
    INVALID_HOOKJAILBREAK = 0
};

/**
* Отлавливаемые события 
*/
enum JailBreak
{
    /*
    * Описание:         -
    * Параметры:        [POST]: ()
    */
    JB_RestartStart,

    /*
    * Описание:         -
    * Параметры:        [POST]: ()
    */
    JB_RestartEnd,

    /*
    * Описание:         -
    * Параметры:        [POST]: ()
    */
    JB_RoundStart,
    
    /*
    * Описание:         -
    * Параметры:        [POST]: ()
    */
    JB_RoundEnd,

    /*
    * Описание:         Выбор последнего заключённого.
    * Параметры:        [PRE]: ()
    */
    JB_Last,

    /*
    * Описание:         Игрок становится последним.
    * Параметры:        [POST]: (const pId)
    */
    JB_PlayerBecomeLast,

    /*
    * Описание:         Игрок становится саймоном.
    * Параметры:        [PRE]: (const pId)
    *                   [POST]: (const pId)
    */
    JB_PlayerBecomeSimon,

    /*
    * Описание:         Начало свободного дня.
    * Параметры:        [POST]: ()
    */
    JB_FreeDayStart,

    /*
    * Описание:         Конец свободного дня.
    * Параметры:        [POST]: ()
    */
    JB_FreeDayEnd,

    /*
    * Описание:         Игрок становится свободным.
    * Параметры:        [PRE]: (const pId)
    *                   [POST]: (const pId)
    */
    JB_PlayerBecomeFree,

    /*
    * Описание:         Игрок перестаёт быть свободным.
    * Параметры:        [POST]: (const pId)
    */
    JB_PlayerResetFree,

    /*
    * Описание:         Игрок становится бунтующим.
    * Параметры:        [PRE]: (const pId)
    *                   [POST]: (const pId)
    */
    JB_PlayerBecomeWanted,

    /*
    * Описание:         Игрок перестаёт быть бунтующим.
    * Параметры:        [POST]: (const pId)
    */
    JB_PlayerResetWanted,

    /*
    * Описание:         Игрок выбирает новую команду.
    * Параметры:        [PRE]: (const pId, const TeamName:iChooseTeam)
    *                   [POST]: (const pId, const TeamName:iChooseTeam)
    */
    JB_ChooseTeam
};

enum MenuItem
{
	MENU_ITEM_1 = 1,
	MENU_ITEM_2,
	MENU_ITEM_3,
	MENU_ITEM_4,
	MENU_ITEM_5,
	MENU_ITEM_6,
	MENU_ITEM_7,
	MENU_ITEM_8,
	MENU_ITEM_9
};

enum UserSex
{
	SEX_MALE,
	SEX_FEMALE
};

enum _:ENUM_DATA_ROUND
{
	ROUND_RESTART,

	ROUND_END,
	ROUND_START
};

enum DayMode
{
	DAY_MODE_NULL,

	DAY_MODE_NORMAL,
	DAY_MODE_FREE_DAY,

	DAY_MODE_GAME
};

enum VoiceSpeak
{
	VOICE_SPEAK_ALL,
	VOICE_SPEAK_GUARD,
	VOICE_SPEAK_SIMON
};