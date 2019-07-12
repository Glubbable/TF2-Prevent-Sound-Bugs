#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>

//#define DEBUG

#define PLUGIN_VERSION	"2.0"
#define PLUGIN_DESC	"Prevents a crit loop bug & missing taunt sounds!"
#define PLUGIN_NAME	"[TF2] Prevents Sound Bugs"
#define PLUGIN_AUTH	"Glubbable"
#define PLUGIN_URL	"http://steamcommunity.com/id/glubbable/"

bool g_bRoundEnd = false;

ConVar g_cvStunSoundBlock;

public const Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTH,
	description = PLUGIN_DESC,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL,
};

char g_sMissingFileReplacement[][] =
{
	"sound/vo/spy_hugenemy01.mp3",
	"sound/vo/spy_hugenemy04.mp3",
	"sound/vo/spy_hughugging04.mp3",
	"sound/vo/taunts/engy/engineer_cheers02.mp3",
	"sound/vo/taunts/spy/spy_laughhappy02.mp3",
	"sound/vo/taunts/pyro/pyro_highfive_success03.mp3"
};

public void OnPluginStart()
{
	HookEvent("teamplay_round_win", Event_OnRoundEndPre, EventHookMode_Pre);
	HookEvent("teamplay_round_start", Event_OnRoundStartPost, EventHookMode_Post);
	
	AddNormalSoundHook(SoundHook_BuggedSounds);
	g_cvStunSoundBlock = CreateConVar("sm_blockstunsounds", "0", "Enables/Disables the blocking of Bonk Sounds.");
}

public void OnConfigsExecuted()
{
	for (int i = 0; i < sizeof(g_sMissingFileReplacement); i++)
	{
		PrecacheSound(g_sMissingFileReplacement[i]);
		AddFileToDownloadsTable(g_sMissingFileReplacement[i]);
	}
}

public Action Event_OnRoundEndPre(Event eEvent, const char[] sName, bool bDB)
{
	g_bRoundEnd = true;
}

public Action Event_OnRoundStartPost(Event eEvent, const char[] sName, bool bDB)
{
	g_bRoundEnd = false;
}

public Action SoundHook_BuggedSounds(int iClients[64], int &numClients, char sSound[PLATFORM_MAX_PATH], int &iEntity, int &iChannel, float &flVolume, int &iLevel, int &iPitch, int &iFlags, char sSoundEntry[PLATFORM_MAX_PATH], int &iSeed)
{
	if (iChannel != SNDCHAN_STATIC && iChannel != SNDCHAN_VOICE && iChannel != SNDCHAN_VOICE_BASE)
		return Plugin_Continue;
		
	if (iEntity <= 0 || iEntity > MaxClients)
		return Plugin_Continue;
		
	if (!IsValidEntity(iEntity))
		return Plugin_Continue;
	
	for (int i = 0; i < sizeof(g_sMissingFileReplacement); i++)
	{
		if (strcmp(sSound, g_sMissingFileReplacement[i], false) == 0)
		{
#if defined DEBUG
			PrintToChatAll("Missing sound was detected and we attempted to block it!");
#endif
			return Plugin_Stop;
		}
	}
	
	if (g_bRoundEnd && StrContains(sSound, "crit_power.wav", false) != -1)
	{
#if defined DEBUG
		PrintToChatAll("Crit Sound detected and was blocked!");
#endif
		return Plugin_Stop;
	}
	
	if (g_cvStunSoundBlock.BoolValue && (StrContains(sSound, "halloween_scream", false) != -1 || StrContains(sSound, "pl_impact_stun", false) != -1))
	{
		if (TF2_GetClientTeam(iEntity) >= TFTeam_Red)
			return Plugin_Stop;
	}
	
	return Plugin_Continue;
}