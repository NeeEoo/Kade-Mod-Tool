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
	// static public var prevMod:String = "base";

	public static var weekUnlocked:Array<Bool> = []; // Make it set to the current mod

	var curWeek:Int = 0;
	var curMod:Int = 0;
	var targetScreen:Int = 0;
	var curModStr:String = "";

	static var lastMod = 0;

	static var default_ui_tex:FlxAtlasFrames;

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

		storyModGroup = new FlxTypedGroup<StoryMenuSubGroup>();

		trace(TitleState.mods);

		curModStr = TitleState.mods[lastMod];
		targetScreen = lastMod;
		prevTargetScreen = lastMod;
		curMod = lastMod;

		var currentMod = 0;

		for(mod in TitleState.mods) {
			var menuSubGroup = new StoryMenuSubGroup(0, 0, mod, currentMod);

			// menuSubGroup.moveEverything(menuSubGroup.currentX + FlxG.width*currentMod, menuSubGroup.currentY);
			menuSubGroup.moveEverything(menuSubGroup.currentX + FlxG.width*(currentMod-lastMod), menuSubGroup.currentY);

			if(currentMod == lastMod) {
				storyColor = menuSubGroup.modStoryColor;
				menuSubGroup.isActive = true;
				menuSubGroup.modSelected();
			}
			menuSubGroup.changeStoryColor(storyColor);

			storyModGroup.add(menuSubGroup);

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
			var wantedColor = storyModGroup.members[targetScreen].modStoryColor;
			var wantedTargetScreen = targetScreen;
			for(i in 0...storyModGroup.members.length) {
				var storyGroup = storyModGroup.members[i];
				var origX = storyGroup.currentX;

				var x = (FlxG.width*i) - (FlxG.width*targetScreen);
				FlxTween.num(origX, x, 0.25, {
					onComplete: function(twn:FlxTween) {
						storyModGroup.members[wantedTargetScreen].isActive = true;
						storyModGroup.members[wantedTargetScreen].modSelected();
						stopSpamming = false;
					}
				}, screenXTweenFunction.bind(storyGroup));

				storyGroup.isActive = false;
				storyGroup.stopTween();
				storyGroup.fadeStoryColor(wantedColor);
			}
			prevTargetScreen = targetScreen;
		}

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

						if(rightModArrowPressed) {
							rightModArrow.animation.play('press');
						} else {
							rightModArrow.animation.play('idle');
						}
					}
				}
			}

			/*if (controls.ACCEPT)
			{
				//selectWeek();
			}*/
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			// lastMod = 0;
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	function changeMod(change:Int = 0) {
		curMod += change;

		// curMod = curMod % mods.length;

		if (curMod >= TitleState.mods.length)
			curMod = 0;
		else if (curMod < 0)
			curMod = TitleState.mods.length - 1;

		targetScreen = curMod;
		curModStr = TitleState.mods[curMod];
		stopSpamming = true;
		lastMod = curMod;

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
