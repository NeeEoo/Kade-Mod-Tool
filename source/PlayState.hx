package;

import StoryBoardParser.SBTiming;
import StoryBoardParser.SBTimeUnit;
import StoryBoardParser.SBSection;
import WeeksParser.SwagWeeks;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
//import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;

#if (windows && DISCORD)
import Discord.DiscordClient;
#end
#if desktop
import Sys;
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;
	public static var openedSubState:FlxSubState = null;

	public static inline final DEFAULT_TIME_BG = FlxColor.GRAY;
	public static inline final DEFAULT_TIME_FILLED = FlxColor.LIME;
	public static inline final DEFAULT_HP_RED = 0xFFFF0000;
	public static inline final DEFAULT_HP_GREEN = 0xFF66FF33;

	public static var timeBarBackgroundColor:Int = DEFAULT_TIME_BG;
	public static var timeBarFilledColor:Int = DEFAULT_TIME_FILLED;
	public static var hpBarRedColor:Int = DEFAULT_HP_RED;
	public static var hpBarGreenColor:Int = DEFAULT_HP_GREEN;

	public static var curStage:String = "";
	public static var SONG:SwagSong;
	public static var MOD:SwagWeeks;
	public static var visualSongName = "";
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyVisNamePlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var currentMod:String = "";
	public static var songName:String = "";
	private var curSong:String = "";

	// public static var weekSong:Int = 0;

	private var shits:Int = 0;
	private var bads:Int = 0;
	private var goods:Int = 0;
	private var sicks:Int = 0;
	private var misses:Int = 0;

	var songPosBG:FlxSprite;
	var songPosBar:FlxBar;
	var songPosName:FlxText;

	public static var rep:Replay;
	public static var loadRep:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;

	#if (windows && DISCORD)
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var largeText:String = null;
	#end

	private var vocals:FlxSound;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;

	private var camZooming:Bool = false;

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;
	private var accuracy:Float = 0.00;
	//private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	//private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	//private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	public var storyBoardBG:FlxCamera;
	public var storyBoardBGFlw:FlxCamera;
	public var storyBoardFG:FlxCamera;
	public var storyBoardFGFlw:FlxCamera;
	public var storyBoardTop:FlxCamera;
	public var storyBoardTopFlw:FlxCamera;
	public var hasStoryBoard = false;
	public var storyBoard:StoryBoardParser;
	public var Tween:FlxTweenManager;
	public var hasIntroCutscene = false;
	public var inOutroCutscene = false;

	public var showOnlyStrums = false;
	public var showIntroCountdown = true;
	public var introLength:Int = 5000;
	public var outroLength:Int = 5000;
	public var outroStartTime:Int = 0;

	public static var offsetTesting:Bool = false;

	var notesHitArray:Array<Date> = [];

	public var dialogue:Array<String> = [];

	var halloweenBG:FlxSprite;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	// var fc:Bool = true;

	var bgGirls:BackgroundGirls;
	// var wiggleShit:WiggleEffect = new WiggleEffect();

	//var talking:Bool = true;
	var songScore:Int = 0;
	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	public static inline final daPixelZoom:Float = 6;

	// inline public static var theFunne:Bool = true;
	// var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	//public static var timeCurrently:Float = 0;
	// public static var timeCurrentlyR:Float = 0;

	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;
	// Per song additive offset
	public static var songOffset:Float = 0;

	private var showSongPosition:Bool = false;
	private var downscroll:Bool = false;
	private var npsDisplay:Bool = false;
	private var etternaTS:Float = 1;
	private var accuracyMod:Int = 1;
	private var accuracyDisplay:Bool = false;
	private var scrollSpeed:Float = 1;
	private var botPlay:Bool = false;

	private var executeModchart = false;

	// API stuff

	public function addObject(object:FlxBasic) { add(object); }
	public function removeObject(object:FlxBasic) { remove(object); }

	override public function create()
	{
		instance = this;

		this.Tween = new FlxTweenManager();

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FakeAssetLibrary.resetCache(Main.fakeAssetLibrary.library);

		repPresses = 0;
		repReleases = 0;

		showSongPosition = FlxG.save.data.songPosition;
		downscroll = FlxG.save.data.downscroll;
		npsDisplay = FlxG.save.data.npsDisplay;
		etternaTS = FlxG.save.data.etternaMode ? 1 : 1.7;
		accuracyMod = FlxG.save.data.accuracyMod;
		accuracyDisplay = FlxG.save.data.accuracyDisplay;
		scrollSpeed = FlxG.save.data.scrollSpeed;
		botPlay = FlxG.save.data.botplay;

		hasStoryBoard = StoryBoardParser.storyBoardExists();

		#if sys
		executeModchart = FileSystem.exists(Paths.luaWeekPath(PlayState.songName + "/modchart"));
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		trace('Mod chart: ' + executeModchart + " - " + Paths.luaWeekPath(PlayState.songName + "/modchart"));

		#if (windows && DISCORD)
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
			detailsText = "Story Mode: Week " + storyWeek;
		else
			detailsText = "Freeplay";

		if(MOD != null && MOD.modName != null) {
			largeText = "Mod: " + MOD.modName;
		}

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText + " " + visualSongName + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, largeText, iconRPC);
		#end

		storyBoardBG = new FlxCamera();
		camGame = new FlxCamera();
		camGame.bgColor.alpha = 0;

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		storyBoardFG = new FlxCamera();
		storyBoardFG.bgColor.alpha = 0;

		storyBoardBGFlw = new FlxCamera();
		storyBoardBGFlw.bgColor.alpha = 0;

		storyBoardFGFlw = new FlxCamera();
		storyBoardFGFlw.bgColor.alpha = 0;

		storyBoardTopFlw = new FlxCamera();
		storyBoardTopFlw.bgColor.alpha = 0;

		storyBoardTop = new FlxCamera();
		storyBoardTop.bgColor.alpha = 0;

		FlxG.cameras.reset(storyBoardBG);
		FlxG.cameras.add(storyBoardBGFlw);
		FlxG.cameras.add(camGame);
		FlxG.camera = camGame;
		FlxG.cameras.add(storyBoardFGFlw);
		FlxG.cameras.add(storyBoardFG);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(storyBoardTopFlw);
		FlxG.cameras.add(storyBoardTop);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + Conductor.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTime Scale: ' + Conductor.timeScale);

		var file = Paths.txtWeek(PlayState.songName + '/dialogue', "week" + storyWeek, "weeks");
		if(Paths.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}

		switch(SONG.stage)
		{
			case 'halloween':
			{
				curStage = 'spooky';

				var hallowTex = Paths.getSparrowAtlas('stages/halloween/halloween_bg');

				halloweenBG = new FlxSprite(-200, -100);
				halloweenBG.frames = hallowTex;
				halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				halloweenBG.animation.play('idle');
				halloweenBG.antialiasing = true;
				add(halloweenBG);
			}
			case 'philly':
			{
				curStage = 'philly';

				var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('stages/philly/sky'));
				bg.scrollFactor.set(0.1, 0.1);
				bg.active = false;
				add(bg);

				var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('stages/philly/city'));
				city.scrollFactor.set(0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				city.active = false;
				add(city);

				phillyCityLights = new FlxTypedGroup<FlxSprite>();
				add(phillyCityLights);

				// Make this dynamic?
				for (i in 0...5)
				{
					var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('stages/philly/win' + i));
					light.scrollFactor.set(0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					light.antialiasing = true;
					light.active = false;
					phillyCityLights.add(light);
				}

				var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('stages/philly/behindTrain'));
				streetBehind.active = false;
				add(streetBehind);

				phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('stages/philly/train'));
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);

				var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('stages/philly/street'));
				street.active = false;
				add(street);
			}
			case 'limo':
			{
				curStage = 'limo';
				defaultCamZoom = 0.90;

				var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('stages/limo/limoSunset'));
				skyBG.scrollFactor.set(0.1, 0.1);
				skyBG.active = false;
				add(skyBG);

				var bgLimo:FlxSprite = new FlxSprite(-200, 480);
				bgLimo.frames = Paths.getSparrowAtlas('stages/limo/bgLimo');
				bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
				bgLimo.animation.play('drive');
				bgLimo.scrollFactor.set(0.4, 0.4);
				add(bgLimo);

				grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
				add(grpLimoDancers);

				for (i in 0...5)
				{
					var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
					dancer.scrollFactor.set(0.4, 0.4);
					grpLimoDancers.add(dancer);
				}

				// var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('stages/limo/limoOverlay'));
				// overlayShit.alpha = 0.5;
				// add(overlayShit);

				// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

				// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

				// overlayShit.shader = shaderBullshit;

				var limoTex = Paths.getSparrowAtlas('stages/limo/limoDrive');

				limo = new FlxSprite(-120, 550);
				limo.frames = limoTex;
				limo.animation.addByPrefix('drive', "Limo stage", 24);
				limo.animation.play('drive');
				limo.antialiasing = true;

				fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('stages/limo/fastCarLol'));
				// add(limo);
			}
			case 'mall':
			{
				curStage = 'mall';

				defaultCamZoom = 0.80;

				var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('stages/mall/bgWalls'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				upperBoppers = new FlxSprite(-240, -90);
				upperBoppers.frames = Paths.getSparrowAtlas('stages/mall/upperBop');
				upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
				upperBoppers.antialiasing = true;
				upperBoppers.scrollFactor.set(0.33, 0.33);
				upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
				upperBoppers.updateHitbox();
				add(upperBoppers);

				var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('stages/mall/bgEscalator'));
				bgEscalator.antialiasing = true;
				bgEscalator.scrollFactor.set(0.3, 0.3);
				bgEscalator.active = false;
				bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
				bgEscalator.updateHitbox();
				add(bgEscalator);

				var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('stages/mall/christmasTree'));
				tree.antialiasing = true;
				tree.scrollFactor.set(0.40, 0.40);
				tree.active = false;
				add(tree);

				bottomBoppers = new FlxSprite(-300, 140);
				bottomBoppers.frames = Paths.getSparrowAtlas('stages/mall/bottomBop');
				bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
				bottomBoppers.antialiasing = true;
				bottomBoppers.scrollFactor.set(0.9, 0.9);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('stages/mall/fgSnow'));
				fgSnow.active = false;
				fgSnow.antialiasing = true;
				add(fgSnow);

				santa = new FlxSprite(-840, 150);
				santa.frames = Paths.getSparrowAtlas('stages/mall/santa');
				santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
				santa.antialiasing = true;
				add(santa);
			}
			case 'mallEvil':
			{
				curStage = 'mallEvil';
				var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('stages/mallEvil/evilBG'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('stages/mallEvil/evilTree'));
				evilTree.antialiasing = true;
				evilTree.scrollFactor.set(0.2, 0.2);
				add(evilTree);

				var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("stages/mallEvil/evilSnow"));
				evilSnow.antialiasing = true;
				add(evilSnow);
			}
			case 'school' | 'schoolWorry':
			{
				curStage = 'school';

				// defaultCamZoom = 0.9;

				var bgSky = new FlxSprite().loadGraphic(Paths.image('stages/school/weebSky'));
				bgSky.scrollFactor.set(0.1, 0.1);
				bgSky.active = false;
				add(bgSky);

				var repositionShit = -200;

				var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('stages/school/weebSchool'));
				bgSchool.scrollFactor.set(0.6, 0.90);
				bgSchool.active = false;
				add(bgSchool);

				var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('stages/school/weebStreet'));
				bgStreet.scrollFactor.set(0.95, 0.95);
				bgStreet.active = false;
				add(bgStreet);

				var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('stages/school/weebTreesBack'));
				fgTrees.scrollFactor.set(0.9, 0.9);
				fgTrees.active = false;
				add(fgTrees);

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				var treetex = Paths.getPackerAtlas('stages/school/weebTrees');
				bgTrees.frames = treetex;
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);

				var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
				treeLeaves.frames = Paths.getSparrowAtlas('stages/school/petals');
				treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
				treeLeaves.animation.play('leaves');
				treeLeaves.scrollFactor.set(0.85, 0.85);
				add(treeLeaves);

				var widShit = Std.int(bgSky.width * 6);

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));
				fgTrees.setGraphicSize(Std.int(widShit * 0.8));
				treeLeaves.setGraphicSize(widShit);

				fgTrees.updateHitbox();
				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();
				treeLeaves.updateHitbox();

				bgGirls = new BackgroundGirls(-100, 190);
				bgGirls.scrollFactor.set(0.9, 0.9);

				if (songName == 'roses' || SONG.stage == 'schoolWorry')
				{
					bgGirls.getScared();
				}

				bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
				bgGirls.updateHitbox();
				add(bgGirls);
			}
			case 'schoolEvil':
			{
				curStage = 'schoolEvil';

				// var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
				// var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

				var posX = 400;
				var posY = 200;

				var bg:FlxSprite = new FlxSprite(posX, posY);
				bg.frames = Paths.getSparrowAtlas('stages/schoolEvil/animatedEvilSchool');
				bg.animation.addByPrefix('idle', 'background 2', 24);
				bg.animation.play('idle');
				bg.scrollFactor.set(0.8, 0.9);
				bg.scale.set(6, 6);
				add(bg);

				/*
						var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('stages/schoolEvil/evilSchoolBG'));
						bg.scale.set(6, 6);
						// bg.setGraphicSize(Std.int(bg.width * 6));
						// bg.updateHitbox();
						add(bg);
						var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('stages/schoolEvil/evilSchoolFG'));
						fg.scale.set(6, 6);
						// fg.setGraphicSize(Std.int(fg.width * 6));
						// fg.updateHitbox();
						add(fg);
						wiggleShit.effectType = WiggleEffectType.DREAMY;
						wiggleShit.waveAmplitude = 0.01;
						wiggleShit.waveFrequency = 60;
						wiggleShit.waveSpeed = 0.8;
					*/

				// bg.shader = wiggleShit.shader;
				// fg.shader = wiggleShit.shader;

				/*
							var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
							var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);
							// Using scale since setGraphicSize() doesnt work???
							waveSprite.scale.set(6, 6);
							waveSpriteFG.scale.set(6, 6);
							waveSprite.setPosition(posX, posY);
							waveSpriteFG.setPosition(posX, posY);
							waveSprite.scrollFactor.set(0.7, 0.8);
							waveSpriteFG.scrollFactor.set(0.9, 0.8);
							// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
							// waveSprite.updateHitbox();
							// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
							// waveSpriteFG.updateHitbox();
							add(waveSprite);
							add(waveSpriteFG);
					*/
			}
			case 'blank':
			{
				curStage = 'blank';
			}
			// stage = 'stage' goes here
			default:
			{
				defaultCamZoom = 0.9;
				curStage = 'stage';
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stages/stage/stageback'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stages/stage/stagefront'));
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				stageFront.active = false;
				add(stageFront);

				var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stages/stage/stagecurtains'));
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;

				add(stageCurtains);
			}
		}

		var gfVersion:String = 'gf';

		switch (SONG.gfVersion)
		{
			case 'gf-car':
				gfVersion = 'gf-car';
			case 'gf-christmas':
				gfVersion = 'gf-christmas';
			case 'gf-pixel':
				gfVersion = 'gf-pixel';
			default:
				gfVersion = 'gf';
		}

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = dad.getGraphicMidpoint();

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai' | 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				var mid = dad.getGraphicMidpoint();
				camPos.set(mid.x + 300, mid.y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				var mid = dad.getGraphicMidpoint();
				camPos.set(mid.x + 300, mid.y);
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;

			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;

			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				add(evilTrail);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
		}

		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		var doof:DialogueSystem = new DialogueSystem(dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		if(hasStoryBoard) storyBoard = new StoryBoardParser();

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong();

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		var lerpCam = 0.04 * (30 / (cast (Lib.current.getChildAt(0), Main)).getFPS());
		var cameras = [storyBoardTopFlw, storyBoardFGFlw, storyBoardBGFlw, FlxG.camera];
		for(camera in cameras)
		{
			camera.follow(camFollow, LOCKON, lerpCam);
			camera.zoom = defaultCamZoom;
			camera.focusOn(camFollow.getPosition());
		}

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		timeBarBackgroundColor = DEFAULT_TIME_BG;
		timeBarFilledColor = DEFAULT_TIME_FILLED;
		hpBarRedColor = DEFAULT_HP_RED;
		hpBarGreenColor = DEFAULT_HP_GREEN;

		if(MOD != null) {
			if(MOD.hudColors != null) {
				var hudColors = MOD.hudColors;
				if(hudColors.timeBarBackground != null) timeBarBackgroundColor = Std.parseInt(hudColors.timeBarBackground);
				if(hudColors.timeBarFilled != null) timeBarFilledColor = Std.parseInt(hudColors.timeBarFilled);
				if(hudColors.healthBarRed != null) hpBarRedColor = Std.parseInt(hudColors.healthBarRed);
				if(hudColors.healthBarGreen != null) hpBarGreenColor = Std.parseInt(hudColors.healthBarGreen);
			}
		}

		// Duplicated code from start song?
		if (showSongPosition) // I dont wanna talk about this code :(
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('timeBar'));
			if (downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, 90000);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(timeBarBackgroundColor, timeBarFilledColor);
			songPosBar.screenCenter(X);
			add(songPosBar);

			songPosName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20, songPosBG.y, 0, visualSongName, 16);
			if (downscroll)
				songPosName.y -= 3;
			songPosName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songPosName.scrollFactor.set();
			songPosName.screenCenter(X);
			add(songPosName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songPosName.cameras = [camHUD];
		}

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(hpBarRedColor, hpBarGreenColor);
		healthBar.screenCenter(X);
		add(healthBar);

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(
			4,
			healthBarBG.y + 50 #if TESTING - 10 #end,
			0,
			visualSongName + " " + (storyDifficulty == 2 ? "Hard" : storyDifficulty == 1 ? "Normal" : "Easy") +
				#if TESTING "\nMOD TOOL TESTING BUILD - 0000000\n" #else (Main.watermarks ? " - KMT " + MainMenuState.kadeModToolVer : "") #end,
			16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, #if TESTING LEFT #else RIGHT #end, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (downscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45 #if TESTING - 10 #end;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);
		if (!accuracyDisplay)
			scoreTxt.x = healthBarBG.x + healthBarBG.width / 2;
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		if (offsetTesting)
			scoreTxt.x += 300;
		add(scoreTxt);

		if (loadRep)
		{
			var replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (downscroll ? 100 : -100), 0, "REPLAY", 20);
			replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			replayTxt.scrollFactor.set();
			add(replayTxt);

			replayTxt.cameras = [camHUD];
		}

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		kadeEngineWatermark.cameras = [camHUD];

		startingSong = true;

		if(hasStoryBoard && storyBoard.sectionActions.exists(SBSection.STARTING_CUTSCENE))
		{
			inCutscene = true;
			storyBoard.currentSection = SBSection.STARTING_CUTSCENE;
			hasIntroCutscene = true;
			Conductor.songPosition = -introLength;
			transIn = null; // So that videos don't bug out
		}
		else
		{
			if (isStoryMode)
			{
				switch (curSong)
				{
					case "winter-horrorland":
						var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
						add(blackScreen);
						blackScreen.scrollFactor.set();
						camHUD.visible = false;

						new FlxTimer().start(0.1, function(tmr:FlxTimer)
						{
							remove(blackScreen);
							FlxG.sound.play(Paths.sound('Lights_Turn_On'));
							camFollow.y = -2050;
							camFollow.x += 200;

							var cameras = [storyBoardTopFlw, storyBoardFGFlw, storyBoardBGFlw, FlxG.camera];
							for(camera in cameras)
							{
								camera.focusOn(camFollow.getPosition());
								camera.zoom = 1.5;
							}

							new FlxTimer().start(0.8, function(tmr:FlxTimer)
							{
								camHUD.visible = true;
								remove(blackScreen);
								var extraCameras = [storyBoardTopFlw, storyBoardFGFlw, storyBoardBGFlw];
								for(camera in extraCameras)
									Tween.tween(camera, {zoom: defaultCamZoom}, 2.5, {ease: FlxEase.quadInOut});

								Tween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
									ease: FlxEase.quadInOut,
									onComplete: function(twn:FlxTween)
									{
										startCountdown();
									}
								});
							});
						});
					case 'senpai':
						schoolIntro(doof);
					case 'roses':
						FlxG.sound.play(Paths.sound('ANGRY'));
						schoolIntro(doof);
					case 'thorns':
						schoolIntro(doof);
					default:
						if(dialogue.length != 0) {
							simpleDialogueIntro(doof);
						} else {
							startCountdown();
						}
				}
			}
			else
			{
				//switch (curSong.toLowerCase())
				//{
				//	default:
				startCountdown();
				//}
			}
		}

		if (!loadRep)
			rep = new Replay("na");

		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueSystem):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (songName == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
				{
					startCountdown();
				}

				remove(black);
			}
		});
	}

	function simpleDialogueIntro(?dialogueBox:DialogueSystem):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;
					add(dialogueBox);
				}
				else
				{
					startCountdown();
				}

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	//var perfectMode:Bool = false;

	#if windows
	//var luaWiggles:Array<WiggleEffect> = [];
	public static var luaModchart:ModchartState = null;
	#end

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		#if windows
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start', [PlayState.songName]);
		}
		#end

		//talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0 - Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			if(!showIntroCountdown) return;

			var introAssets = [
				'default' => ['ready', 'set', 'go'],
				'school' => ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel'],
				'schoolEvil' => ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']
			];

			var introAlts:Array<String> = introAssets['default'];

			var altSuffix:String = "";

			if (introAssets.exists(curStage))
			{
				introAlts = introAssets[curStage];
				altSuffix = '-pixel';
			}

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					Tween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					Tween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					// Make it check the note style?
					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					Tween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
		}, 5);
	}

	var songTime:Float = 0;

	var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;

		if (!paused)
			FlxG.sound.playMusic(Paths.instWeek(PlayState.songName, "week" + storyWeek), 1, false);

		FlxG.sound.music.onComplete = shouldEndSong;
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (showSongPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songPosName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('timeBar'));
			if (downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength - 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(timeBarBackgroundColor, timeBarFilledColor);
			songPosBar.screenCenter(X);
			add(songPosBar);

			songPosName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20, songPosBG.y, 0, visualSongName, 16);
			if (downscroll)
				songPosName.y -= 3;
			songPosName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songPosName.scrollFactor.set();
			songPosName.screenCenter(X);
			add(songPosName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songPosName.cameras = [camHUD];
		}

		// Song check real quick
		switch(curSong)
		{
			case 'bopeebo' | 'philly' | 'blammed' | 'cocoa' | 'eggnog': allowedToHeadbang = true;
			default: allowedToHeadbang = false;
		}

		#if (windows && DISCORD)
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + visualSongName + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, largeText, iconRPC);
		#end
	}

	private function generateSong():Void
	{
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		//curSong = songData.song;
		curSong = songName.toLowerCase();
		vocals = new FlxSound();

		if (SONG.needsVoices)
			vocals.loadEmbedded(Paths.voicesWeek(curSong, "week" + storyWeek));

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection> = songData.notes;

		// Per song offset check
		#if desktop
		var songPath = Paths.weekPath(curSong + '/', "week" + storyWeek);
		// trace("OFFSET: "+ songPath);
		var foundOffsetFile = false;
		for(file in sys.FileSystem.readDirectory(songPath))
		{
			var path = haxe.io.Path.join([songPath, file]);
			if(!sys.FileSystem.isDirectory(path))
			{
				if(path.endsWith('.offset'))
				{
					trace('Found offset file: ' + path);
					foundOffsetFile = true;
					songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
					break;
				}
			}
		}

		if(!foundOffsetFile) {
			songOffset = 0;
			trace('Offset file not found. Creating one @: ' + songPath);
			sys.io.File.saveContent(songPath + songOffset + '.offset', '');
		}
		#end
		// var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			// var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes.strumTime + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes.noteData % 4);
				var daNoteSpeed = songNotes.noteSpeed;
				var daAltAnim = songNotes.altAnim == 1;

				if(daNoteSpeed == null) {
					daNoteSpeed = SONG.speed;
				}

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes.noteData > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note = null;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[unspawnNotes.length - 1];

				var swagNote:Note = new Note(daStrumTime, daNoteData, daNoteSpeed, oldNote);
				swagNote.altAnim = daAltAnim;
				swagNote.sustainLength = songNotes.holdLength;
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength / Conductor.stepCrochet;

				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[unspawnNotes.length - 1];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, daNoteSpeed, oldNote, true);
					sustainNote.altAnim = daAltAnim;
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			// daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	static function sortByShit(obj1:Note, obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, obj1.strumTime, obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (SONG.noteStyle)
			{
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('pixelUI/arrows-pixels'), true, 17, 17);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (i)
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				// case 'normal' goes here
				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (i)
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				// Make the notes have a effect when starting
				Tween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			// TODO: FIX NOTES BEING OFFCENTER
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		var duration:Float = Conductor.stepCrochet * 4 / 1000;
		var cameras = [storyBoardTopFlw, storyBoardFGFlw, storyBoardBGFlw, FlxG.camera];
		for(camera in cameras)
			Tween.tween(camera, {zoom: 1.3}, duration, {ease: FlxEase.elasticInOut});
	}

	public function openPausedSubState(subState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			Tween.active = false;

			if(hasStoryBoard)
				for(video in storyBoard.videos) video.pause();

			var cameras = FlxG.cameras.list;
			for(camera in cameras) camera.active = false;

			#if (windows && DISCORD)
			DiscordClient.changePresence("PAUSED on " + visualSongName + " (" + storyDifficultyText + ") " + generateRanking(), "Acc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, largeText, iconRPC);
			#end
			if(startTimer != null && !startTimer.finished)
				startTimer.active = false;
		}

		openedSubState = subState;
		openSubState(subState);
	}

	public function closePausedSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if(startTimer != null && !startTimer.finished)
				startTimer.active = true;

			paused = false;

			Tween.active = true;

			if(hasStoryBoard)
				for(video in storyBoard.videos) video.resume();

			var cameras = FlxG.cameras.list;
			for(camera in cameras) camera.active = true;

			#if (windows && DISCORD)
			if (startTimer != null && startTimer.finished)
				DiscordClient.changePresence(detailsText + " " + visualSongName + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, largeText, iconRPC, true, songLength - Conductor.songPosition);
			else
				DiscordClient.changePresence(detailsText, visualSongName + " (" + storyDifficultyText + ") " + generateRanking(), largeText, iconRPC);
			#end
		}

		openedSubState = null;
		closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if (windows && DISCORD)
		DiscordClient.changePresence(detailsText + " " + visualSongName + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, largeText, iconRPC);
		#end
	}

	public var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function truncateFloat(number:Float, precision:Int): Float {
		var perc = Math.pow(10, precision);
		return Math.round(number * perc) / perc;
	}

	function generateRanking():String
	{
		var ranking:String = "N/A";

		if (accuracy == 0)
			return "N/A";

		if (misses == 0 && bads == 0 && shits == 0 && goods == 0) // Marvelous (SICK) Full Combo
			ranking = "(MFC)";
		else if (misses == 0 && bads == 0 && shits == 0 && goods >= 1) // Good Full Combo (Nothing but Goods & Sicks)
			ranking = "(GFC)";
		else if (misses == 0) // Regular FC
			ranking = "(FC)";
		else if (misses < 10) // Single Digit Combo Breaks
			ranking = "(SDCB)";
		else
			ranking = "(Clear)";

		// WIFE TIME :)))) (based on Wife3)

		var wifeConditions:Array<Bool> = [
			accuracy >= 99.9935, // AAAAA
			accuracy >= 99.980, // AAAA:
			accuracy >= 99.970, // AAAA.
			accuracy >= 99.955, // AAAA
			accuracy >= 99.90, // AAA:
			accuracy >= 99.80, // AAA.
			accuracy >= 99.70, // AAA
			accuracy >= 99, // AA:
			accuracy >= 96.50, // AA.
			accuracy >= 93, // AA
			accuracy >= 90, // A:
			accuracy >= 85, // A.
			accuracy >= 80, // A
			accuracy >= 70, // B
			accuracy >= 60, // C
			accuracy < 60 // D
		];

		for(i in 0...wifeConditions.length)
		{
			var b = wifeConditions[i];
			if (b)
			{
				switch(i)
				{
					case 0:
						ranking += " AAAAA";
					case 1:
						ranking += " AAAA:";
					case 2:
						ranking += " AAAA.";
					case 3:
						ranking += " AAAA";
					case 4:
						ranking += " AAA:";
					case 5:
						ranking += " AAA.";
					case 6:
						ranking += " AAA";
					case 7:
						ranking += " AA:";
					case 8:
						ranking += " AA.";
					case 9:
						ranking += " AA";
					case 10:
						ranking += " A:";
					case 11:
						ranking += " A.";
					case 12:
						ranking += " A";
					case 13:
						ranking += " B";
					case 14:
						ranking += " C";
					case 15:
						ranking += " D";
				}
				break;
			}
		}

		return ranking;
	}

	function storyBoardUpdate() {
		if(storyBoard.timeUnit == SBTimeUnit.MS) {
			storyBoard.runGameplayStep(Std.int(Conductor.songPosition));
		}
		if(hasIntroCutscene) {
			storyBoard.runIntroCutsceneStep(introLength + Std.int(Conductor.songPosition));
		}
		if(inOutroCutscene) {
			var currentTime = Std.int(Conductor.songPosition) - outroStartTime;
			storyBoard.runOutroCutsceneStep(currentTime);
			if(!hasEnded && currentTime > outroLength) {
				endSong();
			}
		}
	}

	public var hasEnded:Bool = false;

	override public function update(elapsed:Float)
	{
		/*#if !debug
		perfectMode = false;
		#end*/

		if(hasStoryBoard) {
			if(!inOutroCutscene) {
				if(storyBoard.currentSection != SBSection.GAMEPLAY && Conductor.songPosition >= 0) {
					storyBoard.currentSection = SBSection.GAMEPLAY;
				}
			}
		}

		if(Tween.active) {
			Tween.update(elapsed);
		}

		var oldShowOnlyStrums = showOnlyStrums;

		#if windows
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);

			/*for (i in luaWiggles)
			{
				// trace('wiggle le gaming');
				i.update(elapsed);
			}*/

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = luaModchart.getVar("strum" + i + "X", "float");
				member.y = luaModchart.getVar("strum" + i + "Y", "float");
				member.angle = luaModchart.getVar("strum" + i + "Angle", "float");
			}*/

			var cameraAngle:Float = luaModchart.getVar('cameraAngle', 'float');

			storyBoardTopFlw.angle = cameraAngle;
			storyBoardFGFlw.angle = cameraAngle;
			storyBoardBGFlw.angle = cameraAngle;
			FlxG.camera.angle = cameraAngle;
			camHUD.angle = luaModchart.getVar('camHudAngle', 'float');

			showOnlyStrums = luaModchart.getVar("showOnlyStrums", 'bool');

			var p1 = luaModchart.getVar("strumLine1Visible", 'bool');
			var p2 = luaModchart.getVar("strumLine2Visible", 'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
		}
		#end

		if(hasStoryBoard && storyBoard.timing == SBTiming.EXACT) {
			storyBoardUpdate();
		}

		if(oldShowOnlyStrums != showOnlyStrums)
		{
			if(showOnlyStrums)
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
				if(showSongPosition) {
					songPosName.visible = false;
					songPosBar.visible = false;
					songPosBG.visible = false;
				}
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
				if(showSongPosition) {
					songPosName.visible = true;
					songPosBar.visible = true;
					songPosBG.visible = true;
				}
			}
		}

		{
			var balls = notesHitArray.length-1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
		}

		super.update(elapsed);

		if(inDialogue) return;

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		if(curStage == "philly") {
			if (trainMoving)
			{
				trainFrameTiming += elapsed;

				if (trainFrameTiming >= 1 / 24)
				{
					updateTrainPos();
					trainFrameTiming = 0;
				}
			}
		}

		if (!offsetTesting)
		{
			if (accuracyDisplay)
			{
				scoreTxt.text = (npsDisplay ? "NPS: " + nps + " | " : "") + "Score:" + (Conductor.safeFrames != 10 ? songScore + " (" + songScoreDef + ")" : "" + songScore) + " | Combo Breaks:" + misses + " | Accuracy:" + truncateFloat(accuracy, 2) + "% | " + generateRanking();
			}
			else
			{
				scoreTxt.text = (npsDisplay ? "NPS: " + nps + " | " : "") + "Score:" + songScore;
			}
		}
		else
		{
			scoreTxt.text = "Suggested Offset: " + offsetTest;
		}

		if (FlxG.keys.justPressed.ENTER && (startedCountdown || (hasIntroCutscene && Conductor.songPosition < 0)) && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
			{
				var pos = boyfriend.getScreenPosition();
				openPausedSubState(new PauseSubState(pos.x, pos.y));
			}
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());
			destroyStuff();
		}

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		final iconOffset:Int = 26;

		var remappedHealth:Float = healthBar.x + (healthBar.width * ((100 - healthBar.percent) * 0.01));

		iconP1.x = remappedHealth - (iconOffset);
		iconP2.x = remappedHealth - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
		{
			FlxG.switchState(new AnimationDebug(SONG.player2));
			destroyStuff();
		}

		if (FlxG.keys.justPressed.ZERO)
		{
			FlxG.switchState(new AnimationDebug(SONG.player1));
			destroyStuff();
		}
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
			else if(hasIntroCutscene)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				//if(Conductor.songPosition >= 0 - Conductor.crochet * 5) {
				if(Conductor.songPosition >= -5000) {
					startCountdown();
				}
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			songPositionBar = Conductor.songPosition;
		}

		var curSection = PlayState.SONG.notes[Std.int(curStep / 16)];

		if (generatedMusic && curSection != null)
		{
			// Make sure Girlfriend cheers only for certain songs
			if(allowedToHeadbang)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if(gf.animation.curAnim.name == 'danceLeft' || gf.animation.curAnim.name == 'danceRight' || gf.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch(curSong)
					{
						case 'philly':
						{
							// General duration of the song
							if(curBeat < 250)
							{
								// Beats to skip or to stop GF from cheering
								if(curBeat != 184 && curBeat != 216)
								{
									if(curBeat % 16 == 8)
									{
										// Just a garantee that it'll trigger just once
										if(!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									} else triggeredAlready = false;
								}
							}
						}
						case 'bopeebo':
						{
							// Where it starts || where it ends
							// The curBeat > 5 might be unneeded
							if(curBeat > 5 && curBeat < 130)
							{
								if(curBeat % 8 == 7)
								{
									if(!triggeredAlready)
									{
										gf.playAnim('cheer');
										triggeredAlready = true;
									}
								} else triggeredAlready = false;
							}
						}
						case 'blammed':
						{
							if(curBeat > 30 && curBeat < 190)
							{
								if(curBeat < 90 || curBeat > 128)
								{
									if(curBeat % 4 == 2)
									{
										if(!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									} else triggeredAlready = false;
								}
							}
						}
						case 'cocoa':
						{
							if(curBeat < 170)
							{
								if(curBeat < 65 || (curBeat > 130 && curBeat < 145))
								{
									if(curBeat % 16 == 15)
									{
										if(!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									} else triggeredAlready = false;
								}
							}
						}
						case 'eggnog':
						{
							if(curBeat > 10 && curBeat != 111 && curBeat < 220)
							{
								if(curBeat % 8 == 7)
								{
									if(!triggeredAlready)
									{
										gf.playAnim('cheer');
										triggeredAlready = true;
									}
								} else triggeredAlready = false;
							}
						}
					}
				}
			}

			#if windows
			if (luaModchart != null)
				luaModchart.setVar("mustHit", curSection.mustHitSection);
			#end

			var dadMidpoint = dad.getMidpoint();

			if (!curSection.mustHitSection && camFollow.x != dadMidpoint.x + 150)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if windows
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(dadMidpoint.x + 150 + offsetX, dadMidpoint.y - 100 + offsetY);

				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerTwoTurn', []);
				#end

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dadMidpoint.y;
					case 'senpai' | 'senpai-angry':
						camFollow.y = dadMidpoint.y - 430;
						camFollow.x = dadMidpoint.x - 100;
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (curSong == 'tutorial')
				{
					tweenCamIn();
				}
			}

			var bfMidpoint = boyfriend.getMidpoint();

			if (curSection.mustHitSection && camFollow.x != bfMidpoint.x - 100)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if windows
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(bfMidpoint.x - 100 + offsetX, bfMidpoint.y - 100 + offsetY);

				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerOneTurn', []);
				#end

				switch (curStage)
				{
					case 'limo':
						camFollow.x = bfMidpoint.x - 300;
					case 'mall':
						camFollow.y = bfMidpoint.y - 200;
					case 'school' | 'schoolEvil':
						camFollow.x = bfMidpoint.x - 200;
						camFollow.y = bfMidpoint.y - 200;
				}

				if (curSong == 'tutorial')
				{
					var duration:Float = Conductor.stepCrochet * 4 / 1000;
					var cameras = [storyBoardTopFlw, storyBoardFGFlw, storyBoardBGFlw, FlxG.camera];
					for(camera in cameras)
						Tween.tween(camera, {zoom: 1}, duration, {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			storyBoardTopFlw.zoom = FlxMath.lerp(defaultCamZoom, storyBoardTopFlw.zoom, 0.95);
			storyBoardFGFlw.zoom = FlxMath.lerp(defaultCamZoom, storyBoardFGFlw.zoom, 0.95);
			storyBoardBGFlw.zoom = FlxMath.lerp(defaultCamZoom, storyBoardBGFlw.zoom, 0.95);
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		/*if (loadRep) // rep debug
		{
			FlxG.watch.addQuick('rep rpesses',repPresses);
			FlxG.watch.addQuick('rep releases',repReleases);
			// FlxG.watch.addQuick('Queued',inputsQueued);
		}*/

		if (curSong == 'fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48 | 112:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				//case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'bopeebo')
		{
			switch (curBeat)
			{
				case 128 | 129 | 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openPausedSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if (windows && DISCORD)
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- " + visualSongName + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, largeText, iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			//if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes.shift();
				notes.add(dunceNote);
			}
		}

		if (generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					// instead of doing stupid y > FlxG.height
					// we be men and actually calculate the time :)
					if (daNote.tooLate)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}

					if (!daNote.modifiedByLua)
					{
						if (daNote.mustPress)
							daNote.y = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y;
						else
							daNote.y = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y;

						var noteOffsetY = 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(scrollSpeed == 1 ? daNote.noteSpeed : scrollSpeed, 2);

						if (downscroll)
						{
							daNote.y += noteOffsetY;

							if(daNote.isSustainNote)
							{
								// Remember = minus makes notes go up, plus makes them go down
								if(daNote.prevNote != null && daNote.animation.curAnim.name.endsWith('end'))
									daNote.y += daNote.prevNote.height;
								else
									daNote.y += daNote.height / 2;

								// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
								if(!botPlay)
								{
									if((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
									{
										// Clip to strumline
										var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
										swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.y = daNote.frameHeight - swagRect.height;

										daNote.clipRect = swagRect;
									}
								} else {
									var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
									swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
						}
						else
						{
							daNote.y -= noteOffsetY;

							if(daNote.isSustainNote)
							{
								daNote.y -= daNote.height / 2;

								if(!botPlay)
								{
									if((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
									{
										// Clip to strumline
										var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
										swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.height -= swagRect.y;

										daNote.clipRect = swagRect;
									}
								} else {
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;

									daNote.clipRect = swagRect;
								}
							}
						}
					}

					if (!daNote.mustPress && daNote.wasGoodHit)
					{
						if (curSong != 'tutorial')
							camZooming = true;

						var altAnim:String = "";

						var section = SONG.notes[Math.floor(curStep / 16)];
						if (section != null && section.altAnim)
							altAnim = '-alt';

						if (daNote.altAnim)
							altAnim = '-alt';

						switch (Math.abs(daNote.noteData))
						{
							case 0:
								dad.playAnim('singLEFT' + altAnim, true);
							case 1:
								dad.playAnim('singDOWN' + altAnim, true);
							case 2:
								dad.playAnim('singUP' + altAnim, true);
							case 3:
								dad.playAnim('singRIGHT' + altAnim, true);
						}

						#if windows
						if (luaModchart != null)
							luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
						#end

						dad.holdTimer = 0;

						if (SONG.needsVoices)
							vocals.volume = 1;

						daNote.active = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}

					if(!daNote.modifiedByLua) {
						var noteData:Int = Math.floor(Math.abs(daNote.noteData));
						if(daNote.mustPress)
						{
							var playerStrum = playerStrums.members[noteData];

							daNote.visible = playerStrum.visible;
							daNote.x = playerStrum.x;
							if (!daNote.isSustainNote)
								daNote.angle = playerStrum.angle;
							daNote.alpha = playerStrum.alpha;
						}
						else if(!daNote.wasGoodHit)
						{
							var strum = strumLineNotes.members[noteData];

							daNote.visible = strum.visible;
							daNote.x = strum.x;
							if (!daNote.isSustainNote)
								daNote.angle = strum.angle;
							daNote.alpha = strum.alpha;
						}
					}

					if (daNote.isSustainNote)
						daNote.x += daNote.width / 2 + 17;

					//trace(daNote.y);
					// WIP interpolation shit? Need to fix the pause issue
					// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * noteSpeed));

					if (daNote.mustPress && daNote.tooLate)
					{
						if (daNote.isSustainNote && daNote.wasGoodHit)
						{
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
						else
						{
							health -= 0.075;
							vocals.volume = 0;
							/*if (theFunne) */noteMiss(daNote.noteData, daNote);
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}


		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.TWO)
			trace("Beat: " + curBeat);

		if (FlxG.keys.justPressed.ONE)
			endSong();

		if (FlxG.keys.justPressed.THREE)
			shouldEndSong();
		#end

		if(hasStoryBoard && storyBoard.timing == SBTiming.LATE) {
			storyBoardUpdate();
		}
	}

	function destroyStuff() {
		#if windows
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end
		Tween.active = false;
		Tween.forEach(tween -> tween.destroy());
	}

	function shouldEndSong() {
		if(hasStoryBoard && storyBoard.sectionActions.exists(SBSection.ENDING_CUTSCENE))
		{
			inCutscene = true;
			inOutroCutscene = true;

			FlxG.sound.music.volume = 0;
			vocals.volume = 0;

			outroStartTime = Std.int(Conductor.songPosition);
			storyBoard.currentSection = SBSection.ENDING_CUTSCENE;
			storyBoard.timeUnit = SBTimeUnit.MS;
		} else {
			endSong();
		}
	}

	function endSong():Void
	{
		if (!loadRep)
			rep.SaveReplay();

		destroyStuff();

		hasEnded = true;
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		#if !switch
		if (SONG.validScore)
		{
			Highscore.saveScore(currentMod, songName, Math.round(songScore), storyDifficulty);
		}
		#end

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);

				storyVisNamePlaylist.shift();
				storyPlaylist.shift();

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					FlxG.switchState(new StoryMenuState());

					// if ()
					// Doesn't work since it resets the array
					StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

					if (SONG.validScore)
					{
						#if ng
						NGio.unlockMedal(60961);
						#end
						Highscore.saveWeekScore(currentMod, storyWeek, campaignScore, storyDifficulty);
					}

					// FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
					// FlxG.save.flush();
				}
				else
				{
					// Refactor to use Song.getSongFilename
					var difficulty:String = "";

					if (storyDifficulty == 0)
						difficulty = '-easy';

					if (storyDifficulty == 2)
						difficulty = '-hard';

					var songFilename = PlayState.storyPlaylist[0].toLowerCase();

					trace('LOADING NEXT SONG');
					trace(songFilename + difficulty + " - Visual Name: " + PlayState.storyVisNamePlaylist[0]);

					if (curSong == 'eggnog')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					// PlayState. is unneeded
					PlayState.visualSongName = PlayState.storyVisNamePlaylist[0];
					PlayState.SONG = Song.loadFromJson(songFilename + difficulty, PlayState.storyPlaylist[0]);
					PlayState.songName = songFilename;
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				FlxG.switchState(new FreeplayState());
			}
		}
	}

	// var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];

		var score:Float = 350;

		if (accuracyMod == 1) {
			var wife:Float = EtternaFunctions.wife3(noteDiff, Conductor.timeScale);

			totalNotesHit += wife;
		}

		var daRating = daNote.rating;

		switch(daRating)
		{
			case 'shit':
				score = -300;
				combo = 0;
				misses++;
				health -= 0.2;
				//ss = false;
				shits++;
				if (accuracyMod == 0)
					totalNotesHit += 0.25;
			case 'bad':
				score = 0;
				health -= 0.06;
				//ss = false;
				bads++;
				if (accuracyMod == 0)
					totalNotesHit += 0.50;
			case 'good':
				score = 200;
				//ss = false;
				goods++;
				if (health < 2)
					health += 0.04;
				if (accuracyMod == 0)
					totalNotesHit += 0.75;
			case 'sick':
				sicks++;
				if (health < 2)
					health += 0.1;
				if (accuracyMod == 0)
					totalNotesHit += 1;
		}

		// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

		if (daRating != 'shit' || daRating != 'bad')
		{
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));

			var pixelShitPart1:String = "";
			var pixelShitPart2:String = "";

			var isSchoolStage:Bool = curStage.startsWith('school');

			if (isSchoolStage)
			{
				pixelShitPart1 = 'pixelUI/';
				pixelShitPart2 = '-pixel';
			}

			var rating:FlxSprite = new FlxSprite();
			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));

			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			else
			{
				rating.screenCenter(Y);
				rating.y -= 50;
				rating.x = coolText.x - 125;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var msTiming = truncateFloat(noteDiff, 3);

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0, 0, 0, "0ms");
			timeShown = 0;
			switch(daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				//Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for(i in hits)
					total += i;

				offsetTest = truncateFloat(total / hits.length, 2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			add(currentTimingShown);

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			//comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			//currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			add(rating);

			if (isSchoolStage)
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = true;
			}

			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();

			currentTimingShown.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (combo + "").split('');

			if (comboSplit.length == 2)
				seperatedScore.push(0); // make sure theres a 0 in front or it looks weird lol!

			for(i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				//numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				if (isSchoolStage)
				{
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				}
				else
				{
					numScore.antialiasing = true;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				if (combo >= 10 || combo == 0)
					add(numScore);

				Tween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});

				daLoop++;
			}

			coolText.text = Std.string(seperatedScore);
			// add(coolText);

			Tween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			Tween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});

			curSection += 1;
		}
	}

	public function nearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		if (loadRep) // replay code
		{
			// disable input
			up = false;
			down = false;
			right = false;
			left = false;

			// new input


			//if (rep.replay.keys[repPresses].time == Conductor.songPosition)
			//	trace('DO IT!!!!!');

			//timeCurrently = Math.abs(rep.replay.keyPresses[repPresses].time - Conductor.songPosition);
			//timeCurrentlyR = Math.abs(rep.replay.keyReleases[repReleases].time - Conductor.songPosition);


			if (repPresses < rep.replay.keyPresses.length && repReleases < rep.replay.keyReleases.length)
			{
				upP = rep.replay.keyPresses[repPresses].time + 1 <= Conductor.songPosition && rep.replay.keyPresses[repPresses].key == "up";
				rightP = rep.replay.keyPresses[repPresses].time + 1 <= Conductor.songPosition && rep.replay.keyPresses[repPresses].key == "right";
				downP = rep.replay.keyPresses[repPresses].time + 1 <= Conductor.songPosition && rep.replay.keyPresses[repPresses].key == "down";
				leftP = rep.replay.keyPresses[repPresses].time + 1 <= Conductor.songPosition && rep.replay.keyPresses[repPresses].key == "left";

				upR = rep.replay.keyPresses[repReleases].time - 1 <= Conductor.songPosition && rep.replay.keyReleases[repReleases].key == "up";
				rightR = rep.replay.keyPresses[repReleases].time - 1 <= Conductor.songPosition && rep.replay.keyReleases[repReleases].key == "right";
				downR = rep.replay.keyPresses[repReleases].time - 1 <= Conductor.songPosition && rep.replay.keyReleases[repReleases].key == "down";
				leftR = rep.replay.keyPresses[repReleases].time - 1 <= Conductor.songPosition && rep.replay.keyReleases[repReleases].key == "left";

				upHold = upP ? true : upR ? false : true;
				rightHold = rightP ? true : rightR ? false : true;
				downHold = downP ? true : downR ? false : true;
				leftHold = leftP ? true : leftR ? false : true;
			}
		}
		else // record replay code
		{
			if (upP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "up"});
			if (rightP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "right"});
			if (downP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "down"});
			if (leftP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "left"});

			if (upR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "up"});
			if (rightR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "right"});
			if (downR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "down"});
			if (leftR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "left"});
		}
		var pressedKeys:Array<Bool> = [leftP, downP, upP, rightP];
		var releasedKeys:Array<Bool> = [leftR, downR, upR, rightR];

		// FlxG.watch.addQuick('asdfa', upP);
		if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
		{
				repPresses++;
				boyfriend.holdTimer = 0;

				var possibleNotes:Array<Note> = [];

				var ignoreList:Array<Int> = [];

				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
					{
						// the sorting probably doesn't need to be in here? who cares lol
						possibleNotes.push(daNote);

						ignoreList.push(daNote.noteData);
					}
				});


				if (possibleNotes.length > 0)
				{
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
					var daNote = possibleNotes[0];

					// Jump notes
					if (possibleNotes.length >= 2)
					{
						if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
						{
							for (coolNote in possibleNotes)
							{
								if (pressedKeys[coolNote.noteData])
									goodNoteHit(coolNote);
								else
								{
									var inIgnoreList:Bool = false;
									for (shit in 0...ignoreList.length)
									{
										if (pressedKeys[ignoreList[shit]])
											inIgnoreList = true;
									}
								}
							}
						}
						else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
						{
							if (loadRep)
							{
								var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);

								daNote.rating = Ratings.CalculateRating(noteDiff);

								if (nearlyEquals(daNote.strumTime, rep.replay.keyPresses[repPresses].time, 30))
								{
									goodNoteHit(daNote);
									trace('force note hit');
								}
								else
									noteCheck(pressedKeys, daNote);
							}
							else
								noteCheck(pressedKeys, daNote);
						}
						else
						{
							for (coolNote in possibleNotes)
							{
								if (loadRep)
								{
									if (nearlyEquals(coolNote.strumTime, rep.replay.keyPresses[repPresses].time, 30))
									{
										var noteDiff:Float = Math.abs(coolNote.strumTime - Conductor.songPosition);

										if (noteDiff > Conductor.safeZoneOffset * 0.70 || noteDiff < Conductor.safeZoneOffset * -0.70)
											coolNote.rating = "shit";
										else if (noteDiff > Conductor.safeZoneOffset * 0.50 || noteDiff < Conductor.safeZoneOffset * -0.50)
											coolNote.rating = "bad";
										else if (noteDiff > Conductor.safeZoneOffset * 0.45 || noteDiff < Conductor.safeZoneOffset * -0.45)
											coolNote.rating = "good";
										else if (noteDiff < Conductor.safeZoneOffset * 0.44 && noteDiff > Conductor.safeZoneOffset * -0.44)
											coolNote.rating = "sick";
										goodNoteHit(coolNote);
										trace('force note hit');
									}
									else
										noteCheck(pressedKeys, daNote);
								}
								else
									noteCheck(pressedKeys, coolNote);
							}
						}
					}
					else // regular notes?
					{
						if (loadRep)
						{
							if (nearlyEquals(daNote.strumTime, rep.replay.keyPresses[repPresses].time, 30))
							{
								var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);

								daNote.rating = Ratings.CalculateRating(noteDiff);

								goodNoteHit(daNote);
								trace('force note hit');
							}
							else
								noteCheck(pressedKeys, daNote);
						}
						else
							noteCheck(pressedKeys, daNote);
					}
					/*
						if (pressedKeys[daNote.noteData])
							goodNoteHit(daNote);
					 */
					// trace(daNote.noteData);
					/*
						switch (daNote.noteData)
						{
							case 2: // NOTES YOU JUST PRESSED
								if (upP || rightP || downP || leftP)
									noteCheck(upP, daNote);
							case 3:
								if (upP || rightP || downP || leftP)
									noteCheck(rightP, daNote);
							case 1:
								if (upP || rightP || downP || leftP)
									noteCheck(downP, daNote);
							case 0:
								if (upP || rightP || downP || leftP)
									noteCheck(leftP, daNote);
						}
					 */
					if (daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}
		}

		if ((up || right || down || left) && generatedMusic || (upHold || downHold || leftHold || rightHold) && loadRep && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case 0:
							if (left || leftHold)
								goodNoteHit(daNote);
						case 1:
							if (down || downHold)
								goodNoteHit(daNote);
						case 2:
							if (up || upHold)
								goodNoteHit(daNote);
						case 3:
							if (right || rightHold)
								goodNoteHit(daNote);
					}
				}
			});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.playAnim('idle');
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if(pressedKeys[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.animation.play('pressed');

			if(releasedKeys[spr.ID])
			{
				spr.animation.play('static');
				repReleases++;
			}

			spr.centerOffsets();

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
		});
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;
			misses++;

			if (accuracyMod == 1) {
				var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
				var wife:Float = EtternaFunctions.wife3(noteDiff, etternaTS);

				totalNotesHit += wife;
			}

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}

			#if windows
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end

			updateAccuracy();
		}
	}

	/*function badNoteCheck()
		{
			// just double pasting this shit cuz fuk u
			// REDO THIS SYSTEM!
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;

			if (leftP)
				noteMiss(0);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
			if (downP)
				noteMiss(1);
			updateAccuracy();
		}
	*/
	function updateAccuracy()
	{
		totalPlayed++;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		//accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
	}

	function getKeyPresses(note:Note):Int
	{
		var count = 0;

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
				count++;
		});

		if (count == 1)
			return count + 1;
		return count;
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;

	// var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

		if (noteDiff > Conductor.safeZoneOffset * 0.70 || noteDiff < Conductor.safeZoneOffset * -0.70)
			note.rating = "shit";
		else if (noteDiff > Conductor.safeZoneOffset * 0.50 || noteDiff < Conductor.safeZoneOffset * -0.50)
			note.rating = "bad";
		else if (noteDiff > Conductor.safeZoneOffset * 0.45 || noteDiff < Conductor.safeZoneOffset * -0.45)
			note.rating = "good";
		else if (noteDiff < Conductor.safeZoneOffset * 0.44 && noteDiff > Conductor.safeZoneOffset * -0.44)
			note.rating = "sick";

		if (loadRep)
		{
			if (controlArray[note.noteData])
				goodNoteHit(note);
			else if (rep.replay.keyPresses.length > repPresses)
			{
				if (nearlyEquals(note.strumTime, rep.replay.keyPresses[repPresses].time, 4))
				{
					goodNoteHit(note);
				}
			}
		}
		else if (controlArray[note.noteData])
		{
			for (b in controlArray) {
				if (b)
					mashing++;
			}

			// ANTI MASH CODE FOR THE BOYS

			if (mashing <= getKeyPresses(note) && mashViolations < 2)
			{
				mashViolations++;

				goodNoteHit(note, (mashing <= getKeyPresses(note)));
			}
			else
			{
				// this is bad but fuck you
				// Set notes to idle image
				playerStrums.members[0].animation.play('static');
				playerStrums.members[1].animation.play('static');
				playerStrums.members[2].animation.play('static');
				playerStrums.members[3].animation.play('static');
				health -= 0.2;
				trace('mash ' + mashing);
			}

			if (mashing != 0)
				mashing = 0;
		}
	}

	var nps:Int = 0;

	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.CalculateRating(noteDiff);

		if (!note.isSustainNote)
		{
			//notesHitArray.push(Date.now());
			notesHitArray.unshift(Date.now());
		}

		if (resetMashViolation)
			mashViolations--;

		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note);
				combo += 1;
			}
			else
				totalNotesHit += 1;

			switch (note.noteData)
			{
				case 0:
					boyfriend.playAnim('singLEFT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
			}

			#if windows
			if (luaModchart != null)
				luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
			#end

			if (!loadRep)
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (note.noteData == spr.ID)
					{
						spr.animation.play('confirm', true);
					}
				});

			note.wasGoodHit = true;
			vocals.volume = 1;

			note.kill();
			notes.remove(note, true);
			note.destroy();

			updateAccuracy();
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (!trainFinishing && phillyTrain.x < -2000)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (trainFinishing && phillyTrain.x < -4000)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	var inDialogue:Bool = false;

	override function stepHit()
	{
		super.stepHit();
		if(!(inOutroCutscene || inDialogue)) {
			if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
			{
				resyncVocals();
			}
		}

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}
		#end

		if(hasStoryBoard) {
			if(storyBoard.timeUnit == SBTimeUnit.STEPS) {
				storyBoard.runGameplayStep(curStep);
			}
		}

		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if (windows && DISCORD)
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if(!inOutroCutscene) {
			// Updating Discord Rich Presence (with Time Left)
			DiscordClient.changePresence(detailsText + " " + visualSongName + " (" + storyDifficultyText + ") " + generateRanking(), "Acc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, largeText, iconRPC, true, songLength - Conductor.songPosition);
		}
		#end
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	// var curLight:Int = 0;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curBeat', curBeat);
			luaModchart.executeState('beatHit', [curBeat]);
		}
		#end

		if(hasStoryBoard && storyBoard.timing == SBTiming.EXACT) {
			if(storyBoard.timeUnit == SBTimeUnit.BEATS) {
				storyBoard.runGameplayStep(curBeat);
			}
		}

		var section = SONG.notes[Math.floor(curStep / 16)];

		if (section != null)
		{
			if (section.changeBPM)
			{
				if(Conductor.bpm != section.bpm) {
					Conductor.changeBPM(section.bpm);
					FlxG.log.add('CHANGED BPM! ${section.bpm}');
				}
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			//if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
			//	dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		// wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (camZooming && FlxG.camera.zoom < 1.35 && curSong == 'milf' && curBeat >= 168 && curBeat < 200)
		{
			storyBoardTopFlw.zoom += 0.015;
			storyBoardFGFlw.zoom += 0.015;
			storyBoardBGFlw.zoom += 0.015;
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			storyBoardTopFlw.zoom += 0.015;
			storyBoardFGFlw.zoom += 0.015;
			storyBoardBGFlw.zoom += 0.015;
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if(inOutroCutscene) return;

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.playAnim('idle');
		}

		if (!dad.animation.curAnim.name.startsWith("sing"))
		{
			dad.dance();
		}

		if (curBeat % 8 == 7 && curSong == 'bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					var curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
				}

				if (!trainMoving && curBeat % 8 == 4 && FlxG.random.bool(30) && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
			case "spooky":
				if(FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset) {
					lightningStrikeShit();
				}
		}

		if(hasStoryBoard && storyBoard.timing == SBTiming.LATE) {
			if(storyBoard.timeUnit == SBTimeUnit.BEATS) {
				storyBoard.runGameplayStep(curBeat);
			}
		}
	}

	override function onFocusLost() {
		if(openedSubState != null) {
			openedSubState.onFocusLost();
		}

		super.onFocusLost();
	}

	override function onFocus() {
		if(openedSubState != null) {
			openedSubState.onFocus();
		}

		super.onFocus();
	}

	public function pauseSong() {
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}

		Tween.active = false;

		inCutscene = true;
		inDialogue = true;

		canPause = false;
		paused = true;

		if(hasStoryBoard)
			for(video in storyBoard.videos) video.pause();

		for(camera in FlxG.cameras.list) camera.active = false;
		camHUD.active = true;

		if(startTimer != null && !startTimer.finished)
			startTimer.active = false;
	}

	public function resumeSong() {
		if (FlxG.sound.music != null && !startingSong)
		{
			resyncVocals();
		}

		if(startTimer != null && !startTimer.finished)
			startTimer.active = true;

		inCutscene = false;
		inDialogue = false;

		canPause = true;
		paused = false;

		Tween.active = true;

		if(hasStoryBoard)
			for(video in storyBoard.videos) video.resume();

		for(camera in FlxG.cameras.list) camera.active = true;
	}
}
