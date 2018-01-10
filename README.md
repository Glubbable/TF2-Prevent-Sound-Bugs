# TF2 - Prevent Sound Bugs with SourceMod
Attempts to prevent certain sound issues with TF2 via SourceMod

Known bug issues that this attempts to resolve is:

1. Looping Critical Weapon sound that continues after Round End has concluded.
2. Missing Taunt Sounds after the recent Smissmass 2017 Update.

This might not work, as in testing, it sometimes blocked it, sometimes didn't.
So basically, mixed results; sounds from new taunts behave differently to older taunts.

SMs SDK Tools might need its method of obtaining these sounds to be updated.
This is in order for this SoundHooks method to be effective.

As a last ditch effort as well, I have provided some null files of the missing sound files to be uploaded.

Install instructions:
================

- plugins folder goes to addons/sourcemod/plugins
- scripting folder goes to addons/sourcemod/scripting
- sound goes to main tf directory
- fastdl is only if you have one and know how to use it.
