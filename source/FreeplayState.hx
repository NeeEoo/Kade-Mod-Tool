package;

import WeeksParser.SwagWeek;
import WeeksParser.SwagWeeks;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

#if (windows && DISCORD)
import Discord.DiscordClient;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var curSelected:Int = 0;

	var modCatagories:Array<ModCatagory> = [];

	var currentSelectedMod:ModCatagory;

	var songs:Array<SongMetadata> = [];

	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;

	private var iconArray:Array<HealthIcon> = [];

	var isInModCat:Bool = false;

	override function create()
	{
		setDiscordStatus();

		parseModSongs();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		addCategories();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);
		add(scoreText);

		super.create();
	}

	function parseModSongs() {
		for(mod in TitleState.mods) {
			var modInfo = WeeksParser.getWeeksInfoFromJson(mod);
			var catagory = new ModCatagory(modInfo, mod, []);

			var weeks = modInfo.weeks;
			var keys = weeks.keys();

			keys.sort(Reflect.compare);

			for(week in keys) {
				var weekInfo:SwagWeek = weeks[week];
				var tracks = weekInfo.tracks;
				var weekNum = Std.parseInt(week);
				var freeplayCharacters = weekInfo.freeplay;

				var songNum = 0;
				for(track in tracks) {
					var weekText = "";
					var weekTrack = "";
					if(Std.isOfType(track, Array)) {
						weekTrack = track[0];
						weekText = track[1];
					} else {
						weekTrack = track;
						weekText = track;
					}
					var metadata = new SongMetadata(weekTrack, weekNum, freeplayCharacters[songNum], mod, weekText);

					catagory.addSong(metadata);
					songNum++;
				}
			}

			modCatagories.push(catagory);
		}
	}

	public function addCategories(clear:Bool = false) {
		if(clear) {
			grpSongs.clear();
		}
		for (i in 0...modCatagories.length)
		{
			var modLabel = new Alphabet(0, (70 * i) + 30, modCatagories[i].getName(), true, false);
			modLabel.isMenuItem = true;
			modLabel.targetY = i;
			grpSongs.add(modLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}
	}

	// Updating Discord Rich Presence
	function setDiscordStatus() {
		#if (windows && DISCORD)
		if(isInModCat) {
			DiscordClient.changePresence("In the Story Mode Menu", "\nCurrent Mod: " + currentSelectedMod.getName());
		} else {
			DiscordClient.changePresence("In the Freeplay Menu", null);
		}
		#end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if(controls.BACK) {
			if(isInModCat) {
				isInModCat = false;
				addCategories(true);
				curSelected = 0;
				diffText.text = "";
				scoreText.text = "";
				lerpScore = 0;
				for (icon in iconArray) {
					icon.destroy();
				}
				setDiscordStatus();
			} else {
				FlxG.switchState(new MainMenuState());
			}
		}

		if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);

		if(isInModCat) {
			lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

			if (Math.abs(lerpScore - intendedScore) <= 10)
				lerpScore = intendedScore;

			scoreText.text = "PERSONAL BEST:" + lerpScore;

			if (controls.LEFT_P)
				changeDiff(-1);
			if (controls.RIGHT_P)
				changeDiff(1);
		}

		if (controls.ACCEPT)
		{
			if (isInModCat)
			{
				var songName = songs[curSelected].songName.toLowerCase();
				var songFilename:String = Song.getSongFilename(songName, curDifficulty);

				trace(songFilename);

				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;
				PlayState.storyWeek = songs[curSelected].week;
				PlayState.currentMod = songs[curSelected].mod;
				PlayState.songFilename = songName;
				LoadingState.setGlobals();
				PlayState.visualSongName = songs[curSelected].visualSongName;
				PlayState.SONG = Song.loadFromJson(songFilename, songName);
				PlayState.MOD = currentSelectedMod.getModInfo();
				trace('CUR WEEK' + PlayState.storyWeek);
				LoadingState.loadAndSwitchState(new PlayState());
			}
			else
			{
				currentSelectedMod = modCatagories[curSelected];
				isInModCat = true;
				curSelected = 0;
				grpSongs.clear();
				songs = currentSelectedMod.getSongs();
				Paths.setCurrentMod(currentSelectedMod.modFolderName);
				setDiscordStatus();
				for (i in 0...songs.length)
				{
					var songText = new Alphabet(0, (70 * i) + 30, songs[i].visualSongName, true, false);
					songText.isMenuItem = true;
					songText.targetY = i;
					grpSongs.add(songText);
					// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!

					var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
					icon.sprTracker = songText;

					// using a FlxGroup is too much fuss!
					iconArray.push(icon);
					add(icon);
				}
				changeSelection();
				changeDiff();
				curSelected = 0;
			}
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		// Change to modulo?
		if (curDifficulty < 0)
			curDifficulty = 2;
		else if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].mod, songs[curSelected].songName, curDifficulty);
		#end

		switch (curDifficulty)
		{
			case 0:
				diffText.text = "EASY";
			case 1:
				diffText.text = 'NORMAL';
			case 2:
				diffText.text = "HARD";
		}
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent('Fresh');
		#end

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpSongs.length - 1;
		else if (curSelected >= grpSongs.length)
			curSelected = 0;

		if(isInModCat) {
			#if !switch
			intendedScore = Highscore.getScore(songs[curSelected].mod, songs[curSelected].songName, curDifficulty);
			// lerpScore = 0;
			#end

			#if PRELOAD_ALL
			Paths.setCurrentMod(songs[curSelected].mod);
			FlxG.sound.playMusic(Paths.instWeek(songs[curSelected].songName, "week" + songs[curSelected].week), 0);
			#end

			for (i in 0...iconArray.length)
			{
				iconArray[i].alpha = 0.6;
			}

			iconArray[curSelected].alpha = 1;
		}

		var i:Int = 0;
		for (item in grpSongs.members)
		{
			item.targetY = i - curSelected;
			i++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}
}

class ModCatagory
{
	private var _songs = new Array<SongMetadata>();
	private var _modInfo:SwagWeeks;
	public var modFolderName:String;
	public final function getSongs():Array<SongMetadata>
	{
		return _songs;
	}

	public final function addSong(song:SongMetadata)
	{
		_songs.push(song);
	}

	public final function removeSong(song:SongMetadata)
	{
		_songs.remove(song);
	}

	public final function getName() {
		return _modInfo.modName;
	}

	public final function getModInfo() {
		return _modInfo;
	}

	public function new (modInfo:SwagWeeks, mod:String, songs:Array<SongMetadata>)
	{
		_modInfo = modInfo;
		modFolderName = mod;
		_songs = songs;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var visualSongName:String = "";
	public var mod:String = "";

	public function new(song:String, week:Int, songCharacter:String, mod:String, ?visualSongName:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.mod = mod;
		if(visualSongName == null) {
			this.visualSongName = song;
		} else {
			this.visualSongName = visualSongName;
		}
	}
}
