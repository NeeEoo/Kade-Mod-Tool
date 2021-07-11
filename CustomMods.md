# Making a custom mod

When copying things inside of these, ``, do not include the quotations.

The most important part of making a mod is the `weeks.json` file. That file contains all of the info needed for the mod tool to understand the mod.

There is an update planned later to make an editor that can do this.

To make mods using the mod tool it is recommended that you know how to write JSON.

Make a folder with your mod name in the weeks folder. The name of the folder cannot contain uppercase letters or spaces.

If you want to start with a template you can start by copying the `weeks.json` from the base folder in the `assets/weeks` folder, or copy the JSON from below.

You can use the `weeks.json` file to make new weeks. This is also able to add as many weeks as you like, but there must be at least one week for it to work.

You should set the mod name. The mod name will appear in the Freeplay menu and Story menu.

There exists asset overrides so you can reskin stages, characters, notes, health bar. You can even change music effects.

You do this by adding files in specific places in the mod folder. If it finds a override it uses that asset, if it can't find a override, it will use the original asset from the base game.

You shouldn't replace the assets from the base game.

The first override is a mod override.

1. `assets/weeks/<modname>/`
2. `assets/weeks/<modname>/week_/`
3. `assets/weeks/<modname>/week_/tracks/<song>/`

Replace the underscore with the current week number.

The mod tool priorities the song override, then the week override, then the mod override.

Place images in the images folder to override the asset.

Place sounds in the sounds folder to override the sound.

Place music in the music folder to override the music.

Place the character overrides in `images/characters`

Place the stage overrides in `images/stages`

The overrides shouldn't be placed in a folder named `shared`

The week number should start at 0 and shouldn't skip over numbers. This may be fixed in a future update.

The storyMenuColor value must start with `0xFF` then the RGB hex code should be placed after that.

The menu characters tells the tool what characters should be shown on the story menu.

The Freeplay array should be the same length as the total songs in the week. It is what makes the characters appear on the Freeplay menu.

The locked value locks the week if it is set to true.

The week comment is what appears in the corner top right corner in the story menu.

The weekText says what it should show if it doesn't find `week.png` in the week.

The introTexts is an array containing an array of 2 string. These are the intro texts and adding things here will make it have a chance to appear when starting the game.

The item in the tracks array can be either an array or a string. If it is a string it will use that string in the game, if it is an array it will use the second string as the name, but it will load it from the folder using the first string.

The first string must follow the same rules as the mod folder name. Which is no uppercase letters or spaces.

```json
{
    "modName": "Mod Name Here",
    "credits": [
        "Person 1",
        "Person 2"
    ],
    "weeks": {
        "0": {
            "weekText": "Week Name",
            "comment": "Funny Comment",
            "tracks": [
                ["pico", "DisplayName1"],
                ["philly", "DisplayName2"],
                ["blammed", "DisplayName3"],
                ["winter-horrorland", "You can add as many songs in a week as you like"]
            ],
            "menuCharacters": ["pico", "bf", "gf"],
            "locked": false,
            "freeplay": [
                "pico",
                "pico",
                "pico",
                "monster-christmas"
            ]
        }
    },
    "storyMenuColor": "0xFF64f230",
    "hudColors": {
        "healthBarGreen": "0xFF66ff33",
        "healthBarRed": "0xFFff0000",
        "timeBarFilled": "0xFF00ff00",
        "timeBarBackground": "0xFF808080"
    },
    "introTexts": [
        [
            "Hopefully this",
            "works"
        ]
    ]
}
```

## Sharing your custom mod

Under any circumstances you can upload a mod under the use of our mod tool but please do respect our hard work by crediting these creators: Ne_Eo and Lelmaster. If you upload the mod on Gamebanana or anywhere else please use our tool appropriately and respectfully.

When uploading your mod only include the custom mod you made and not the mod tool itself. Instead tell users in a file in the mod and/or in the description of your mod.

This is to make the mods being able to just be put in the mod tool for it just to work. And to keep filesizes down.

## Porting mods to the mod tool

To port mods, there some things that needs to be done.

The first thing is in the week folder you want to make a folder named `tracks`. The tracks folder should contain the songs.

In the song folder, the song chart and music files must be placed there.

In the week folder, there can exist an image named `week.png`. That image will be shown on the story menu.

If your song chart was made on the original engine or on Kade Engine 1.4.2 or below, follow these steps to make it work here.

You might be able to use the charting editor. I haven't tested it.

REMEMBER that after the text you placed you put in you should add a comma.

Capitalization is important.

You need to add `"stage":"VALUE"` in the song chart file next to before "player1". Where VALUE should be replaced with either one of these.

stage, halloween, philly, limo, mall, mallEvil, school, schoolEvil

If your song uses a different gf. You need to add `"gfVersion":"VALUE"` before "stage". Replace VALUE with either one of these.

gf-car, gf-christmas, gf-pixel

If your song uses the pixel style you should add `"noteStyle":"pixel"`

If your song uses the dialogue system in the school songs. You should rename it from `songDialogue.txt` to `dialogue.txt`

## Modcharts

Modcharts should be placed in the same folder as your song charts are located.

You can read the docs of the modcharts [here](https://github.com/KadeDev/Kade-Engine/blob/f20493cd84cbbca5c87e6621912085a130f89d50/docs/modchart.md)

Differences from the Kade Engine Modcharts:

Sprites are loaded from a folder named `luasprites` that should be placed in the mod folder.

New function called `kmt_runStoryBoardAction()`. Takes a string as an argument (Should not include the time). It runs the same commands as the storyboard

## Storyboards

Read the StoryBoards.txt file for info on how to use storyboards.

## Dialogue

IMPORTANT: The portrait enter animation name has been changed to `portrait enter`.

The dialogue box image animation names are now named `appear` and `normal`

Read the Dialogue.txt file for info on how to add dialogue.

## Tips

If your sprite is offset or jumps around. You can use `frameX="0"` and `frameY="0"` in the xml file, remember to adjust the number.

## Quirks with some songs

These values are hardcoded i'm just listing the things they do.

If you don't want these things to happen you can just set the name to for example "blammed2" and have a visual name that says "Blammed". You might need to change the name in the song chart file also.

If the song is named "bopeebo" the bf plays the hey animation on every 8th beat. `(beat % 8 == 7)`
The gf will cheer every 8th beat but only if during when the beat is in a range of 6 to 129. `(beat % 8 == 7 and beat > 5 and beat < 130)`
The vocals are muted on beat 128, 129 and 130.

If the song is named "blammed" the gf will cheer every 4th beat during beat 31 to 89, and beat 129 to 189. `(beat % 4 == 2) and ((beat > 30 and beat < 90) and (beat > 128 and beat < 190))`

If the song is named "cocoa" the gf will cheer every 16th beat. But only if the beat is below 170, and if beat is below 65 or in range from 131 to 144. `(beat < 170) and (beat < 65 or (beat > 130 and beat < 145)) and (beat % 16 == 15)`

If the song is named "eggnog" the gf will cheer every 8th beat, during beat 11 to 219, but not on beat 111. `(beat > 10 and beat != 111 and beat < 220 and beat % 8 == 7)`

If the song is named "philly" the gf will cheer every 16th beat. `(beat % 16 == 8)` It will only play when the beat number is below 250. It won't play on beat 184 or 216.

If the song is named "fresh" the camera will be able to zoom on beat 16 and the gf speed is set to 2. On beats 48 and 112 the gf speed is set to 1. On beat 80 the gf speed is set to 2.

If the stage is either "school" or "schoolEvil" the ready, set, go will be using the pixelated versions. And play the "-pixel" version of "intro_". Same with the score.

If the song is named "roses" and the current stage is school, the girls in the background gets scared. You can use the stage name "schoolWorry". To make the girls get scared regardless of the song name.

### This only applies for storymode

If the song is named "eggnog", it will play the sound effect "Lights_Shut_off" when it's loading the next song. It's meant to be used with "winter-horrorland" as the next song.

If the song is named "winter-horrorland". It will play the sound effect "Lights_Turn_On". Start with the camera pointing at the top of the tree. The entire stage is zoomed in.

If the song name is any one of these "senpai", "roses", "thorns". It will open a dialogue box with the contents of "dialogue.txt".

If the song is named "roses" it will play the sound effect "ANGRY".

If the song is named "thorns" it will start a cutscene with a red background. The image "senpaiCrazy" will be placed and play the animation "Senpai Pre Explosion". The sound effect "Senpai_Dies" will play.
