#include amxmodx
#include reapi

#include jailbreak

#define PLUGIN  "[JB] Addon: Check compatibility"
#define VERSION "13.05.2018"
#define AUTHOR  "ALIK"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	if(!is_rehlds())
	{
		UTIL_Log("Error", "%s | Должен использоваться ReHLDS!", PLUGIN);
	}

	if(!is_regamedll())
	{
		UTIL_Log("Error", "%s | Должен использоваться ReGameDLL!", PLUGIN);
	}
	
	#if AMXX_VERSION_NUM < 183
		UTIL_Log("Error", "%s | Версия AMXXMODX должна быть >= 1.8.3!", PLUGIN);
	#endif

	#if REAPI_VERSION < 56156
		UTIL_Log("Error", "%s | Версия ReAPI должна быть >= 5.6.0.156!", PLUGIN);
	#endif

	#if JAILBREAK_VERSION < 180513
		UTIL_Log("Error", "%s | Версия JailBreak должна быть >= 13.05.2018!", PLUGIN);
	#endif
}