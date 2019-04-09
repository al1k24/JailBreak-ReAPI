#if defined _jailbreak_util_const_included
	#endinput
#endif
#define _jailbreak_util_const_included

#define NULL                    0

#define MAX_MENU_ITEMS			21

#define ITEM_NULL               -1
#define STRING_NULL             ""

#define DIR_LOG					"addons/amxmodx/logs/jailbreak"

const MsgId_VoiceMask			= 64;
const MsgId_ReqState			= 65;
const MsgId_CurWeapon 			= 66;
const MsgId_Geiger				= 67;
const MsgId_Flashlight			= 68;
const MsgId_FlashBat			= 69;
const MsgId_Health				= 70;
const MsgId_Damage				= 71;
const MsgId_Battery				= 72;
const MsgId_Train				= 73;
const MsgId_HudTextPro			= 74;
const MsgId_HudText				= 75;
const MsgId_SayText				= 76;
const MsgId_TextMsg				= 77;
const MsgId_WeaponList			= 78;
const MsgId_ResetHUD			= 79;
const MsgId_InitHUD				= 80;
const MsgId_ViewMode			= 81;
const MsgId_GameTitle			= 82;
const MsgId_DeathMsg			= 83;
const MsgId_ScoreAttrib			= 84;
const MsgId_ScoreInfo			= 85;
const MsgId_TeamInfo			= 86;
const MsgId_TeamScore			= 87;
const MsgId_GameMode			= 88;
const MsgId_MOTD				= 89;
const MsgId_ServerName			= 90;
const MsgId_AmmoPickup			= 91;
const MsgId_WeapPickup			= 92;
const MsgId_ItemPickup			= 93;
const MsgId_HideWeapon			= 94;
const MsgId_SetFOV				= 95;
const MsgId_ShowMenu			= 96;
const MsgId_ScreenShake			= 97;
const MsgId_ScreenFade			= 98;
const MsgId_AmmoX				= 99;
const MsgId_SendAudio			= 100;
const MsgId_RoundTime			= 101;
const MsgId_Money				= 102;
const MsgId_ArmorType			= 103;
const MsgId_BlinkAcct			= 104;
const MsgId_StatusValue			= 105;
const MsgId_StatusText			= 106;
const MsgId_StatusIcon			= 107;
const MsgId_BarTime				= 108;
const MsgId_ReloadSound			= 109;
const MsgId_Crosshair			= 110;
const MsgId_NVGToggle			= 111;
const MsgId_Radar				= 112;
const MsgId_Spectator			= 113;
const MsgId_VGUIMenu			= 114;
const MsgId_TutorText			= 115;
const MsgId_TutorLine			= 116;
const MsgId_TutorState			= 117;
const MsgId_TutorClose			= 118;
const MsgId_AllowSpec			= 119;
const MsgId_BombDrop			= 120;
const MsgId_BombPickup			= 121;
const MsgId_ClCorpse			= 122;
const MsgId_HostagePos			= 123;
const MsgId_HostageK			= 124;
const MsgId_HLTV				= 125;
const MsgId_SpecHealth			= 126;
const MsgId_ForceCam			= 127;
const MsgId_ADStop				= 128;
const MsgId_ReceiveW			= 129;
const MsgId_CZCareer			= 130;
const MsgId_CZCareerHUD			= 131;
const MsgId_ShadowIdx			= 132;
const MsgId_TaskTime			= 133;
const MsgId_Scenario			= 134;
const MsgId_BotVoice			= 135;
const MsgId_BuyClose			= 136;
const MsgId_SpecHealth2			= 137;
const MsgId_BarTime2			= 138;
const MsgId_ItemStatus			= 139;
const MsgId_Location			= 140;
const MsgId_BotProgress			= 141;
const MsgId_Brass				= 142;
const MsgId_Fog					= 143;
const MsgId_ShowTimer			= 144;
const MsgId_HudTextArgs			= 145;

enum _:ENUM_DATA_COLORS
{
	COLOR_R,
	COLOR_G,
	COLOR_B
};

#if defined _reapi_included
	
	const TeamName:TEAM_GUARD = TEAM_CT;
	const TeamName:TEAM_PRISONER = TEAM_TERRORIST;

#endif