#include <sourcemod>
#include <sdktools>
#include <colours>

#define STRAFE_NONE		0
#define STRAFE_LEFT		1
#define STRAFE_RIGHT	2

public Plugin myinfo = {
	name = "Strafe Bind Fix",
	author = "Clarkey",
	description = "Stops double bind in-game strafe hack.",
	version = "1.0",
	url = "http://finalrespawn.com"
};

int g_iStrafeBind[MAXPLAYERS + 1];
float g_fMessageTime[MAXPLAYERS + 1];
float g_fStrafeBindTime[MAXPLAYERS + 1];

public void OnPluginStart()
{
	RegConsoleCmd("sm_sbind", Command_StrafeBind);
	RegConsoleCmd("sm_strafebind", Command_StrafeBind);
}

public void OnClientPutInServer(int client)
{
	g_iStrafeBind[client] = STRAFE_NONE;
	g_fMessageTime[client] = 0.0;
	g_fStrafeBindTime[client] = 0.0;
}

public void OnClientDisconnect_Post(int client)
{
	g_iStrafeBind[client] = STRAFE_NONE;
	g_fMessageTime[client] = 0.0;
	g_fStrafeBindTime[client] = 0.0;
}

public Action Command_StrafeBind(int client, int args)
{
	if ((GetGameTime() - g_fStrafeBindTime[client]) < 10.0)
	{
		CPrintToChat(client, "[{darkblue}Strafe{default}] You {lightred}need to wait 10.0s {default}before you can change your strafe bind.");
	}
	else
	{
		Menu menu = new Menu(Handler_StrafeBind);
		menu.SetTitle("Strafe Bind");
		menu.AddItem("left", "Allow +left");
		menu.AddItem("right", "Allow +right");
		menu.Display(client, MENU_TIME_FOREVER);
	}
	
	return Plugin_Handled;
}

public Handler_StrafeBind(Menu menu, MenuAction action, int client, int item)
{
	if (action == MenuAction_Select)
	{
		char Item[8];
		menu.GetItem(item, Item, sizeof(Item));
		
		if (StrEqual("left", Item))
		{
			g_iStrafeBind[client] = STRAFE_LEFT;
			g_fStrafeBindTime[client] = GetGameTime();
		}
		else if (StrEqual("right", Item))
		{
			g_iStrafeBind[client] = STRAFE_RIGHT;
			g_fStrafeBindTime[client] = GetGameTime();
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
	
	return 0;
}

public Action OnPlayerRunCmd(int client, int &buttons)
{
	if ((buttons & IN_LEFT))
	{
		if (g_iStrafeBind[client] == STRAFE_NONE)
		{
			g_iStrafeBind[client] = STRAFE_LEFT;
		}
		else if (g_iStrafeBind[client] == STRAFE_RIGHT)
		{
			PrintStrafeMessage(client);
			
			float Velocity[3];
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, Velocity);
		}
	}
	else if ((buttons & IN_RIGHT))
	{
		if (g_iStrafeBind[client] == STRAFE_NONE)
		{
			g_iStrafeBind[client] = STRAFE_RIGHT;
		}
		else if (g_iStrafeBind[client] == STRAFE_LEFT)
		{
			PrintStrafeMessage(client);
			
			float Velocity[3];
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, Velocity);
		}
	}
	
	return Plugin_Continue;
}

void PrintStrafeMessage(int client)
{
	if ((GetGameTime() - g_fMessageTime[client]) > 2.0)
	{
		CPrintToChat(client, "[{darkblue}Strafe{default}] You are {lightred}not allowed to use that strafe bind. {default}Type {green}!strafebind {default}to change the strafe bind that you can use.");
		g_fMessageTime[client] = GetGameTime();
	}
}