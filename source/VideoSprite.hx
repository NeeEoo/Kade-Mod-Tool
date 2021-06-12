package;

import StoryBoardParser.SBRemove;
import flixel.graphics.FlxGraphic;
import GlobalVideo.Handler;
import flixel.FlxSprite;

using StringTools;

class VideoSprite extends FlxSprite
{
	private static var videoId = 0;
	private var lostFocusPause:Bool = false;
	public var handler:Handler = null;
	public var endAction:Int = 0;
	public var spriteId:String = "";
	public var storyBoard:StoryBoardParser = null;

	public function new(x:Float, y:Float, source:String)
	{
		super(x, y);

		#if web
		var str1:String = "HTML CRAP-" + videoId;
		handler = new VideoHandler();
		handler.isSprite = true;
		handler.init1();
		handler.video.name = str1;
		handler.init2();
		handler.source(source);
		#elseif desktop
		var str1:String = "WEBM SHIT-" + videoId;
		handler = new WebmHandler();
		handler.isSprite = true;
		handler.source(source);
		handler.makePlayer();
		handler.webm.name = str1;
		#end

		handler.clearPause();
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

		videoId++;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		handler.update(elapsed);

		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(handler.webm.bitmapData);

		if(graphic.bitmap != null) {
			frames = graphic.imageFrame;
		} else {
			active = false;
		}

		if (handler.ended || handler.stopped)
		{
			if(endAction == 1) { // Remove
				var action = new SBRemove(spriteId);
				action.storyBoard = storyBoard;
				action.runAction();
			} else {
				handler.hide();
				handler.stop();
			}
		}

		if (handler.played || handler.restarted)
			handler.show();

		handler.restarted = false;
		handler.played = false;
		handler.stopped = false;
		handler.ended = false;
	}

	public function pause() {
		if (!handler.paused) handler.pause();
	}

	public function resume() {
		if (handler.paused) handler.togglePause();
	}
}
