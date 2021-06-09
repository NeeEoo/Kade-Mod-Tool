package;

import flixel.FlxBasic;
import flixel.FlxState;
import flixel.FlxG;

import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.system.FlxSound;
import openfl.utils.Assets;
import openfl.utils.AssetType;

import openfl.Lib;

using StringTools;

class VideoSubState extends MusicBeatSubstate
{
	public var leAsset:String = "";
	public var txt:FlxText;
	public var fuckingVolume:Float = 1;
	public var notDone:Bool = true;
	public var vidSound:FlxSound;
	public var useSound:Bool = false;
	public var soundMultiplier:Float = 1;
	public var prevSoundMultiplier:Float = 1;
	public var videoFrames:Int = 0;
	public var defaultText:String = #if web "You Are Using HTML5!\nTap Anything..." #else "The Video Didnt Load!" #end;
	private var doShit:Bool = false;
	private var pauseText:String = "Press P To Pause/Unpause";
	private var lostFocusPause:Bool = false;

	public function new(source:String, frameSkipLimit:Int = -1)
	{
		super();

		#if !web
		if (frameSkipLimit != -1)
			GlobalVideo.get().webm.SKIP_STEP_LIMIT = frameSkipLimit;
		#end

		doShit = false;

		var leAsset:String = source;
		
		if(leAsset.startsWith("assets/weeks"))
			leAsset = "weeks:" + leAsset;

		fuckingVolume = FlxG.sound.music.volume;
		FlxG.sound.music.volume = 0;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		txt = new FlxText(0, 0, FlxG.width, defaultText);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		//add(txt);

		#if !web
		var songPath:String = leAsset.replace(".webm", ".ogg");
		if (Assets.exists(songPath, MUSIC) || Assets.exists(songPath, SOUND))
		{
			var videoFrameFile = leAsset.replace(".webm", ".txt");
			if(!Assets.exists(videoFrameFile, TEXT)) {
				throw "Missing Video Frame Text File";
			}
			videoFrames = Std.parseInt(Assets.getText(videoFrameFile));

			useSound = true;
			vidSound = FlxG.sound.play(songPath);
		}
		#end

		var handler = GlobalVideo.get();

		handler.source(source);
		handler.clearPause();
		#if !web
		handler.updatePlayer();
		#end

		handler.show();

		handler.restarted = false;
		handler.played = false;
		handler.stopped = false;
		handler.ended = false;

		#if web
		handler.play();
		#else
		handler.restart();
		#end

		if (useSound)
		{
			//vidSound = FlxG.sound.play(source.replace(".webm", ".ogg"));

			/*new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{*/
				vidSound.time = vidSound.length * soundMultiplier;
				/*new FlxTimer().start(1.2, function(tmr:FlxTimer)
				{
					if (useSound)
					{
						vidSound.time = vidSound.length * soundMultiplier;
					}
				}, 0);*/
				doShit = true;
			//}, 1);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var handler = GlobalVideo.get();

		#if !web
		if (useSound)
		{
			@:privateAccess var wasFuckingHit = handler.webm.wasHitOnce;
			@:privateAccess soundMultiplier = handler.webm.renderedCount / videoFrames;

			if (soundMultiplier > 1)
				soundMultiplier = 1;

			if (soundMultiplier < 0)
				soundMultiplier = 0;

			if (doShit)
			{
				var compareShit:Float = 50;
				if (vidSound.time >= (vidSound.length * soundMultiplier) + compareShit || vidSound.time <= (vidSound.length * soundMultiplier) - compareShit)
					vidSound.time = vidSound.length * soundMultiplier;
			}
			if (wasFuckingHit)
			{
				if (soundMultiplier == 0) {
					if (prevSoundMultiplier != 0)
					{
						vidSound.pause();
						vidSound.time = 0;
					}
				} else {
					if (prevSoundMultiplier == 0)
					{
						vidSound.resume();
						vidSound.time = vidSound.length * soundMultiplier;
					}
				}
				prevSoundMultiplier = soundMultiplier;
			}
		}
		#end

		if (notDone)
		{
			FlxG.sound.music.volume = 0;
		}
		handler.update(elapsed);

		if (controls.RESET)
		{
			handler.restart();
		}

		if (FlxG.keys.justPressed.P)
		{
			txt.text = pauseText;
			trace("PRESSED PAUSE");
			handler.togglePause();
			if (handler.paused) {
				handler.alpha();
			} else {
				handler.unalpha();
				txt.text = defaultText;
			}
			txt.screenCenter();
		}

		if (handler.ended || handler.stopped)
		{
			txt.visible = false;
			if (handler.paused) {
				handler.togglePause();
				handler.unalpha();
				txt.text = defaultText;
			}

			handler.hide();
			handler.stop();
		}

		if (handler.ended)
		{
			notDone = false;
			FlxG.sound.music.volume = fuckingVolume;
			txt.visible = false;
			vidSound.destroy();
			PlayState.instance.closePausedSubState();
			trace("STOPPED");
		}

		if (handler.played || handler.restarted)
			handler.show();

		handler.restarted = false;
		handler.played = false;
		handler.stopped = false;
		handler.ended = false;
	}

	override function onFocusLost() {
		var handler = GlobalVideo.get();

		if (!handler.paused) {
			txt.text = pauseText;
			handler.pause();
			lostFocusPause = true;
		}

		super.onFocusLost();
	}

	override function onFocus() {
		var handler = GlobalVideo.get();

		if (lostFocusPause && handler.paused) {
			lostFocusPause = false;
			handler.togglePause();
			txt.text = defaultText;
			txt.screenCenter();
		}

		super.onFocus();
	}
}
