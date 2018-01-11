#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#tryinclude <sf2>

//#define DEBUG

#define PLUGIN_VERSION	"1.4"
#define PLUGIN_DESC	"Prevents a crit loop bug & missing taunt sounds!"
#define PLUGIN_NAME	"[TF2] Prevents Sound Bugs"
#define PLUGIN_AUTH	"Glubbable"
#define PLUGIN_URL	"http://steamcommunity.com/id/glubbable/"

#define TFTeam_Unassigned 0
#define TFTeam_Spectator 1
#define TFTeam_Red 2
#define TFTeam_Blue 3

bool gb_RoundEnd = false;
bool gb_BonkBlockMode = false;

Handle Cvar_StunSoundBlock;

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
	HookEvent("teamplay_round_start", Event_UnHookCritSound, EventHookMode_Post);

	AddNormalSoundHook(SoundHook_BuggedSounds);

	PrepareSounds();

	Cvar_StunSoundBlock = CreateConVar("sm_blockstunsounds", "0", "Enables/Disables the blocking of Bonk Sounds.");
}

public void OnMapStart()
{
	PrepareSounds();
}

void PrepareSounds()
{
	PrecacheSound("vo/spy_hugenemy01.mp3");
	PrecacheSound("vo/spy_hugenemy04.mp3");
	PrecacheSound("vo/spy_hughugging04.mp3");

	PrecacheSound("vo/taunts/engy/engineer_cheers02.mp3");
	PrecacheSound("vo/taunts/spy/spy_laughhappy02.mp3");
	PrecacheSound("vo/taunts/pyro/pyro_highfive_success03.mp3");

	AddFileToDownloadsTable("vo/spy_hugenemy01.mp3");
	AddFileToDownloadsTable("vo/spy_hugenemy04.mp3");
	AddFileToDownloadsTable("vo/spy_hughugging04.mp3");

	AddFileToDownloadsTable("vo/taunts/engy/engineer_cheers02.mp3");
	AddFileToDownloadsTable("vo/taunts/spy/spy_laughhappy02.mp3");
	AddFileToDownloadsTable("vo/taunts/pyro/pyro_highfive_success03.mp3");
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
			if (entity <= MaxClients)
			{
				#if defined DEBUG
				PrintToChatAll("Missing sound was detected and we attempted to block it!");
				#endif

				return Plugin_Stop;
			}
		}

		if (StrContains(sound, "crit_power.wav", false) != -1)
		{
			if (entity <= MaxClients)
			{
				#if defined DEBUG
				PrintToChatAll("Crit Sound detected and was blocked!");
				#endif

				if (gb_RoundEnd == true)
					return Plugin_Stop;
			}
		}

#if defined _sf2_included
		if (StrContains(sound, "halloween_scream", false) != -1 || StrContains(sound, "pl_impact_stun", false) != -1)
		{
			if (entity <= MaxClients)
			{
				if (TF2_IsPlayerInCondition(entity, TFCond_Dazed))
				{
					gb_BonkBlockMode = GetConVarBool(Cvar_StunSoundBlock);

					if (gb_BonkBlockMode == true)
					{
						if (IsClientRED(entity) || SF2_IsClientInGhostMode(entity) || SF2_IsClientProxy(entity))
							return Plugin_Stop;
					}
				}
			}
		}
#endif

#if !defined _sf2_included
		if (StrContains(sound, "halloween_scream", false) != -1 || StrContains(sound, "pl_impact_stun", false) != -1)
		{
			if (entity <= MaxClients)
			{
				if (TF2_IsPlayerInCondition(entity, TFCond_Dazed))
				{
					gb_BonkBlockMode = GetConVarBool(Cvar_StunSoundBlock);

					if (gb_BonkBlockMode == true)
						return Plugin_Stop;
				}
			}
		}
#endif
		else return Plugin_Continue;
	}

	return Plugin_Continue;
}

stock bool IsClientRED(int client, bool tfteam = true)
{
	int team = GetClientTeam(client);
	if (team == TFTeam_Unassigned) return false;
	if (team == TFTeam_Spectator) return false;
	if (team == TFTeam_Red) return true;
	if (team == TFTeam_Blue) return false;

	return false;
}
