#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>

#undef REQUIRE_PLUGIN
#tryinclude <sf2>
#define REQUIRE_PLUGIN

//#define DEBUG

#define PLUGIN_VERSION	"1.6"
#define PLUGIN_DESC	"Prevents a crit loop bug & missing taunt sounds!"
#define PLUGIN_NAME	"[TF2] Prevents Sound Bugs"
#define PLUGIN_AUTH	"Glubbable"
#define PLUGIN_URL	"http://steamcommunity.com/id/glubbable/"

#define TFTeam_Unassigned 0
#define TFTeam_Spectator 1
#define TFTeam_Red 2
#define TFTeam_Blue 3

bool gb_RoundEnd = false;
bool gb_StunSoundBlockMode = false;

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

	AddFileToDownloadsTable("sound/vo/spy_hugenemy01.mp3");
	AddFileToDownloadsTable("sound/vo/spy_hugenemy04.mp3");
	AddFileToDownloadsTable("sound/vo/spy_hughugging04.mp3");

	AddFileToDownloadsTable("sound/vo/taunts/engy/engineer_cheers02.mp3");
	AddFileToDownloadsTable("sound/vo/taunts/spy/spy_laughhappy02.mp3");
	AddFileToDownloadsTable("sound/vo/taunts/pyro/pyro_highfive_success03.mp3");
}

public Action Event_HookCritSound(Handle event, const char[] name, bool dontBroadcast)
{
	gb_RoundEnd = true;
}

public Action Event_UnHookCritSound(Handle event, const char[] name, bool dontBroadcast)
{
	gb_RoundEnd = false;
}

public Action SoundHook_BuggedSounds(int iClients[64], int &numClients, char sSound[PLATFORM_MAX_PATH], int &iEntity, int &iChannel, float &flVolume, int &iLevel, int &iPitch, int &iFlags, char sSoundEntry[PLATFORM_MAX_PATH], int &iSeed)
{
	for (int iClient = 1; iClient < numClients; iClient++)
	{
		if (IsValidEntity(iEntity))
		{
			if (StrContains(sSound, "vo/taunts/spy/spy_laughhappy02.mp3", false) != -1
			|| StrContains(sSound, "vo/taunts/engy/engineer_cheers02.mp3", false) != -1 
			|| StrContains(sSound, "vo/spy_hugenemy01.mp3", false) != -1
			|| StrContains(sSound, "vo/spy_hugenemy04.mp3", false) != -1
			|| StrContains(sSound, "vo/spy_hughugging04.mp3", false) != -1
			|| StrContains(sSound, "vo/taunts/pyro/pyro_highfive_success03.mp3", false) != -1)
			{
					#if defined DEBUG
					PrintToChatAll("Missing sound was detected and we attempted to block it!");
					#endif
	
					return Plugin_Stop;
			}
	
			else if (StrContains(sSound, "crit_power.wav", false) != -1)
			{
					#if defined DEBUG
					PrintToChatAll("Crit Sound detected and was blocked!");
					#endif
	
					if (gb_RoundEnd == true)
						return Plugin_Stop;
			}
	
			else if (StrContains(sSound, "halloween_scream", false) != -1 
			|| StrContains(sSound, "pl_impact_stun", false) != -1
			|| StrContains(sSound, "pl_impact_stun_range", false) != -1)
			{
					gb_StunSoundBlockMode = GetConVarBool(Cvar_StunSoundBlock);
	
					if (gb_StunSoundBlockMode == true)
					{
						#if defined _sf2_included
						if (IsClientRED(iEntity) || IsClientBLU(iEntity))
							return Plugin_Stop;

						if (IsClientRED(iClient) || IsClientBLU(iClient))
							return Plugin_Stop;
						#endif
	
						#if !defined _sf2_included
						return Plugin_Stop;
						#endif
					}
			}
			
			else return Plugin_Continue;
		}
	}
	
	return Plugin_Continue;
}

#if defined _sf2_included
stock bool IsClientRED(int iClient)
{
	int iTeam = GetClientTeam(iClient);

	switch (iTeam)
	{
		case TFTeam_Red: return true;
		default: return false;
	}

	return true;
}

stock bool IsClientBLU(int iClient)
{
	int iTeam = GetClientTeam(iClient);

	switch (iTeam)
	{
		case TFTeam_Blue: return true;
		default: return false;
	}

	return true;
}
#endif