#include amxmodx
#include reapi

#include jailbreak

#define PLUGIN 	"[JB] Addon: Main Menu"
#define VERSION	"13.10.2018"
#define AUTHOR	"ALIK"

enum _:ENUM_DATA_ITEMS
{
	ITEM_1,
	ITEM_2,
	ITEM_3,
	ITEM_4,
	ITEM_5,
	ITEM_6,
	ITEM_7,
	ITEM_8,
	ITEM_9
};
new g_iItemId[ENUM_DATA_ITEMS];
	
	/** MENU_ITEM_ */
	#define ITEM(%0) g_iItemId[%0]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	ITEM(ITEM_1) = RegisterMainMenuItem(MENU_ITEM_1, "#Jb_Menu_Main_Item_1");
	ITEM(ITEM_4) = RegisterMainMenuItem(MENU_ITEM_4, "#Jb_Menu_Main_Item_4_3");
	ITEM(ITEM_5) = RegisterMainMenuItem(MENU_ITEM_5, "#Jb_Menu_Main_Item_5");
}

public jb_main_menu_opened(const pId, const iItemId)
{
	if(iItemId == ITEM(ITEM_1))
	{
		if(IsRound(ROUND_RESTART) || IsRound(ROUND_END))
		{
			jb_update_menu_item_info("%L", pId, "#Jb_Menu_Disable_3");
			
			return JB_HANDLED;
		}
	}
	else if(iItemId == ITEM(ITEM_4))
	{
		switch(get_member(pId, m_iTeam))
		{
			case TEAM_PRISONER:
			{
				jb_update_menu_item("%L", pId, "#Jb_Menu_Main_Item_4_1");

				if(!jb_is_user_last(pId))
				{
					jb_update_menu_item_info("%L", pId, "#Jb_Menu_Disable_3");

					return JB_HANDLED;
				}
			}
			case TEAM_GUARD:
			{
				new iSimon = jb_get_simon_id();
				if(!iSimon)
				{
					jb_update_menu_item("%L", pId, "#Jb_Menu_Main_Item_4_3");

					if(IsRound(ROUND_RESTART) || IsRound(ROUND_END) || !IsAlive(pId))
					{
						jb_update_menu_item_info("%L", pId, "#Jb_Menu_Disable_3");

						return JB_HANDLED;
					}
				}
				else
				{
					if(iSimon == pId)
					{
						jb_update_menu_item("%L", pId, "#Jb_Menu_Main_Item_4_2");
					}
					else
					{
						jb_update_menu_item("%L", pId, "#Jb_Menu_Main_Item_4_3");
						jb_update_menu_item_info("%L", pId, "#Jb_Menu_Disable_3");
			
						return JB_HANDLED;
					}
				}
			}
		}
	}
	return JB_CONTINUE;
}

public jb_main_menu_item_selected(const pId, const MenuItem:iPosition)
{
	switch(iPosition)
	{
		case MENU_ITEM_1: return Jb_MainMenuItem_Shop(pId);
		case MENU_ITEM_4:
		{
			switch(get_member(pId, m_iTeam))
			{
				case TEAM_PRISONER: return Jb_MainMenuItem_Last(pId);
				case TEAM_GUARD: return Jb_MainMenuItem_Simon(pId);
			}
		}
		case MENU_ITEM_5: return Jb_MainMenuItem_Team(pId);
	}

	return JB_CONTINUE;
}

public Jb_MainMenuItem_Shop(const pId)
{
	if(IsRound(ROUND_RESTART) || IsRound(ROUND_END))
		return JB_HANDLED;
	
	// JB_ShowMenu_Shop(pId);

	PRINT_CHAT(pId, "*** SHOP");
	
	return JB_CONTINUE;
}

public Jb_MainMenuItem_Team(const pId)
{
	jb_show_menu_team(pId);

	return JB_CONTINUE;
}

public Jb_MainMenuItem_Simon(const pId)
{
	if(!IsTeam(pId, TEAM_GUARD))
		return JB_HANDLED;

	new iSimon = jb_get_simon_id();
	if(!iSimon)
	{
		if(IsRound(ROUND_RESTART) || IsRound(ROUND_END) || !IsAlive(pId))
			return JB_HANDLED;

		jb_set_user_simon(pId);
		jb_show_menu_simon(pId);
	}
	else
	{
		if(iSimon != pId)
			return JB_HANDLED;

		jb_show_menu_simon(pId);
	}

	return JB_CONTINUE;
}

public Jb_MainMenuItem_Last(const pId)
{
    if(!IsTeam(pId, TEAM_PRISONER) || !jb_is_user_last(pId))
        return JB_HANDLED;

    jb_show_menu_last(pId);

    return JB_CONTINUE;
}