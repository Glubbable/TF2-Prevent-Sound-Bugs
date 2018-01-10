#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <tf2>

#define PLUGIN_VERSION	"1.0"
#define PLUGIN_DESC	"Prevents a crit loop bug & missing taunt sounds!"
#define PLUGIN_NAME	"[TF2] Prevents Sound Bugs"
#define PLUGIN_AUTH	"Glubbable"
#define PLUGIN_URL	"http://steamcommunity.com/id/glubbable/"

bool gb_OldRoundEnd = false;
bool gb_NewRoundStart = true;

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
	HookEvent("teamplay_round_win", Event_HookCritSound, EventHookMode);
	HookEvent("teamplay_round_start", Event_UnHookCritSound, EventHookMode);

	AddNormalSoundHook(view_as<NormalSHook>(SoundHook_StopMissingSounds));
	AddNormalSoundHook(view_as<NormalSHook>(SoundHook_FixCritSound));
}

public Action Event_HookCritSound(Handle event, const char[] name, bool dontBroadcast)
{
	if (gb_OldRoundEnd == false)
		gb_OldRoundEnd = true;

	if (gb_NewRoundStart == true)
		gb_NewRoundStart = false;
}

public Action Event_UnHookCritSound(Handle event, const char[] name, bool dontBroadcast)
{
	if (gb_OldRoundEnd == true)
		gb_OldRoundEnd = false;

	if (gb_NewRoundStart == false)
		gb_NewRoundStart = true;
}

public Action SoundHook_FixCritSound(int clients[64], int &numClients, char sound[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	bool b_BlockSound = false;

	if(entity <= MaxClients)
	{
		if (IsValidClient(entity))
		{
			if (gb_OldRoundEnd == true && gb_NewRoundStart == false)
			{
				if (StrContains(sound, "weapons/crit_power.wav", false) != -1)
				{
					ReplaceString(sound, PLATFORM_MAX_PATH, "weapons/crit_power.wav", "misc/null.wav", true);
					strcopy(sound, PLATFORM_MAX_PATH, "misc/null.wav");
					PrecacheSound(sound, true);
					b_BlockSound = true;
				}
			}
	
			if (gb_NewRoundStart == true && gb_OldRoundEnd == false)
			{
				if (StrContains(sound, "weapons/crit_power.wav", false) != -1)
				{
					b_BlockSound = false;
				}
			}

			if (b_BlockSound == true)
			{
				return Plugin_Changed;
			}
		}
	}

	return Plugin_Continue;
}

public Action SoundHook_StopMissingSounds(int clients[64], int &numClients, char sound[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	bool b_BlockSound2 = false;

	if(entity <= MaxClients)
	{
		if (IsValidClient(entity))
		{
			if (StrContains(sound, "vo/taunts/spy/spy_laughhappy02.mp3", false) != -1
			|| StrContains(sound, "vo/taunts/engy/engineer_cheers02.mp3", false) != -1 
			|| StrContains(sound, "vo/spy_hugenemy01.mp3", false) != -1
			|| StrContains(sound, "vo/spy_hugenemy04.mp3", false) != -1
			|| StrContains(sound, "vo/spy_hughugging04.mp3", false) != -1
			|| StrContains(sound, "vo/taunts/pyro/pyro_highfive_success03.mp3", false) != -1)
			{
				ReplaceString(sound, PLATFORM_MAX_PATH, "vo/taunts/spy/spy_laughhappy02.mp3", "misc/null.wav", true);
				ReplaceString(sound, PLATFORM_MAX_PATH, "vo/taunts/engy/engineer_cheers02.mp3", "misc/null.wav", true);
				ReplaceString(sound, PLATFORM_MAX_PATH, "vo/spy_hugenemy01.mp3", "misc/null.wav", true);
				ReplaceString(sound, PLATFORM_MAX_PATH, "vo/spy_hugenemy04.mp3", "misc/null.wav", true);
				ReplaceString(sound, PLATFORM_MAX_PATH, "vo/spy_hughugging04.mp3", "misc/null.wav", true);
				ReplaceString(sound, PLATFORM_MAX_PATH, "vo/taunts/pyro/pyro_highfive_success03.mp3", "misc/null.wav", true);
				strcopy(sound, PLATFORM_MAX_PATH, "misc/null.wav");
				PrecacheSound(sound, true);
				b_BlockSound2 = true;
			}

			if (b_BlockSound2 == true)
			{
				return Plugin_Changed;
			}
		}
	}

	return Plugin_Continue;
}

stock bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client))) return false;
	return IsClientInGame(client);
}