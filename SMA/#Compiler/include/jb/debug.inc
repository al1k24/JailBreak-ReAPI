/** szMessage */
#define DEBUG_LOG log_amx

/** pId, szMessage */
#define DEBUG_MSG(%1,%2) client_print(%1, print_chat, %2)

Debug_Init()
{
    register_clcmd("say /he", "_he");
    register_clcmd("say /money+", "_money_plus");
    register_clcmd("say /money-", "_money_minus");
    register_clcmd("say /money0", "_money0");

    register_clcmd("say /respawn", "_respawn");

    register_clcmd("say /deagle", "_deagle");
    register_clcmd("say /t1", "_round_time");
    register_clcmd("say /t2", "_round_time2");
}

public _deagle(const pId) rg_give_item(pId, "weapon_deagle");
public _he(const pId) rg_give_item(pId, "weapon_hegrenade");
public _respawn(const pId) rg_round_respawn(pId);
public _money0(const pId) UTIL_SetMoney(pId, 0);
public _money_plus(const pId) UTIL_SetMoney(pId, g_iMoney[pId] + 1000);
public _money_minus(const pId) UTIL_SetMoney(pId, g_iMoney[pId] - 1000);
public _round_time(const pId) UTIL_RoundTime(pId, 10, true);
public _round_time2(const pId) UTIL_RoundTimeHide(pId);