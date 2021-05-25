package;

import WeeksParser.SwagWeeks;
import WeeksParser.SwagWeek;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

#if (windows && DISCORD)
import Discord.DiscordClient;
#end

using StringTools;

class StoryMenuSubGroup extends FlxGroup
{
	var scoreText:FlxText;

	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	var visualTrackNames:Array<Dynamic> = [];
	var weekData:Array<Dynamic> = [];
	var curDifficulty:Int = 1;

	public var weekUnlocked:Array<Bool> = [];
	public var tween:FlxTween = null;

	var weekCharacters:Array<Dynamic> = [];
	var weekComment:Array<String> = [];

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;
	var curMod:Int = 0;
	var curModStr:String = "base";

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxTypedGroup<FlxSprite>;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var storyBG:FlxSprite;

	var modInfo:SwagWeeks;
	public var currentX:Float;
	public var currentY:Float;
	public var modStoryColor:Int;

	public var leftModArrow:FlxSprite;
	public var rightModArrow:FlxSprite;

	var blackBarThingie:FlxSprite;
	var modNameText:FlxSprite;

	public var isActive:Bool = false;

	public function new(x:Float, y:Float, mod:String, curMod:Int)
	{
		super();

		trace('Loading Story Menu For $mod');

		modInfo = WeeksParser.getWeeksInfoFromJson(mod);
		this.curModStr = mod;
		this.curMod = curMod;
		currentX = x;
		currentY = y;
		// }

		// override function create() {
		// #if (windows && DISCORD)
		// // Updating Discord Rich Presence
		// DiscordClient.changePresence("In the Story Mode Menu", "\nCurrently Viewing " + curModStr);
		// #end

		Paths.setCurrentMod(curModStr);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		
		storyBG = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400);
		//changeStoryColor(StoryMenuState.storyColor);
		changeStoryColor(StoryMenuState.storyColor);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		blackBarThingie = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		// grpWeekCharacters[curMod] = new FlxTypedGroup<MenuCharacter>();

		leftModArrow = makeArrow(
			10,
			0,//10,
			Direction.LEFT,
			ui_tex
		);

		var scale = (blackBarThingie.y + blackBarThingie.height) / leftModArrow.height;

		leftModArrow.setGraphicSize(Std.int(leftModArrow.width*scale), Std.int(leftModArrow.height*scale));
		leftModArrow.updateHitbox();

		scoreText = new FlxText(leftModArrow.x + leftModArrow.width + 10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		rightModArrow = makeArrow(
			FlxG.width,
			0,//10,
			Direction.RIGHT,
			ui_tex,
			scale
		);
		rightModArrow.x -= 10 + rightModArrow.width;

		// X position is overwritten later
		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		// txtWeekTitle = new FlxText(rightModArrow.x - 10, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var visTrackNames:Array<Array<String>> = [];
		var visWeekComment:Array<String> = [];
		var unlockedWeeks:Array<Bool> = [];
		var modWeekCharacters:Array<Array<String>> = [];
		var modTracks:Array<Array<String>> = [];

		var weeks = modInfo.weeks;
		var totalWeeks = 0;

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		modNameText = MenuItem.makeText(0, modInfo.modName, true);
		modNameText.screenCenter(X);
		// modNameText.x += FlxG.width * curMod;
		modNameText.antialiasing = true;

		/*{
			var weekThing:MenuItem = new MenuItem(0, storyBG.y + storyBG.height + 10, 0, currentModInfo.modName, true);
			weekThing.y += ((weekThing.height + 20) * totalWeeks);
			weekThing.targetY = totalWeeks;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = true;
			totalWeeks++; // To make space
		}*/

		var keys = weeks.keys();

		keys.sort(Reflect.compare);
		
		for(week in keys) {
			var weekInfo:SwagWeek = weeks[week];
			var tracks = weekInfo.tracks;

			var visTrack:Array<String> = [];
			var weekTracks:Array<String> = [];

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
				visTrack.push(weekText);
				weekTracks.push(weekTrack);
			}
			
			{
				var weekThing:MenuItem = new MenuItem(0, storyBG.y + storyBG.height + 10, totalWeeks);
				weekThing.y += ((weekThing.height + 20) * totalWeeks);
				weekThing.targetY = totalWeeks;
				
				weekThing.screenCenter(X);
				// if (axes != FlxAxes.Y)
				// 	x = (FlxG.width / 2) - (width / 2);
				// weekThing.x += FlxG.width * curMod;
				weekThing.antialiasing = true;
				grpWeekText.add(weekThing);
				// weekThing.updateHitbox();

				// Needs an offset thingie
				if (weekInfo.locked)
				{
					var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
					lock.frames = ui_tex;
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.ID = totalWeeks;
					lock.antialiasing = true;
					grpLocks.add(lock);
				}
			}

			visWeekComment.push(weekInfo.comment);
			unlockedWeeks.push(!weekInfo.locked);
			visTrackNames.push(visTrack);
			modWeekCharacters.push(weekInfo.menuCharacters);
			modTracks.push(weekTracks);

			// trace(modWeekCharacters);

			totalWeeks++;
		}

		{
			difficultySelectors = new FlxTypedGroup<FlxSprite>();
			add(difficultySelectors);

			// trace("Line 124");

			leftArrow = makeArrow(
				grpWeekText.members[0].x + grpWeekText.members[0].width + 10,
				grpWeekText.members[0].y + 10,
				// grpWeekText.members[0].y + grpWeekText.members[0].height*1.5 + 10,
				Direction.LEFT,
				ui_tex
			);
			
			difficultySelectors.add(leftArrow);

			sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
			sprDifficulty.frames = ui_tex;
			sprDifficulty.animation.addByPrefix('easy', 'EASY');
			sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
			sprDifficulty.animation.addByPrefix('hard', 'HARD');
			// sprDifficulty.animation.play('easy');
			changeDifficulty();

			difficultySelectors.add(sprDifficulty);

			rightArrow = makeArrow(
				sprDifficulty.x + sprDifficulty.width + 50,
				leftArrow.y,
				Direction.RIGHT,
				ui_tex
			);

			difficultySelectors.add(rightArrow);
		}

		grpWeekCharacters.add(new MenuCharacter(0, 100, 0.5, false));
		grpWeekCharacters.add(new MenuCharacter(450, 25, 0.9, true));
		grpWeekCharacters.add(new MenuCharacter(850, 100, 0.5, true));

		add(storyBG);
		add(grpWeekCharacters);

		weekComment = visWeekComment;
		weekUnlocked = unlockedWeeks;
		visualTrackNames = visTrackNames;
		weekCharacters = modWeekCharacters;
		weekData = modTracks;

		if(modInfo.storyMenuColor != null) {
			modStoryColor = Std.parseInt(modInfo.storyMenuColor);
		} else {
			modStoryColor = StoryMenuState.DEFAULT_STORY_COLOR;
		}

		/*if (FlxG.sound.music != null)
		{
			if(curModStr != StoryMenuState.prevMod) {
				if (FlxG.sound.music.playing) {
					FlxG.sound.music.stop();
				}
				var currentFreakyPath = Paths.music('freakyMenu');

				FlxG.sound.playMusic(currentFreakyPath);
				StoryMenuState.prevMod = curModStr;
			}
		}*/

		trace("Line 96");

		txtTracklist = new FlxText(FlxG.width * 0.05, storyBG.x + storyBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);
		add(leftModArrow);
		add(rightModArrow);
		add(modNameText);

		updateText();

		trace("Line 165");

		FlxG.watch.add(this, "weekCharacters", "Characters");
		FlxG.watch.add(this, "curModStr", "Current Mod");
		FlxG.watch.add(this, "curMod", "Mod INDEX");
		FlxG.watch.add(this, "curWeek", "Current Week");
		//FlxG.watch.add(this, "mods", "Mods");
		FlxG.watch.add(this, "curDifficulty", "Current Difficulty");
		FlxG.watch.add(this, "weekData", "Week Tracks");
		FlxG.watch.add(this, "visualTrackNames", "Vis Track Name");
		FlxG.watch.add(this, "weekComment", "Week Comments");
		FlxG.watch.add(this, "weekUnlocked", "Unlocked Weeks");
		// FlxG.watch.add(this, "prevMod", "Previous Mod");
		// FlxG.watch.addQuick("Characters", weekCharacters);
		// FlxG.watch.addQuick("Mod", curModStr);
		// FlxG.watch.addQuick("Mod INDEX", curMod);
		// FlxG.watch.addQuick("Current Mod", curWeek);

		// super.create();
	}

	public function moveEverything(x:Float, y:Float) {
		var dx = x - currentX;
		var dy = y - currentY;

		var rawSprites = [
			storyBG,
			blackBarThingie,
			scoreText,
			leftModArrow,
			rightModArrow,
			txtWeekTitle,
			modNameText,
			txtTracklist
		];

		// grpWeekCharacters,
		//
		// ,grpWeekText

		var groupSprites:Array<FlxTypedGroup<FlxSprite>> = [
			grpLocks,
			difficultySelectors
		];

		// var groupSprites:Array<FlxSpriteGroup> = [
		// 	grpWeekCharacters,
		// 	grpWeekText
		// ];

		for(group in groupSprites) {
			for(i in 0...group.members.length) {
				group.members[i].x += dx;
				group.members[i].y += dy;
			}
		}

		/*for(i in 0...difficultySelectors.members.length) {
			difficultySelectors.members[i].x += dx;
			difficultySelectors.members[i].y += dy;
		}

		for(i in 0...grpLocks.members.length) {
			grpLocks.members[i].x += dx;
			grpLocks.members[i].y += dy;
		}*/

		for(i in 0...grpWeekCharacters.members.length) {
			grpWeekCharacters.members[i].x += dx;
			grpWeekCharacters.members[i].y += dy;
		}

		for(i in 0...grpWeekText.members.length) {
			grpWeekText.members[i].x += dx;
			grpWeekText.members[i].y += dy;
		}

		for(sprite in rawSprites) {
			sprite.x += dx;
			sprite.y += dy;
		}

		currentX = x;
		currentY = y;
	}

	override function update(elapsed:Float)
	{
		if(!isActive) {
			super.update(elapsed);
			return;
		}
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = weekComment[curWeek].toUpperCase();
		// txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);
		txtWeekTitle.x = rightModArrow.x - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UP_P)
				{
					changeWeek(-1);
				}

				if (controls.DOWN_P)
				{
					changeWeek(1);
				}

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopSpamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			if (stopSpamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				grpWeekCharacters.members[1].animation.play('bfConfirm');
				stopSpamming = true;
			}

			PlayState.storyVisNamePlaylist = visualTrackNames[curWeek];
			PlayState.storyPlaylist = weekData[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = "";

			switch (curDifficulty)
			{
				case 0:
					diffic = '-easy';
				case 2:
					diffic = '-hard';
			}

			PlayState.storyDifficulty = curDifficulty;

			var songName = PlayState.storyPlaylist[0].toLowerCase();
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			PlayState.currentMod = curModStr;
			StoryMenuState.weekUnlocked = weekUnlocked;
			LoadingState.setGlobals();
			PlayState.visualSongName = PlayState.storyVisNamePlaylist[0];
			PlayState.SONG = Song.loadFromJson(songName + diffic, songName);
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		else if (curDifficulty > 2)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		// intendedScore = Highscore.getWeekScore(curModStr, curWeek, curDifficulty);

		// Why 2 times?
		#if !switch
		intendedScore = Highscore.getWeekScore(curModStr, curWeek, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekData.length) {
			curWeek = 0;
		}
		else if (curWeek < 0) {
			curWeek = weekData.length - 1;
		}

		updateSelected();
	}

	function updateSelected() {
		var i = 0;
		for (item in grpWeekText.members)
		{
			item.targetY = i - curWeek;
			// if(item.isCategory) {
			// 	item.alpha = 1;
			// 	i++;
			// 	continue;
			// }
			
			if (item.targetY == 0 && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			i++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function updateText()
	{
		// trace(weekCharacters);

		txtTracklist.text = "Tracks\n";
		var stringThing:Array<String> = visualTrackNames[curWeek];

		for (i in stringThing)
			txtTracklist.text += "\n" + i;

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		txtTracklist.text += "\n";

		for(i in 0...3) {
			grpWeekCharacters.members[i].setCharacter(weekCharacters[curWeek][i]);
		}

		#if !switch
		intendedScore = Highscore.getWeekScore(curModStr, curWeek, curDifficulty);
		#end
	}

	function makeArrow(x:Float, y:Float, direction: Direction, ?ui_tex:FlxAtlasFrames, ?scale:Float = 1) {
		if(ui_tex == null) {
			ui_tex = StoryMenuState.default_ui_tex;
		}
		var arrow = new FlxSprite(x,y);
		arrow.antialiasing = true;

		arrow.frames = ui_tex;
		switch(direction) {
			case LEFT: {
				arrow.animation.addByPrefix('idle', "arrow left");
				arrow.animation.addByPrefix('press', "arrow push left");
			}
			case RIGHT: {
				arrow.animation.addByPrefix('idle', 'arrow right');
				arrow.animation.addByPrefix('press', "arrow push right", 24, false);
			}
		}
		
		arrow.animation.play('idle');
		arrow.updateHitbox();

		if(scale != 1) {
			arrow.setGraphicSize(Std.int(arrow.width*scale));
			arrow.updateHitbox();
		}
		return arrow;
	}

	public function changeStoryColor(color:Int) {
		// storyBG = storyBG.makeGraphic(FlxG.width, 400, color);
		storyBG.color = color;// = storyBG.makeGraphic(FlxG.width, 400, color);
	}

	public function fadeStoryColor(color:Int) {
		// var tween = new ColorTween();
		// tween.tween(0.2, StoryMenuState.storyColor, color, storyBG);
		// storyBG.color = color;
		// StoryMenuState.storyColor = color;
		tween = FlxTween.color(storyBG, 0.25, StoryMenuState.storyColor, color, {
			onUpdate: setColorGlobal
		});
	}

	public function stopTween() {
		if(tween != null) {
			tween.cancel();
		}
	}

	function setColorGlobal(tween:FlxTween) {
		StoryMenuState.storyColor = storyBG.color; // So if user changes quickly the color will fade from where it was
	}
}

enum Direction {
	LEFT;
	RIGHT;
}