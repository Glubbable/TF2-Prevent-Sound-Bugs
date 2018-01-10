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

bool gb_OldRoundEnd = false;
bool gb_NewRoundStart = true;

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
	gb_OldRoundEnd = true;
	gb_NewRoundStart = false;
}

public Action Event_UnHookCritSound(Handle event, const char[] name, bool dontBroadcast)
{
	gb_OldRoundEnd = false;
	gb_NewRoundStart = true;
}

public Action SoundHook_BuggedSounds(int clients[64], int &numClients, char sound[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	bool b_BlockSound = false;

	if (IsValidEntity(entity))
	{
		if (gb_OldRoundEnd == true && gb_NewRoundStart == false)
		{
			if (StrContains(sound, "weapons/crit_power.wav", false) != -1)
			{
				b_BlockSound = true;

				#if defined DEBUG
				PrintToChatAll("Crit Sound detected and was blocked!");
				#endif
			}
		}
	
		if (gb_NewRoundStart == true && gb_OldRoundEnd == false)
		{
			if (StrContains(sound, "weapons/crit_power.wav", false) != -1)
				b_BlockSound = false;
		}

		if (StrContains(sound, "vo/taunts/spy/spy_laughhappy02.mp3", false) != -1
		|| StrContains(sound, "vo/taunts/engy/engineer_cheers02.mp3", false) != -1 
		|| StrContains(sound, "vo/spy_hugenemy01.mp3", false) != -1
		|| StrContains(sound, "vo/spy_hugenemy04.mp3", false) != -1
		|| StrContains(sound, "vo/spy_hughugging04.mp3", false) != -1
		|| StrContains(sound, "vo/taunts/pyro/pyro_highfive_success03.mp3", false) != -1)
		{
			b_BlockSound = true;

			#if defined DEBUG
			PrintToChatAll("Missing sound was detected and we attempted to block it!");
			#endif
		}

		if (b_BlockSound == true)
			return Plugin_Stop;

		else return Plugin_Continue;
	}

	return Plugin_Continue;
}