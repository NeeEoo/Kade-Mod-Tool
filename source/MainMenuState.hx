package;

import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
#if ng
import io.newgrounds.NG;
#end

#if (windows && DISCORD)
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	public static inline final nightly:String = "";

	public static inline final kadeModToolVer:String = "4.1" + nightly;
	public static inline final gameVer:String = "0.2.7.1";

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create()
	{
		#if (windows && DISCORD)
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Main Menu", null);
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.15;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.15;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}

		FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, gameVer + (Main.watermarks ? " FNF - Kade Mod Tool " + kadeModToolVer : ""), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		#if TESTING
		var testerStuff:FlxText = new FlxText(10, FlxG.height - 500, 0, "", 12);
		testerStuff.text += "This is a TESTING build\n";
		testerStuff.text += "for the Kade Mod Tool\n";
		testerStuff.text += "made by Ne_Eo and Lelmaster\n";
		testerStuff.text += "\n";
		testerStuff.text += "Do not redistribute this exectuable\n";
		// testerStuff.alignment = CENTER;
		testerStuff.scrollFactor.set();
		testerStuff.setFormat("VCR OSD Mono", 28, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		// storyBG = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400);
		add(testerStuff);
		#end

		var controlsStuff:FlxText = new FlxText(FlxG.width-500, FlxG.height - 300, 0, "", 12);
		controlsStuff.text += "Controls:\n";
		controlsStuff.text += "Change mod\n";
		controlsStuff.text += "Q or PAGEUP to go back\n";
		controlsStuff.text += "E or PAGEDOWN to go forward\n";
		#if debug
		controlsStuff.text += "Press F2 to open debugger\n";
		#end
		controlsStuff.scrollFactor.set();
		controlsStuff.setFormat("VCR OSD Mono", 28, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		controlsStuff.alignment = CENTER;
		add(controlsStuff);

		var http = new haxe.Http("https://raw.githubusercontent.com/NeeEoo/Kade-Mod-Tool/master/version.check");
		
		http.onData = function(data:String)
		{
			var NUM_NULL = -20210612;
			var bgWidth = Std.int(FlxG.width * 0.25);
			var text1:String = null;
			var newVersion:String = "";
			var alignment1:FlxTextAlign = LEFT;
			var alignment2:FlxTextAlign = LEFT;
			var bgHeight:Int = NUM_NULL;
			var x:Float = 0;
			var y:Float = NUM_NULL;
			var bx:Float = NUM_NULL;
			var by:Float = NUM_NULL;
			var cx:Float = NUM_NULL;
			var cy:Float = NUM_NULL;
			var bgAlpha:Float = 0.6;
			var fontSize1:Int = 24;
			var fontSize2:Int = 18;
			var textColor1:Int = FlxColor.WHITE;
			var textColor2:Int = FlxColor.WHITE;
			var bgColor:Int = 0xFF000000;
			var font1:String = Paths.font("vcr.ttf");
			var font2:String = Paths.font("vcr.ttf");
			var sysFont1:String = "";
			var sysFont2:String = "";

			var rows = data.split("\n");
			var changes:Array<String> = [];
			var inChanges = false;
			for(row in rows)
			{
				if(row.trim().toLowerCase() == ":changes:") {
					inChanges = true;
					continue;
				} else if(inChanges) {
					changes.push(row.trim());
					continue;
				}
				var setting = row.split("=");
				var key = setting[0].trim();
				var value = setting[1].trim();

				switch(key) {
					case 'w': bgWidth = Std.parseInt(value);
					case 'h': bgHeight = Std.parseInt(value);
					case 'x': x = Std.parseFloat(value);
					case 'y': y = Std.parseFloat(value);
					case 'bx': bx = Std.parseFloat(value);
					case 'by': by = Std.parseFloat(value);
					case 'cx': cx = Std.parseFloat(value);
					case 'cy': cy = Std.parseFloat(value);
					case 'fs1': fontSize1 = Std.parseInt(value);
					case 'fs2': fontSize2 = Std.parseInt(value);
					case 'c1': textColor1 = Std.parseInt(value);
					case 'c2': textColor2 = Std.parseInt(value);
					case 'a1': alignment1 = value.toLowerCase();
					case 'a2': alignment2 = value.toLowerCase();
					case 'f1': font1 = value;
					case 'f2': font2 = value;
					case 'sf1': sysFont1 = value;
					case 'sf2': sysFont2 = value;
					case 't': text1 = value.replace("\\n","\n");
					case 'a': bgAlpha = Std.parseFloat(value);
					case 'cb': bgColor = Std.parseInt(value);
					case 'v': newVersion = value;
				}
			}

			if (kadeModToolVer != newVersion && MainMenuState.nightly == "")
			{
				trace('Outdated! ' + newVersion + ' != ' + kadeModToolVer);

				if(bgHeight == NUM_NULL) {
					var changesRows = changes.length;
					bgHeight = fontSize1 * 3 + fontSize2 * changesRows;
				}

				if(y == NUM_NULL) y = FlxG.height - bgHeight;

				if(text1 == null) text1 = 'New Version Available\nNewest version is $newVersion\n';

				if(!text1.endsWith("\n")) text1 += "\n";

				var outdatedText = new FlxText(x, y, 0, text1, fontSize1);
				outdatedText.setFormat(font1, fontSize1, textColor1, alignment1);
				if(sysFont1 != "") outdatedText.systemFont = sysFont1;
				outdatedText.scrollFactor.set();

				if(bx == NUM_NULL) bx = outdatedText.x - 6;
				if(by == NUM_NULL) by = y;

				var background:FlxSprite = new FlxSprite(bx, by).makeGraphic(bgWidth, bgHeight, bgColor);
				background.alpha = bgAlpha;
				background.scrollFactor.set();

				if(cx == NUM_NULL) cx = outdatedText.x;
				if(cy == NUM_NULL) cy = outdatedText.y + (fontSize1 * 2);

				var changesText = new FlxText(cx, cy, 0, "", fontSize2);
				changesText.text = changes.join("\n") + "\n";
				changesText.setFormat(font2, fontSize2, textColor2, alignment2);
				if(sysFont2 != "") changesText.systemFont = sysFont2;
				changesText.scrollFactor.set();

				add(background);
				add(changesText);
				add(outdatedText);
			}
		}

		http.onError = function (error) {
			trace('http error: $error');
		}

		http.request();

		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game", "&"]);
					#else
					FlxG.openURL('https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game');
					#end
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 1.3, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, #if debug 0.1 #else 1 #end, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story mode':
										FlxG.switchState(new StoryMenuState());
										trace("Story Menu Selected");

									case 'freeplay':
										FlxG.switchState(new FreeplayState());
										trace("Freeplay Menu Selected");

									case 'options':
										FlxG.switchState(new OptionsMenu());
								}
							});
						}
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		else if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var sprMid = spr.getGraphicMidpoint();
				camFollow.setPosition(sprMid.x, sprMid.y);
			}

			spr.updateHitbox();
		});
	}
}
