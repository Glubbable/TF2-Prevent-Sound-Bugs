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

#define PLUGIN_VERSION	"1.7"
#define PLUGIN_DESC	"Prevents a crit loop bug & missing taunt sounds!"
#define PLUGIN_NAME	"[TF2] Prevents Sound Bugs"
#define PLUGIN_AUTH	"Glubbable"
#define PLUGIN_URL	"http://steamcommunity.com/id/glubbable/"

bool g_bRoundEnd = false;
bool g_bStunSoundBlockMode = false;

ConVar g_cvStunSoundBlock;

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

	g_cvStunSoundBlock = CreateConVar("sm_blockstunsounds", "0", "Enables/Disables the blocking of Bonk Sounds.");
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
	g_bRoundEnd = true;
}

public Action Event_UnHookCritSound(Handle event, const char[] name, bool dontBroadcast)
{
	g_bRoundEnd = false;
}

public Action SoundHook_BuggedSounds(int iClients[64], int &numClients, char sSound[PLATFORM_MAX_PATH], int &iEntity, int &iChannel, float &flVolume, int &iLevel, int &iPitch, int &iFlags, char sSoundEntry[PLATFORM_MAX_PATH], int &iSeed)
{
	for (int iClient = 1; iClient < numClients; iClient++)
	{
		if (iEntity && IsValidEntity(iEntity))
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
	
					if (g_bRoundEnd)
						return Plugin_Stop;
			}
	
			else if (StrContains(sSound, "halloween_scream", false) != -1 
			|| StrContains(sSound, "pl_impact_stun", false) != -1
			|| StrContains(sSound, "pl_impact_stun_range", false) != -1)
			{
					g_bStunSoundBlockMode = g_cvStunSoundBlock.BoolValue;
	
					if (g_bStunSoundBlockMode && iEntity <= MaxClients)
					{
						#if defined _sf2_included
						if (TF2_GetClientTeam(iEntity) >= TFTeam_Red)
							return Plugin_Stop;

						else if (TF2_GetClientTeam(iClient) >= TFTeam_Red)
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