#include amxmodx

#include jailbreak

#define PLUGIN  "[JB] Simon menu item: Advantages"
#define VERSION "07.02.2019"
#define AUTHOR  "ALIK"

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    
    RegisterSimonMenuItem("Jb_SimonMenuItem_Advantages", "#Jb_Menu_Simon_Item_9");

    register_clcmd("radio1", "ClCmdHook_Radio1");
}

public ClCmdHook_Radio1(const pId)
{
    if(!jb_is_user_simon(pId))
        return PLUGIN_CONTINUE;
    
    Jb_SimonMenuItem_Advantages(pId);

    return PLUGIN_HANDLED_MAIN;
}

public Jb_SimonMenuItem_Advantages(const pId)
{
    PRINT_CHAT(pId, "* Jb_SimonMenuItem_Advantages");

    return JB_CONTINUE;
}