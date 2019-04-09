/** В качестве шаблона использовались наработки от serfreeman1337 */

#include amxmodx
#include reapi
#include mysqlt

#include jailbreak

#define PLUGIN	"[JB] Save: MySQL"
#define VERSION	"20.10.2018"
#define AUTHOR	"ALIK"

#define CVAR_HOST       ""
#define CVAR_DATABASE   ""
#define CVAR_USER       ""
#define CVAR_PASSWORD   ""

#define CVAR_TABLE_1    "jb_user"

#define QUERY_LENGTH    1472 //X3 :D

#define TASK_FLUSH 20102018

/** szQuery[], iLen, szText */
#define FORMAT_QUERY(%1,%2,%3) (%2 += formatex(%1[%2], charsmax(%1) - %2, %3))

/** szQuery, eData */
#define QUERY(%0,%1) mysql_query(g_hConnection, "Sql_Handler", %0, %1, sizeof(%1))

/** szRow[] */
#define RESULT(%0) mysql_read_result(mysql_fieldnametonum(%0))

enum _:ENUM_DATA_SQL
{
	SQL_DUMMY,
	SQL_INIT,
	SQL_LOAD,
	SQL_UPDATE,
	SQL_INSERT,
	SQL_IGNORE
};
new Handle:g_hHost, Handle:g_hConnection;

new bool:g_bSql_IsReady;
	
	/** NULL */
	#define IsSqlReady() g_bSql_IsReady

enum _:ENUM_DATA_LOAD
{
	LOAD_NO,			// данных нет
	LOAD_WAIT,			// ожидание данных
	LOAD_WAIT_NEW,		// новая запись, ждем ответа
	LOAD_UPDATE,		// перезагрузить после обновления
	LOAD_NEW,			// новая запись
	LOAD_OK				// есть данные
};
new g_iState[33];

enum _:ENUM_DATA_USER
{
	USER_ID,
	USER_SEX,
	USER_MONEY,
	
	USER_TIME_ONLINE,
	
	USER_AUTH[32]
};
new g_eUser[33][ENUM_DATA_USER];

    /** pId, USER_ */
    #define USER(%1,%2) g_eUser[%1][%2]

new g_szFlushQuery[QUERY_LENGTH * 3], g_iLen_FlushQuery;

new g_iQueryNum;

new g_iOnlineTime[33];

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    set_task(0.1, "Task_LoadSql");
}

public plugin_end()
{
	// log_amx("*** [DB] plugin_end: query = %d", g_iQueryNum);
	
	// UTIL_Log("MySQL_Auth", "Карта - %s | Запросов в БД: %d", g_szMap, g_iQueryNum);
	
	DB_FlushQuery();
}

public client_putinserver(pId)
{
    // log_amx(" ** client_putinserver(%d)", pId);

    new szInfo[32];
    get_user_authid(pId, szInfo, charsmax(szInfo));
    
    copy(g_eUser[pId][USER_AUTH], charsmax(g_eUser[][USER_AUTH]), szInfo);

    if(IsSqlReady())
    {
        DB_LoadPlayerData(pId);
    }
}

public client_disconnected(pId)
{
    // log_amx(" ** client_disconnected(%d)", pId);

    DB_SavePlayerData(pId);

    g_eUser[pId][USER_ID] = 0;
    g_eUser[pId][USER_SEX] = 0;
    g_eUser[pId][USER_MONEY] = 0;
    
    g_eUser[pId][USER_TIME_ONLINE] = 0;

    g_eUser[pId][USER_AUTH][0] = EOS;

    g_iOnlineTime[pId] = 0;
}

public Task_LoadSql()
{
    g_hHost = mysql_makehost(CVAR_HOST, CVAR_USER, CVAR_PASSWORD, CVAR_DATABASE);

    new szError[128], iErrorNum;
    g_hConnection = mysql_connect(g_hHost, iErrorNum, szError, charsmax(szError));

    if(iErrorNum)
    {
        UTIL_Log("Error", "%s | SQL: [%d] - [%s]", PLUGIN, iErrorNum, szError); return;
    }
    
    mysql_performance(50, 50, 6);

    DB_Init();
}

public Task_FlushQuery()
{
    DB_FlushQuery();
}

public Sql_Handler(const iFailState, const szError[], const iError, const eData[], const iDataSize,  const Float:flQueueTime)
{
    if(!DB_CheckFailState(iFailState, iError, szError))
        return;

    switch(eData[0])
    {
        case SQL_INIT:
        {
            g_bSql_IsReady = true;

            for(new pId = 1; pId <= MaxClients; pId++)
            {
                if(!IsConnected(pId)) continue;

                if(g_iState[pId] != LOAD_OK)
                {
                    DB_LoadPlayerData(pId);
                }
            }

            // log_amx("[DB] Init: ok | time: %f", flQueueTime);
        }
        case SQL_LOAD:
        {
            new pId = eData[1];

            if(!IsConnected(pId)) return;

            if(mysql_num_results())
            {
                g_iState[pId] = LOAD_OK;
                g_iOnlineTime[pId] = get_systime();

                USER(pId, USER_ID) = RESULT("id");
                USER(pId, USER_TIME_ONLINE) = RESULT("online_time");

                jb_set_user_money(pId, (USER(pId, USER_MONEY) = RESULT("money")));
                jb_set_user_sex(pId, UserSex:(USER(pId, USER_SEX) = RESULT("sex")));

                // log_amx("[DB] Load: ok | time: %f", flQueueTime);
            }
            else
            {
                g_iState[pId] = LOAD_NEW;

                DB_SavePlayerData(pId);
            }
        }
        case SQL_UPDATE:
        {
            // обновляем позици игроков
            // действие с задержкой, что-бы учесть изменения при множественном обновлении данных
            // 0.1

            for(new pId = 1; pId <= MaxClients; pId++)
            {
                if(!IsConnected(pId)) continue;

                if(g_iState[pId] == LOAD_UPDATE)
                {
                    g_iState[pId] = LOAD_NO;

                    DB_LoadPlayerData(pId);
                }
            }
        }
        case SQL_INSERT:
        {
            new pId = eData[1];

            if(IsConnected(pId))
            {
                if(g_iState[pId] == LOAD_UPDATE)
                {
                    g_iState[pId] = LOAD_NO;

                    DB_LoadPlayerData(pId);
                }
                else
                {
                    g_iState[pId] = LOAD_OK;

                    DB_LoadPlayerData(pId);
                }
            }

            // обновляем позици игроков
            // действие с задержкой, что-бы учесть изменения при множественном обновлении данных
            // 1.0
        }
    }
}

bool:DB_CheckFailState(const iFailState, const iError, const szError[])
{
    ++g_iQueryNum;

    switch(iFailState)
    {
        case TQUERY_SUCCESS:
        {
            return true;
        }
        case TQUERY_CONNECT_FAILED:
        {
            UTIL_Log("Error", "%s | MySQL: #%d %s", PLUGIN, iError, szError);
        }
        case TQUERY_QUERY_FAILED:
        {
            UTIL_Log("Error", "%s | MySQL: #%d %s", PLUGIN, iError, szError);

            new szLastQuery[256];
            mysql_get_query(szLastQuery, charsmax(szLastQuery));

            UTIL_Log("Error", "%s | MySQL: %s", PLUGIN, szLastQuery);
        }
    }
    return false;
}

DB_Init()
{
    new szQuery[QUERY_LENGTH], iLen = 0, eData[1] = SQL_INIT;

    FORMAT_QUERY(szQuery, iLen, "CREATE TABLE IF NOT EXISTS `%s`", CVAR_TABLE_1);
    FORMAT_QUERY(szQuery, iLen, "(");
    {
        FORMAT_QUERY(szQuery, iLen, "`id` INT(11) NOT NULL AUTO_INCREMENT,");
        FORMAT_QUERY(szQuery, iLen, "`steam_id` VARCHAR(32) NOT NULL,");
        FORMAT_QUERY(szQuery, iLen, "`sex` INT(11) NOT NULL DEFAULT '0',");
        FORMAT_QUERY(szQuery, iLen, "`money` INT(11) NOT NULL DEFAULT '0',");
        FORMAT_QUERY(szQuery, iLen, "`online_time` INT(11) NOT NULL DEFAULT '0',");
        FORMAT_QUERY(szQuery, iLen, "`join_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,");
        FORMAT_QUERY(szQuery, iLen, "`register_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,");

        FORMAT_QUERY(szQuery, iLen, "PRIMARY KEY (`id`),");
        FORMAT_QUERY(szQuery, iLen, "UNIQUE INDEX `steam_id` (`steam_id`)");
    }
    FORMAT_QUERY(szQuery, iLen, ")");
    FORMAT_QUERY(szQuery, iLen, "COLLATE='utf8_general_ci' ENGINE=MyISAM;");

    QUERY(szQuery, eData);
}

DB_LoadPlayerData(const pId)
{
    g_iState[pId] = LOAD_WAIT;

    new szQuery[256], iLen, eData[2];

    eData[0] = SQL_LOAD;
    eData[1] = pId;

    FORMAT_QUERY(szQuery, iLen, "SELECT * FROM `%s` WHERE `steam_id` = '%s';", CVAR_TABLE_1, USER(pId, USER_AUTH));

    QUERY(szQuery, eData);
}

DB_SavePlayerData(pId, bool:bReload = false)
{
    if(g_iState[pId] < LOAD_NEW)
        return;

    new szQuery[512], iLen, eData[2]; eData[1] = pId;

    switch(g_iState[pId])
    {
        case LOAD_OK:
        {
            if(bReload)
            {
                g_iState[pId] = LOAD_UPDATE;
            }

            eData[0] = SQL_UPDATE;
            
            FORMAT_QUERY(szQuery, iLen, "UPDATE `%s` SET ", CVAR_TABLE_1);
            {
                if(g_iOnlineTime[pId])
                {
                    FORMAT_QUERY(szQuery, iLen, "`online_time` = '%d'", (USER(pId, USER_TIME_ONLINE) += (get_systime() - g_iOnlineTime[pId])));

                    g_iOnlineTime[pId] = get_systime();
                }

                new iSex = jb_get_user_sex(pId);
                if(USER(pId, USER_SEX) != iSex)
                {
                    FORMAT_QUERY(szQuery, iLen, ", `sex` = '%d', ", iSex);
                }

                new iMoney = jb_get_user_money(pId);
                if(USER(pId, USER_MONEY) != iMoney)
                {
                    FORMAT_QUERY(szQuery, iLen, ", `money` = '%d'", iMoney);
                }
			}
            FORMAT_QUERY(szQuery, iLen, " WHERE `steam_id` = '%s';", USER(pId, USER_AUTH));
        }
        case LOAD_NEW:
        {
            eData[0] = SQL_INSERT;

            FORMAT_QUERY(szQuery, iLen, "INSERT INTO `%s` (`steam_id`) VALUES ('%s');", CVAR_TABLE_1, USER(pId, USER_AUTH));

            g_iState[pId] = bReload ? LOAD_UPDATE : LOAD_WAIT_NEW;
        }
    }

    if(szQuery[0])
    {
        if(eData[0] == SQL_UPDATE)
        {
            DB_AddQuery(szQuery, iLen);
        }
        else
        {
            QUERY(szQuery, eData);
        }
    }
}

DB_AddQuery(const szQuery[], iLen)
{
    if((g_iLen_FlushQuery + iLen + 1) > charsmax(g_szFlushQuery))
    {
        DB_FlushQuery();
    }

    g_iLen_FlushQuery += FORMAT_QUERY(g_szFlushQuery, g_iLen_FlushQuery, "%s%s", g_iLen_FlushQuery ? ";" : "", szQuery);

    if(task_exists(TASK_FLUSH))
    {
        remove_task(TASK_FLUSH);
    }
    set_task(1.0, "Task_FlushQuery", TASK_FLUSH);
}

DB_FlushQuery()
{
    if(g_iLen_FlushQuery)
    {
        g_iLen_FlushQuery = 0;

        new eData[1] = SQL_UPDATE;
        QUERY(g_szFlushQuery, eData);

        // log_amx("*** [DB] DB_FlushQuery: Query");
        // log_amx("*** [DB] ->%s<-", g_szFlushQuery);
    }
}