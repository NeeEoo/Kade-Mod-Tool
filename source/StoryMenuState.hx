package;

import WeeksParser.SwagWeek;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
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

@:allow(StoryMenuSubGroup)
class StoryMenuState extends MusicBeatState
{
	static public inline var DEFAULT_STORY_COLOR = 0xFFF9CF51;
	static public var prevMod:String = "base";

	// var scoreText:FlxText;

	// var visualTrackNames:Map<String, Array<Dynamic>> = [];
	// var weekData:Map<String, Array<Dynamic>> = [];
	// var curDifficulty:Int = 1;

	public static var weekUnlocked:Array<Bool> = []; // Make it set to the current mod

	// var weekCharacters:Map<String, Array<Dynamic>> = [];
	// var weekComment:Map<String, Array<String>> = [];

	// var txtWeekTitle:FlxText;

	var curWeek:Int = 0;
	var curMod:Int = 0;
	var targetScreen:Int = 0;
	var curModStr:String = "base";
	var mods:Array<String> = [];

	// var txtTracklist:FlxText;

	// var grpWeekText:FlxTypedGroup<MenuItem>;
	// var grpWeekCharacters:Map<String, FlxTypedGroup<MenuCharacter>>;

	// var grpLocks:FlxTypedGroup<FlxSprite>;

	// var difficultySelectors:FlxGroup;
	// var sprDifficulty:FlxSprite;
	// var leftArrow:FlxSprite;
	// var rightArrow:FlxSprite;

	// var storyBG:FlxSprite;
	static var default_ui_tex:FlxAtlasFrames;

	static var storyColors:Map<String, Int> = [];
	static var storyColor:Int = DEFAULT_STORY_COLOR;

	var storyModGroup:FlxTypedGroup<StoryMenuSubGroup>;

	override function create()
	{
		#if (windows && DISCORD)
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		if(default_ui_tex == null) {
			default_ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets', "default");
		}
		
		// storyBG = new FlxSprite(0, 56);
		// changeStoryColor(DEFAULT_STORY_COLOR);

		storyModGroup = new FlxTypedGroup<StoryMenuSubGroup>();
		//add(grpWeekText);

		#if sys
		mods = FakeAssetLibrary.modsFound;
		#else
		mods = ["base"];
		#end

		trace(mods);

		curModStr = mods[0];

		// var totalWeeks = 0;
		var currentMod = 0;

		for(mod in mods) {
			var menuSubGroup = new StoryMenuSubGroup(0, 0, mod, currentMod);
			/*Paths.setCurrentMod(mod);

			var currentModInfo = WeeksParser.getWeeksInfoFromJson(mod);
			var visTrackNames:Array<Array<String>> = [];
			var visWeekComment:Array<String> = [];
			var unlockedWeeks:Array<Bool> = [];
			var modWeekCharacters:Array<Array<String>> = [];
			var modTracks:Array<Array<String>> = [];

			var weeks = currentModInfo.weeks;
			var totalWeeksInMod = 0;

			grpWeekCharacters[mod] = new FlxTypedGroup<MenuCharacter>();

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
					// trace(weekTrack, track);
					visTrack.push(weekText);
					weekTracks.push(weekTrack);
				}
				
				{
					var weekThing:MenuItem = new MenuItem(0, storyBG.y + storyBG.height + 10, totalWeeksInMod);
					weekThing.y += ((weekThing.height + 20) * totalWeeks);
					weekThing.targetY = totalWeeks;
					grpWeekText.add(weekThing);
	
					weekThing.screenCenter(X);
					weekThing.x += FlxG.width;
					weekThing.antialiasing = true;
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

				grpWeekCharacters[mod].add(new MenuCharacter(0, 100, 0.5, false));
				grpWeekCharacters[mod].add(new MenuCharacter(450, 25, 0.9, true));
				grpWeekCharacters[mod].add(new MenuCharacter(850, 100, 0.5, true));

				{
					difficultySelectors[mod] = new FlxGroup();
					add(difficultySelectors[mod]);

					// trace("Line 124");

					leftArrow = new FlxSprite(
						grpWeekText.members[0].x + grpWeekText.members[0].width + 10,
						grpWeekText.members[0].y + grpWeekText.members[0].height*1.5 + 10);
					leftArrow.frames = ui_tex;
					leftArrow.animation.addByPrefix('idle', "arrow left");
					leftArrow.animation.addByPrefix('press', "arrow push left");
					leftArrow.animation.play('idle');
					difficultySelectors.add(leftArrow);

					sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
					sprDifficulty.frames = ui_tex;
					sprDifficulty.animation.addByPrefix('easy', 'EASY');
					sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
					sprDifficulty.animation.addByPrefix('hard', 'HARD');
					// sprDifficulty.animation.play('easy');
					changeDifficulty();

					difficultySelectors.add(sprDifficulty);

					rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
					rightArrow.frames = ui_tex;
					rightArrow.animation.addByPrefix('idle', 'arrow right');
					rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
					rightArrow.animation.play('idle');
					difficultySelectors.add(rightArrow);
				}

				add(grpWeekCharacters);

				visWeekComment.push(weekInfo.comment);
				unlockedWeeks.push(!weekInfo.locked);
				visTrackNames.push(visTrack);
				modWeekCharacters.push(weekInfo.menuCharacters);
				modTracks.push(weekTracks);

				trace(modWeekCharacters);

				totalWeeksInMod++;
				totalWeeks++;
			}

			weekComment[mod] = visWeekComment;
			weekUnlocked[mod] = unlockedWeeks;
			visualTrackNames[mod] = visTrackNames;
			weekCharacters[mod] = modWeekCharacters;
			weekData[mod] = modTracks;*/
			
			// if(currentMod != 0) {
			menuSubGroup.moveEverything(menuSubGroup.currentX + FlxG.width*currentMod, menuSubGroup.currentY);
			//}

			/*for (item in menuSubGroup.members)
			{
				item.x += FlxG.width;
				// y = FlxMath.lerp(y, (targetY * 120) + 480, 0.17 * (60 / FlxG.save.data.fpsCap));
				// item.targetY = i - curWeek;
				
				//if (item.targetY == 0 && weekUnlocked[curWeek])
				//	item.alpha = 1;
				//else
				//	item.alpha = 0.6;
				// i++;
			}*/
			if(currentMod == 0) {
				storyColor = menuSubGroup.modStoryColor;
				menuSubGroup.isActive = true;
			}
			menuSubGroup.changeStoryColor(storyColor);

			storyModGroup.add(menuSubGroup);

			storyColors[mod] = menuSubGroup.modStoryColor;
			currentMod++;
		}
		add(storyModGroup);

		Paths.setCurrentMod(curModStr);

		/*if (FlxG.sound.music != null)
		{
			if(curModStr != prevMod) {
				if (FlxG.sound.music.playing) {
					FlxG.sound.music.stop();
				}
				var currentFreakyPath = Paths.music('freakyMenu');

				FlxG.sound.playMusic(currentFreakyPath);
				prevMod = curModStr;
			}
		}*/

		super.create();
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopSpamming:Bool = false;
	var prevTargetScreen = 0;

	function screenXTweenFunction(s:StoryMenuSubGroup, x:Float) {
		s.moveEverything(x, s.currentY);
	}

	override function update(elapsed:Float)
	{
		if(targetScreen != prevTargetScreen) {
			// var movementRatio = 0.17 * (60 / FlxG.save.data.fpsCap);
			var wantedColor = storyModGroup.members[targetScreen].modStoryColor;
			var wantedTargetScreen = targetScreen;
			for(i in 0...storyModGroup.members.length) {
				var storyGroup = storyModGroup.members[i];
				var origX = storyGroup.currentX;
				// var origY = storyGroup.currentY;
				// var x = FlxMath.lerp(origX, (FlxG.width*targetScreen) + (FlxG.width*i), movementRatio);
				var x = (FlxG.width*i) - (FlxG.width*targetScreen);
				FlxTween.num(origX, x, 0.25, {
					onComplete: function(twn:FlxTween) {
						storyModGroup.members[wantedTargetScreen].isActive = true;
						stopSpamming = false;
					}
				}, screenXTweenFunction.bind(storyGroup));
				// FlxTween.num(origX, x, 0.25, null, screenXTweenFunction.bind(storyGroup));
				// storyGroup.moveEverything(x, origY);
				storyGroup.isActive = false;
				storyGroup.stopTween();
				storyGroup.fadeStoryColor(wantedColor);
			}
			prevTargetScreen = targetScreen;
			// storyModGroup.members[targetScreen].isActive = true;
		}
		// scoreText.setFormat('VCR OSD Mono', 32);
		/*lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = weekComment[curModStr][curWeek].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		difficultySelectors.visible = weekUnlocked[curModStr][curWeek];

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});*/

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if(!stopSpamming) {
					if (FlxG.keys.justPressed.PAGEUP || FlxG.keys.justPressed.Q)
					{
						changeMod(-1);
					}
	
					if (FlxG.keys.justPressed.PAGEDOWN || FlxG.keys.justPressed.E)
					{
						changeMod(1);
					}
	
					var leftModArrowPressed = FlxG.keys.pressed.PAGEUP || FlxG.keys.pressed.Q;
					var rightModArrowPressed = FlxG.keys.pressed.PAGEDOWN || FlxG.keys.pressed.E;
	
					for(i in 0...storyModGroup.members.length) {
						var leftModArrow = storyModGroup.members[i].leftModArrow;
						var rightModArrow = storyModGroup.members[i].rightModArrow;
						if(leftModArrowPressed) {
							leftModArrow.animation.play('press');
						} else {
							leftModArrow.animation.play('idle');
						}
						// leftModArrow.updateHitbox();
						// leftModArrow.offset.set(-0.5 * (leftModArrow.width - leftModArrow.frameWidth), -0.5 * (leftModArrow.height - leftModArrow.frameHeight));
						
						if(rightModArrowPressed) {
							rightModArrow.animation.play('press');
						} else {
							rightModArrow.animation.play('idle');
						}
					}
				}
			}

			if (controls.ACCEPT)
			{
				//selectWeek();
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

	function changeMod(change:Int = 0) {
		curMod += change;

		// curMod = curMod % mods.length;

		if (curMod >= mods.length)
			curMod = 0;
		else if (curMod < 0)
			curMod = mods.length - 1;

		targetScreen = curMod;
		curModStr = mods[curMod];
		stopSpamming = true;

		Paths.setCurrentMod(curModStr);

		FlxG.sound.play(Paths.sound('scrollMenu'));


		// updateSelected();
	}

	override function destroy() {
		storyModGroup.forEach(function(group) {
			group.stopTween();
		});
		storyModGroup.destroy();
		super.destroy();
	}
}
