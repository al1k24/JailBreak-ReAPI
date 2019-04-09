#include amxmodx
#include fakemeta
#include reapi
#include json

#include jailbreak

#define PLUGIN 	"[JB] Addon: Player Model"
#define VERSION	"08.08.2018"
#define AUTHOR	"ALIK"

enum _:ENUM_DATA_BODY
{
	BODY_GUARD,
	BODY_SIMON,
	BODY_PRISONER
};
new g_iBody[ENUM_DATA_BODY] = { -1, -1, -1 };

new Array:g_aPrisonerSkins,
	
	g_iPrisonerSkins_ItemsNum;

enum _:ENUM_DATA_SKIN
{
	SKIN_NORMAL,
	SKIN_FREE,
	SKIN_WANTED
};
new g_iSkin[ENUM_DATA_SKIN] = { -1, -1, -1 };

new Trie:g_tModel;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	RegisterHookChain(RG_CBasePlayer_Spawn, "RGHook_CBasePlayer_Spawn_Post", true);

	RegisterHookJailBreak(JB_PlayerBecomeFree, "JBHook_PlayerBecomeFree_Post", true);
	RegisterHookJailBreak(JB_PlayerBecomeSimon, "JBHook_PlayerBecomeSimon_Post", true);
	RegisterHookJailBreak(JB_PlayerBecomeWanted, "JBHook_PlayerBecomeWanted_Post", true);
}

public plugin_precache()
{
	g_tModel = TrieCreate();

	g_aPrisonerSkins = ArrayCreate();

	JSON_Precache();
}

public RGHook_CBasePlayer_Spawn_Post(const pId)
{
	if(!IsAlive(pId))
		return;

	switch(get_member(pId, m_iTeam))
	{
		case TEAM_PRISONER:
		{
			if(TrieKeyExists(g_tModel, "prisoner"))
			{
				new szModel[8];
				TrieGetString(g_tModel, "prisoner", szModel, charsmax(szModel));

				rg_set_user_model(pId, szModel, true);

				if(g_iBody[BODY_PRISONER] > -1)
				{
					set_entvar(pId, var_body, g_iBody[BODY_PRISONER]);
				}

				if(g_iPrisonerSkins_ItemsNum > 0)
				{
					set_entvar(pId, var_skin, ArrayGetCell(g_aPrisonerSkins, random(g_iPrisonerSkins_ItemsNum)));
				}
			}
		}
		case TEAM_GUARD:
		{
			if(TrieKeyExists(g_tModel, "guard"))
			{
				new szModel[8];
				TrieGetString(g_tModel, "guard", szModel, charsmax(szModel));

				rg_set_user_model(pId, szModel, true);

				if(g_iBody[BODY_GUARD] > -1)
				{
					set_entvar(pId, var_body, g_iBody[BODY_GUARD]);
				}
			}
		}
	}
}

public JBHook_PlayerBecomeFree_Post(const pId)
{
	if(g_iSkin[SKIN_FREE] > -1)
	{
		set_entvar(pId, var_skin, g_iSkin[SKIN_FREE]);
	}
}

public JBHook_PlayerBecomeWanted_Post(const pId)
{
	if(g_iSkin[SKIN_WANTED] > -1)
	{
		set_entvar(pId, var_skin, g_iSkin[SKIN_WANTED]);
	}
}

public JBHook_PlayerBecomeSimon_Post(const pId)
{
    if(TrieKeyExists(g_tModel, "simon"))
	{
		new szModel[8];
		TrieGetString(g_tModel, "simon", szModel, charsmax(szModel));

		rg_set_user_model(pId, szModel, true);

		if(g_iBody[BODY_SIMON] > -1)
		{
			set_entvar(pId, var_body, g_iBody[BODY_SIMON]);
		}
	}
}

JSON_Precache()
{
	new szFile[64], szDir[32]; GET_DIR(szDir);
	formatex
	(
		szFile, charsmax(szFile), "%s/jailbreak/json/PlayerModel.json", szDir
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
	
	/** Model */
	JSON_CreateObject_Model(oJSON);
	
	// [Конец]
	json_serial_to_file(oJSON, szFile, true);
	json_free(oJSON);
}

JSON_CreateObject_Model(&JSON:oJSON)
{
	new szBuffer[16];

	new JSON:oJSON_Value_Object, JSON:oJSON_Value = json_init_object();

	/** Simon */
	oJSON_Value_Object = json_init_object();

	formatex(szBuffer, charsmax(szBuffer), "vip");
	
	if(PRECACHE_MODEL("models/player/%s/%s.mdl", szBuffer, szBuffer) != -1)
	{
		TrieSetString(g_tModel, "simon", szBuffer);
	}
	json_object_set_string(oJSON_Value_Object, "player", szBuffer);
	json_object_set_number(oJSON_Value_Object, "body", g_iBody[BODY_SIMON]);

	json_object_set_value(oJSON_Value, "Simon", oJSON_Value_Object);
	json_free(oJSON_Value_Object);

	/** Guard */
	oJSON_Value_Object = json_init_object();

	formatex(szBuffer, charsmax(szBuffer), "gign");
	
	if(PRECACHE_MODEL("models/player/%s/%s.mdl", szBuffer, szBuffer) != -1)
	{
		TrieSetString(g_tModel, "guard", szBuffer);
	}
	json_object_set_string(oJSON_Value_Object, "player", szBuffer);
	json_object_set_number(oJSON_Value_Object, "body", g_iBody[BODY_GUARD]);

	json_object_set_value(oJSON_Value, "Guard", oJSON_Value_Object);
	json_free(oJSON_Value_Object);

	/** Prisoner */
	oJSON_Value_Object = json_init_object();

	formatex(szBuffer, charsmax(szBuffer), "terror");
	
	if(PRECACHE_MODEL("models/player/%s/%s.mdl", szBuffer, szBuffer) != -1)
	{
		TrieSetString(g_tModel, "prisoner", szBuffer);
	}
	json_object_set_string(oJSON_Value_Object, "player", szBuffer);
	json_object_set_number(oJSON_Value_Object, "body", g_iBody[BODY_PRISONER]);

	new JSON:oJSON_Array_PrisonerSkin = json_init_array();
	json_array_append_number(oJSON_Array_PrisonerSkin, 0);

	new JSON:oJSON_Object_PrisonerSkin = json_init_object();

	json_object_set_value(oJSON_Object_PrisonerSkin, "normal", oJSON_Array_PrisonerSkin);
	json_free(oJSON_Array_PrisonerSkin);

	json_object_set_number(oJSON_Object_PrisonerSkin, "free", -1);
	json_object_set_number(oJSON_Object_PrisonerSkin, "wanted", -1);

	json_object_set_value(oJSON_Value_Object, "skin", oJSON_Object_PrisonerSkin);
	
	json_object_set_value(oJSON_Value, "Prisoner", oJSON_Value_Object);
	json_free(oJSON_Value_Object);
	
	json_object_set_value(oJSON, "Model", oJSON_Value);
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

	/** Model */
	JSON_ReadObject_Model(oJSON_Parse);

	json_free(oJSON_Parse);
}

JSON_ReadObject_Model(const JSON:oJSON_Parse)
{
	if(json_object_has_value(oJSON_Parse, "Model", JSONObject, true))
	{
		new szBuffer[16];

		new JSON:oJSON_Key = json_object_get_value(oJSON_Parse, "Model", true);

		// Simon
		if(json_object_has_value(oJSON_Key, "Simon", JSONObject, true))
		{
			new JSON:oJSON_Key_Object = json_object_get_value(oJSON_Key, "Simon", true);

			if(json_object_has_value(oJSON_Key_Object, "player", JSONString, true))
			{
				json_object_get_string(oJSON_Key_Object, "player", szBuffer, charsmax(szBuffer), false);

				if(PRECACHE_MODEL("models/player/%s/%s.mdl", szBuffer, szBuffer) != -1)
				{
					TrieSetString(g_tModel, "simon", szBuffer);
				}
			}
			else
			{
				UTIL_Log("Error", "%s | JSONx001: Model->Simon->player", PLUGIN);
			}

			if(TrieKeyExists(g_tModel, "simon"))
			{
				if(json_object_has_value(oJSON_Key_Object, "body", JSONNumber, true))
				{
					g_iBody[BODY_SIMON] = json_object_get_number(oJSON_Key_Object, "body");
				}
				else
				{
					UTIL_Log("Error", "%s | JSONx001: Model->Simon->body", PLUGIN);
				}
			}

			json_free(oJSON_Key_Object);
		}
		else
		{
			UTIL_Log("Error", "%s | JSONx001: Model->Simon", PLUGIN);
		}

		// Guard
		if(json_object_has_value(oJSON_Key, "Guard", JSONObject, true))
		{
			new JSON:oJSON_Key_Object = json_object_get_value(oJSON_Key, "Guard", true);

			if(json_object_has_value(oJSON_Key_Object, "player", JSONString, true))
			{
				json_object_get_string(oJSON_Key_Object, "player", szBuffer, charsmax(szBuffer), false);

				if(PRECACHE_MODEL("models/player/%s/%s.mdl", szBuffer, szBuffer) != -1)
				{
					TrieSetString(g_tModel, "guard", szBuffer);
				}
			}
			else
			{
				UTIL_Log("Error", "%s | JSONx001: Model->Guard->player", PLUGIN);
			}

			if(TrieKeyExists(g_tModel, "guard"))
			{
				if(json_object_has_value(oJSON_Key_Object, "body", JSONNumber, true))
				{
					g_iBody[BODY_GUARD] = json_object_get_number(oJSON_Key_Object, "body");
				}
				else
				{
					UTIL_Log("Error", "%s | JSONx001: Model->Guard->body", PLUGIN);
				}
			}

			json_free(oJSON_Key_Object);
		}
		else
		{
			UTIL_Log("Error", "%s | JSONx001: Model->Guard", PLUGIN);
		}

		// Prisoner
		if(json_object_has_value(oJSON_Key, "Prisoner", JSONObject, true))
		{
			new JSON:oJSON_Key_Object = json_object_get_value(oJSON_Key, "Prisoner", true);

			if(json_object_has_value(oJSON_Key_Object, "player", JSONString, true))
			{
				json_object_get_string(oJSON_Key_Object, "player", szBuffer, charsmax(szBuffer), false);

				if(PRECACHE_MODEL("models/player/%s/%s.mdl", szBuffer, szBuffer) != -1)
				{
					TrieSetString(g_tModel, "prisoner", szBuffer);
				}
			}
			else
			{
				UTIL_Log("Error", "%s | JSONx001: Model->Prisoner->player", PLUGIN);
			}

			if(TrieKeyExists(g_tModel, "prisoner"))
			{
				if(json_object_has_value(oJSON_Key_Object, "body", JSONNumber, true))
				{
					g_iBody[BODY_PRISONER] = json_object_get_number(oJSON_Key_Object, "body");
				}
				else
				{
					UTIL_Log("Error", "%s | JSONx001: Model->Prisoner->body", PLUGIN);
				}

				if(json_object_has_value(oJSON_Key_Object, "skin", JSONObject, true))
				{
					new JSON:oJSON_Key_Object_Skin = json_object_get_value(oJSON_Key_Object, "skin", true);

					if(json_object_has_value(oJSON_Key_Object_Skin, "normal", JSONArray, true))
					{
						new JSON:oJSON_Key_Object_Skin_Array = json_object_get_value(oJSON_Key_Object_Skin, "normal", true);

						if(json_is_array(oJSON_Key_Object_Skin_Array))
						{
							for(new i = 0, iAmount = json_array_get_count(oJSON_Key_Object_Skin_Array); i < iAmount; i++)
							{
								ArrayPushCell(g_aPrisonerSkins, json_array_get_number(oJSON_Key_Object_Skin_Array, i));
							}
							
							if((g_iPrisonerSkins_ItemsNum = ArraySize(g_aPrisonerSkins)) > 0)
							{
								g_iSkin[SKIN_NORMAL] = 0;
							}
						}

						json_free(oJSON_Key_Object_Skin_Array);
					}
					else
					{
						UTIL_Log("Error", "%s | JSONx001: Model->Prisoner->skin->normal", PLUGIN);
					}

					if(json_object_has_value(oJSON_Key_Object_Skin, "free", JSONNumber, true))
					{
						g_iSkin[SKIN_FREE] = json_object_get_number(oJSON_Key_Object_Skin, "free");
					}
					else
					{
						UTIL_Log("Error", "%s | JSONx001: Model->Prisoner->skin->free", PLUGIN);
					}

					if(json_object_has_value(oJSON_Key_Object_Skin, "wanted", JSONNumber, true))
					{
						g_iSkin[SKIN_WANTED] = json_object_get_number(oJSON_Key_Object_Skin, "wanted");
					}
					else
					{
						UTIL_Log("Error", "%s | JSONx001: Model->Prisoner->skin->wanted", PLUGIN);
					}

					json_free(oJSON_Key_Object_Skin);
				}
				else
				{
					UTIL_Log("Error", "%s | JSONx001: Model->Prisoner->skin", PLUGIN);
				}
			}

			json_free(oJSON_Key_Object);
		}
		else
		{
			UTIL_Log("Error", "%s | JSONx001: Model->Prisoner", PLUGIN);
		}
		

		json_free(oJSON_Key);
	}
	else
	{
		UTIL_Log("Error", "%s | JSONx001: Model", PLUGIN);
	}
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