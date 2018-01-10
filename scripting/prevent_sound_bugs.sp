#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <tf2>

#define PLUGIN_VERSION	"1.2"
#define PLUGIN_DESC	"Prevents a crit loop bug & missing taunt sounds!"
#define PLUGIN_NAME	"[TF2] Prevents Sound Bugs"
#define PLUGIN_AUTH	"Glubbable"
#define PLUGIN_URL	"http://steamcommunity.com/id/glubbable/"

bool gb_RoundEnd = false;

#define DEBUG

public const Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTH,
	description = PLUGIN_DESC,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL,
}

public void OnPluginStart()
{
	HookEvent("teamplay_round_win", Event_HookCritSound, EventHookMode_Pre);
	HookEvent("teamplay_round_start", Event_UnHookCritSound, EventHookMode);

	AddNormalSoundHook(SoundHook_BuggedSounds);
}

public Action Event_HookCritSound(Handle event, const char[] name, bool dontBroadcast)
{
	gb_RoundEnd = true;
}

public Action Event_UnHookCritSound(Handle event, const char[] name, bool dontBroadcast)
{
	gb_RoundEnd = false;
}

public Action SoundHook_BuggedSounds(int clients[64], int &numClients, char sound[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (IsValidEntity(entity))
	{
		if (StrContains(sound, "vo/taunts/spy/spy_laughhappy02.mp3", false) != -1
		|| StrContains(sound, "vo/taunts/engy/engineer_cheers02.mp3", false) != -1 
		|| StrContains(sound, "vo/spy_hugenemy01.mp3", false) != -1
		|| StrContains(sound, "vo/spy_hugenemy04.mp3", false) != -1
		|| StrContains(sound, "vo/spy_hughugging04.mp3", false) != -1
		|| StrContains(sound, "vo/taunts/pyro/pyro_highfive_success03.mp3", false) != -1)
		{
			#if defined DEBUG
			PrintToChatAll("Missing sound was detected and we attempted to block it!");
			#endif

			return Plugin_Stop;
		}

		if (gb_RoundEnd == true)
		{
			if (StrContains(sound, "crit_power", false) != -1)
			{
				#if defined DEBUG
				PrintToChatAll("Crit Sound detected and was blocked!");
				#endif

				return Plugin_Stop;
			}
		}

		else return Plugin_Continue;
	}

	return Plugin_Continue;
}