package;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxStringUtil;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import haxe.io.Path;
import openfl.display.BitmapData;

using StringTools;

class SBAction {
	public var storyBoard:StoryBoardParser;
	public var time:Int;

	public function runAction() throw "stub!";
}

class SBSprite extends SBAction {
	public var spriteID:String;
	public var layer:String;
	public var origin:String;
	public var filename:String;
	public var x:Float;
	public var y:Float;

	public function new(spriteID:String, layer:String, origin:String, filename:String, x:Float, y:Float) {
		this.spriteID = spriteID;
		this.layer = layer;
		this.origin = origin;
		this.filename = filename;
		this.x = x;
		this.y = y;
	}

	override public function runAction() {
		if(storyBoard.sprites.exists(spriteID)) throw 'Sprite ID "$spriteID" already exists';

		var sprite = new FlxSprite(x, y);
		if(true) {
			sprite.loadGraphic(filename);
		} else {
			// Sparrow Stuff here later
		}

		sprite.antialiasing = false;
		sprite.updateHitbox();

		var w = sprite.width;
		var h = sprite.height;

		var originPoint = StoryBoardParser.getOriginPoint(origin, w, h);

		sprite.origin.set(originPoint.x, originPoint.y);

		sprite.cameras = [StoryBoardParser.getLayer(layer)];

		storyBoard.sprites[spriteID] = sprite;
		PlayState.instance.add(sprite);
	}
}

class SBAnim extends SBAction {
	public var actor:String;
	public var animationName:String;
	public var force:Bool;
	public var reverse:Bool;
	public var frame:Int;

	public function new(actor:String, animationName:String, force:Bool = false, reverse:Bool = false, frame:Int = 0) {
		this.actor = actor;
		this.animationName = animationName;
		this.force = force;
		this.reverse = reverse;
		this.frame = frame;
	}

	override public function runAction() {
		switch(actor)
		{
			case 'boyfriend' | 'bf':
				return PlayState.boyfriend.playAnim(animationName, force, reverse, frame);
			case 'girlfriend' | 'gf':
				return PlayState.gf.playAnim(animationName, force, reverse, frame);
			case 'dad':
				return PlayState.dad.playAnim(animationName, force, reverse, frame);
		}

		var sprite:Dynamic = storyBoard.sprites.get(actor);
		if (sprite == null)
		{
			if (Std.parseInt(actor) == null)
				sprite = Reflect.getProperty(PlayState.instance, actor);
			else
				sprite = PlayState.strumLineNotes.members[Std.parseInt(actor)];
		}

		sprite.animation.play(animationName, force, reverse, frame);
	}
}

class SBMove extends SBAction {
	public var spriteID:String;
	public var x:Float;
	public var y:Float;
	public var relative:Bool;

	public function new(spriteID:String, x:Float, y:Float, relative=false) {
		this.spriteID = spriteID;
		this.x = x;
		this.y = y;
		this.relative = relative;
	}

	override public function runAction() {
		var actor:FlxSprite = storyBoard.getActor(spriteID);
		if(actor != null)
		{
			if(relative)
			{
				x += actor.x;
				y += actor.y;
			}
			actor.x = x;
			actor.y = y;
		}
	}
}

class SBTween extends SBAction {
	public var spriteID:String;
	public var attribute:String;
	public var value:Float;
	public var duration:Float;
	public var tweenType:FlxTweenType;
	public var easeAnim:EaseFunction;
	public var relative:Bool = false;

	public function new(spriteID:String, attribute:String, value:Float, duration:Int, tweenType:FlxTweenType = FlxTweenType.ONESHOT, ?easeAnim:EaseFunction) {
		this.spriteID = spriteID;
		this.attribute = attribute;
		this.value = value;
		this.duration = duration / 1000;
		this.tweenType = tweenType;
		if(easeAnim != null) {
			this.easeAnim = easeAnim;
		} else {
			this.easeAnim = FlxEase.linear;
		}
	}

	override public function runAction() {
		var actor:Dynamic = storyBoard.getActor(spriteID);
		if(actor != null)
		{
			var obj:Dynamic = null;

			switch(attribute)
			{
				case 'scale': obj = {"scale.x": value, "scale.y": value};
				case 'scalex': obj = {"scale.x": value};
				case 'scaley': obj = {"scale.y": value};
				case 'scrollfactor': obj = {"scrollFactor.x": value, "scrollFactor.y": value};
				case 'scrollfactorx': obj = {"scrollFactor.x": value};
				case 'scrollfactory': obj = {"scrollFactor.y": value};
			}

			if(obj == null) {
				obj = {};
				Reflect.setProperty(obj, attribute, value);
			}

			if(relative) {
				for(fieldPath in Reflect.fields(obj)) {
					var target = actor;
					var path = fieldPath.split(".");
					var field = path.pop();
					for (component in path)
					{
						target = Reflect.getProperty(target, component);
						if (!Reflect.isObject(target))
							throw 'The object does not have the property "$component" in "$fieldPath"';
					}

					Reflect.setProperty(obj, fieldPath, Reflect.getProperty(target, field) + value);
				}
			}

			if(storyBoard.attachedTweens[spriteID] == null) {
				storyBoard.attachedTweens[spriteID] = [];
			}

			storyBoard.attachedTweens[spriteID].push(PlayState.instance.Tween.tween(actor, obj, duration, {type: tweenType, ease: easeAnim}));
		}
	}
}

class SBAttrib extends SBAction {
	public var spriteID:String;
	public var attribute:String;
	public var value:Dynamic;
	public var relative:Bool;

	public function new(spriteID:String, attribute:String, value:Dynamic, relative:Bool) {
		this.spriteID = spriteID;
		this.attribute = attribute;
		this.value = value;
		this.relative = relative;
	}

	override public function runAction() {
		var actor:Dynamic = storyBoard.getActor(spriteID);
		if(actor != null) {
			var fields:Array<String> = [attribute];

			switch(attribute) {
				case 'scale': fields = ["scale.y", "scale.x"];
				case 'scalex': fields = ["scale.x"];
				case 'scaley': fields = ["scale.y"];
				case 'scrollfactor': fields = ["scrollFactor.x", "scrollFactor.y"];
				case 'scrollfactorx': fields = ["scrollFactor.x"];
				case 'scrollfactory': fields = ["scrollFactor.y"];
			}

			for (fieldPath in fields)
			{
				var target = actor;
				var path = fieldPath.split(".");
				var field = path.pop();
				for (component in path)
				{
					target = Reflect.getProperty(target, component);
					if (!Reflect.isObject(target))
						throw 'The object does not have the property "$component" in "$fieldPath"';
				}

				var val:Dynamic = value;
				if(relative) {
					val = Reflect.getProperty(target, field) + value;
				}

				Reflect.setProperty(target, field, val);
			}
		}
	}
}

class SBAudio extends SBAction {
	public var filename:String;
	public var volume:Int;

	public function new(filename:String, volume:Int = 100) {
		this.filename = filename;
		this.volume = volume;
	}

	override public function runAction() {
		FlxG.sound.play(filename, volume/100);
	}
}

class SBRemove extends SBAction {
	public var spriteID:String;

	public function new(spriteID:String) {
		this.spriteID = spriteID;
	}

	override public function runAction() {
		var sprite:Dynamic = storyBoard.sprites.get(spriteID);
		if(sprite != null) {
			var tweens = storyBoard.attachedTweens[spriteID];
			if(tweens != null) {
				for(tween in tweens) {
					tween.active = false;
					tween.destroy();
				}
				storyBoard.attachedTweens[spriteID] = null;
			}

			var video:VideoSprite = storyBoard.videos.get(spriteID);
			if(video != null) storyBoard.videos.remove(spriteID);

			PlayState.instance.remove(sprite);
			sprite.destroy();
			sprite = null;
			storyBoard.sprites.remove(spriteID);
		}
	}
}

class SBSetTimeUnit extends SBAction {
	public var timeUnit:SBTimeUnit;

	public function new(timeUnit:SBTimeUnit) {
		this.timeUnit = timeUnit;
	}

	override public function runAction() {
		storyBoard.timeUnit = timeUnit;
	}
}

class SBConfig extends SBAction {
	public var key:String;
	public var value:Dynamic;

	public function new(key:String, value:Dynamic) {
		this.key = key;
		this.value = value;
	}

	override public function runAction() {
		switch(key)
		{
			case "showcountdown":
				PlayState.instance.showIntroCountdown = value;
			case "introlength":
				PlayState.instance.introLength = value;
			case "showonlystrums":
				PlayState.instance.showOnlyStrums = value;
				#if windows
				if (PlayState.luaModchart != null)
					PlayState.luaModchart.setVar('showOnlyStrums', value);
				#end
		}
	}
}

class SBPlayVideo extends SBAction {
	public var filename:String;

	public function new(filename:String) {
		this.filename = filename;
	}

	override public function runAction() {
		PlayState.instance.persistentUpdate = false;
		PlayState.instance.persistentDraw = false;
		PlayState.instance.paused = true;

		PlayState.instance.openPausedSubState(new VideoSubState(filename));
	}
}

class SBVideo extends SBAction {
	public inline static var NONE:Int = 0;
	public inline static var REMOVE:Int = 1;

	public var spriteID:String;
	public var layer:String;
	public var origin:String;
	public var filename:String;
	public var x:Float;
	public var y:Float;
	public var endAction:Int;

	public function new(spriteID:String, layer:String, origin:String, filename:String, x:Float, y:Float, ?endAction:Int = 0) {
		this.spriteID = spriteID;
		this.layer = layer;
		this.origin = origin;
		this.filename = filename;
		this.x = x;
		this.y = y;
		this.endAction = endAction;
	}

	override public function runAction() {
		if(storyBoard.sprites.exists(spriteID)) throw 'Sprite ID "$spriteID" already exists';

		var vidSprite = new VideoSprite(x, y, filename);
		vidSprite.endAction = endAction;
		vidSprite.storyBoard = storyBoard;
		vidSprite.spriteId = spriteID;

		//vidSprite.antialiasing = false;
		//vidSprite.updateHitbox();

		#if web
		throw "Video Sprites are unsupported on web";
		#else
		var bitmap:BitmapData = vidSprite.handler.webm.bitmapData;
		#end

		var w = bitmap.width;
		var h = bitmap.height;

		var originPoint = StoryBoardParser.getOriginPoint(origin, w, h);

		vidSprite.origin.set(originPoint.x, originPoint.y);

		vidSprite.cameras = [StoryBoardParser.getLayer(layer)];

		storyBoard.sprites[spriteID] = vidSprite;
		storyBoard.videos[spriteID] = vidSprite;
		PlayState.instance.add(vidSprite);
	}
}

class SBText extends SBAction {
	public var spriteID:String;
	public var layer:String;
	public var origin:String;
	public var text:String;
	public var x:Float;
	public var y:Float;
	public var fontSize:Int;

	public function new(spriteID:String, layer:String, origin:String, text:String, x:Float, y:Float, fontSize:Int = 8) {
		this.spriteID = spriteID;
		this.layer = layer;
		this.origin = origin;
		this.text = text;
		this.x = x;
		this.y = y;
		this.fontSize = fontSize;
	}

	override public function runAction() {
		if(storyBoard.sprites.exists(spriteID)) throw 'Sprite ID "$spriteID" already exists';

		var text = new FlxText(x, y, 0, text);
		text.setFormat(Paths.font("vcr.ttf"), fontSize);
		text.borderStyle = FlxTextBorderStyle.OUTLINE;

		var w = text.width;
		var h = text.height;

		var originPoint = StoryBoardParser.getOriginPoint(origin, w, h);

		text.origin.set(originPoint.x, originPoint.y);

		text.cameras = [StoryBoardParser.getLayer(layer)];

		storyBoard.sprites[spriteID] = text;
		PlayState.instance.add(text);
	}
}

enum SBSection {
	STARTING_CUTSCENE;
	GAMEPLAY;
	ENDING_CUTSCENE;
}

enum SBTimeUnit {
	MS;
	BEATS;
	STEPS;
}

class StoryBoardParser
{
	public static var instance:StoryBoardParser = null;

	private var parsingSection:SBSection = null;
	public var currentSection:SBSection = null;
	public var version:String = "";
	public var timeUnit:SBTimeUnit = SBTimeUnit.MS;

	public var sectionActions = new Map<SBSection, Array<SBAction>>();

	public var videos = new Map<String, VideoSprite>();
	public var sprites = new Map<String, Dynamic>();
	public var attachedTweens = new Map<String, Array<FlxTween>>();

	public function new(createBare:Bool = false)
	{
		instance = this;

		if(createBare) return;

		var filename = Paths.storyBoardWeekPath(PlayState.SONG.song.toLowerCase() + "/storyboard");

		var storyboardData = CoolUtil.coolTextFile(filename);

		var parseActions:Array<SBAction> = [];

		var rowNum = 0;

		for(row in storyboardData)
		{
			rowNum++;
			if(row.startsWith(";")) {
				continue;
			}

			if(row.startsWith("KMTStoryBoard "))
			{
				version = row.substr(14);
				trace("StoryBoard Version " + version);
			}
			else if(row.startsWith("--SECTION-"))
			{
				var type = row.substr(10);
				if(!type.endsWith("--")) throw 'Invalid Storyboard File - Found start of section tag but it is missing "--" at line $rowNum';

				type = type.substr(0, type.length - 2);

				parsingSection = switch(type.toLowerCase()) {
					case 'startingcutscene' | 'intro': SBSection.STARTING_CUTSCENE;
					case 'gameplay': SBSection.GAMEPLAY;
					case 'endingcutscene' | 'outro': SBSection.ENDING_CUTSCENE;
					default: throw 'Invalid Storyboard File - No Section named "$type" at line $rowNum';
				}
			}
			else if(parsingSection == SBSection.STARTING_CUTSCENE && row.toLowerCase().startsWith("introlength "))
			{
				PlayState.instance.introLength = Std.parseInt(row.substr(12));
			}
			else if(parsingSection != null)
			{
				var data = ~/,(?=(?:[^"]*"[^"]*")*[^"]*$)/gm.split(row); // row.split(",") but it doesn't split in quotes
				var time = Std.parseInt(data[0]);
				var actionClass = makeAction(data, rowNum);

				if(actionClass != null) {
					actionClass.time = time;
					parseActions.push(actionClass);
				}
			}
			if(row == "--END-SECTION--")
			{
				if(parsingSection == null) throw 'Unexpected End Section at line $rowNum';

				for (action in parseActions)
					action.storyBoard = this;

				sectionActions.set(parsingSection, parseActions);
				parseActions = [];
				parsingSection = null;
			}
		}
	}

	public static function makeAction(data:Array<String>, rowNum:Int=-1) {
		var action = data[1];
		var actionClass:SBAction = null;
		if(action == "SetTimeUnit")
		{
			var timeString = data[2];
			var timeUnit = switch(timeString.toLowerCase()) {
				case 'ms': SBTimeUnit.MS;
				case 'beats': SBTimeUnit.BEATS;
				case 'steps': SBTimeUnit.STEPS;
				default: throw 'Invalid Storyboard File - Time Unit "$timeString" is invalid at line $rowNum';
			}

			actionClass = new SBSetTimeUnit(timeUnit);
		}
		else if(action == "PlayAnim")
		{
			var actor = data[2];
			var animationName = data[3];
			var force = data.length > 4 ? data[4] == "1" : false;
			var reverse = data.length > 5 ? data[5] == "1" : false;
			var frame = data.length > 6 ? Std.parseInt(data[6]) : 0;

			if(frame == null) {
				trace("Invalid Frame value, defaulting to 0");
				frame = 0;
			}

			actionClass = new SBAnim(actor, animationName, force, reverse, frame);
		}
		else if(action == "Move" || action == "MoveRel")
		{
			var actor = data[2];
			var x = Std.parseFloat(data[3]);
			var y = Std.parseFloat(data[4]);
			var isRelative = action == "MoveRel";

			actionClass = new SBMove(actor, x, y, isRelative);
		}
		else if(action == "Sprite")
		{
			var spriteID = data[2];
			var layer = data[3];
			var origin = data[4].toLowerCase().replace("centre", "center");
			var filename = StoryBoardParser.convertSpecialPath(data[5]);
			var x = Std.parseFloat(data[6]);
			var y = Std.parseFloat(data[7]);

			actionClass = new SBSprite(spriteID, layer, origin, filename, x, y);
		}
		else if(action == "Remove")
		{
			var spriteID = data[2];

			actionClass = new SBRemove(spriteID);
		}
		else if(action == "Tween" || action == "TweenRel")
		{
			var spriteID = data[2];
			var attribute = data[3];
			var value = Std.parseFloat(data[4]);
			var endTime = Std.parseInt(data[5]);
			var tweenType = data.length > 6 ? convertToTweenType(data[6]) : FlxTweenType.ONESHOT;
			var easeAnim = data.length > 7 ? convertToEase(data[7]) : null;
			var isRelative = action == "TweenRel";

			var _actionClass = new SBTween(spriteID, attribute, value, endTime, tweenType, easeAnim);
			_actionClass.relative = isRelative;
			actionClass = _actionClass;
		}
		else if(action == "Audio")
		{
			var filename = StoryBoardParser.convertSpecialPath(data[2]);
			var volume = data.length > 3 ? Std.parseInt(data[3]) : 100;

			actionClass = new SBAudio(filename, volume);
		}
		else if(action.startsWith("Attrib"))
		{
			var spriteID = data[2];
			var attribute = data[3];
			var isRelative = action.startsWith("AttribRel");
			if(isRelative) action = action.replace("AttribRel", "Attrib");

			var value:Dynamic = null;
			switch(action)
			{
				case "Attrib" | "AttribString": value = data[4];
				case "AttribFloat": value = Std.parseFloat(data[4]);
				case "AttribInt": value = Std.parseInt(data[4]);
				case "AttribBool": value = data[4] == "1";
				case "AttribNull": value = null;
				default: throw 'Invalid Attrib Type at line $rowNum';
			}

			actionClass = new SBAttrib(spriteID, attribute, value, isRelative);
		}
		else if(action.startsWith("Config"))
		{
			var key = data[2].toLowerCase();
			var value:Dynamic = null;
			switch(action)
			{
				case "Config" | "ConfigString": value = data[3];
				case "ConfigFloat": value = Std.parseFloat(data[3]);
				case "ConfigInt": value = Std.parseInt(data[3]);
				case "ConfigBool": value = data[3] == "1";
				case "ConfigNull": value = null;
				default: throw 'Invalid Config Type at line $rowNum';
			}

			actionClass = new SBConfig(key, value);
		}
		else if(action == "PlayVideo")
		{
			var filename = StoryBoardParser.convertSpecialPath(data[2], false);

			if(!filename.endsWith(".webm")) throw 'Invalid file format - Use "webm" at line $rowNum';

			actionClass = new SBPlayVideo(filename);
		}
		else if(action == "Video")
		{
			var spriteID = data[2];
			var layer = data[3];
			var origin = data[4].toLowerCase().replace("centre", "center");
			var filename = StoryBoardParser.convertSpecialPath(data[5], false);
			var x = Std.parseFloat(data[6]);
			var y = Std.parseFloat(data[7]);
			var endAction = SBVideo.REMOVE;

			if(data.length > 8) {
				endAction = switch(data[8].toLowerCase()) {
					case 'none' | '0': SBVideo.NONE;
					case 'remove' | '1': SBVideo.REMOVE;
					default: SBVideo.REMOVE;
				}
			}

			if(!filename.endsWith(".webm")) throw 'Invalid file format - Use "webm" at line $rowNum';

			actionClass = new SBVideo(spriteID, layer, origin, filename, x, y, endAction);
		}
		else if(action == "Text" || action == "TextRaw")
		{
			var spriteID = data[2];
			var layer = data[3];
			var origin = data[4].toLowerCase().replace("centre", "center");
			var text = data[5];
			var x = Std.parseFloat(data[6]);
			var y = Std.parseFloat(data[7]);
			var fontSize = data.length > 8 ? Std.parseInt(data[8]) : 8;

			if(action == "Text") {
				if(text.startsWith('"')) text = text.substr(1);
				if(text.endsWith('"')) text = text.substr(0, text.length-1);
				if(text.contains("\\n")) {
					text = text.replace("\\n", "\n");
					text += "\n";
				}
			}

			actionClass = new SBText(spriteID, layer, origin, text, x, y, fontSize);
		}

		return actionClass;
	}

	public function runIntroCutsceneStep(time:Int) {
		if(currentSection != SBSection.STARTING_CUTSCENE) return;
		if(timeUnit != SBTimeUnit.MS) throw "Only Milliseconds are allowed for intro cutscene";
		var curActions = sectionActions[currentSection];
		if(curActions == null) return;

		while(curActions.length > 0 && curActions[0].time <= time)
		{
			var action = curActions.shift();

			action.runAction();

			if(Std.is(action, SBSetTimeUnit)) break; // Unsafe if there is a action on that exact time. Will cause it to happen next step
		}
	}

	public function runGameplayStep(time:Int) {
		if(currentSection != SBSection.GAMEPLAY) return;
		var curActions = sectionActions[currentSection];
		if(curActions == null) return;

		while(curActions.length > 0 && curActions[0].time <= time)
		{
			var action = curActions.shift();

			action.runAction();

			if(Std.is(action, SBSetTimeUnit)) break; // Unsafe if there is a action on that exact time. Will cause it to happen next step
		}
	}

	public static function convertSpecialPath(path:String, useLibrary:Bool = true) {
		var realPath = path;
		if(realPath.startsWith('"')) realPath = realPath.substr(1);
		if(realPath.endsWith('"')) realPath = realPath.substr(0, realPath.length-1);

		if(realPath.startsWith("@"))
			realPath = Path.join(['assets', realPath.substr(1)]);
		else if(realPath.startsWith("#"))
			realPath = Path.join(['assets', 'weeks', Paths.currentMod, realPath.substr(1)]);
		else if(realPath.startsWith("$"))
			realPath = Path.join(['assets', 'weeks', Paths.currentMod, Paths.currentWeek, realPath.substr(1)]);
		else if(realPath.startsWith("&"))
			realPath = Path.join(['assets', 'weeks', Paths.currentMod, Paths.currentWeek, 'tracks', Paths.currentSong, realPath.substr(1)]);

		if(useLibrary) {
			if(realPath.startsWith("assets/weeks"))
				return 'weeks:' + realPath;
			else if(realPath.startsWith("assets/shared"))
				return 'shared:' + realPath;
		}

		return realPath;
	}

	public static inline function storyBoardExists() {
		return Paths.storyBoardExists(PlayState.SONG.song.toLowerCase() + "/storyboard");
	}

	public function getActor(spriteID:String):Dynamic {
		if(spriteID.startsWith("___"))
		{
			switch(spriteID.toLowerCase())
			{
				case '___playstate': return PlayState.instance;
				case '___staticplaystate': return PlayState;
			}
		}

		switch(spriteID)
		{
			case 'boyfriend' | 'bf':
				return PlayState.boyfriend;
			case 'girlfriend' | 'gf':
				return PlayState.gf;
			case 'dad':
				return PlayState.dad;
		}

		if (sprites.get(spriteID) == null)
		{
			if (Std.parseInt(spriteID) == null)
				return Reflect.getProperty(PlayState.instance, spriteID);
			else
				return PlayState.strumLineNotes.members[Std.parseInt(spriteID)];
		}

		return sprites.get(spriteID);
	}

	public static function getOriginPoint(origin:String, w:Float, h:Float):FlxPoint {
		return switch(origin)
		{
			case 'topleft': new FlxPoint(0, 0);
			case 'topright': new FlxPoint(w, 0);
			case 'bottomleft': new FlxPoint(0, h);
			case 'bottomright': new FlxPoint(w, h);
			case 'center': new FlxPoint(w*.5, h*.5);
			case 'centerleft': new FlxPoint(0, h*.5);
			case 'centerright': new FlxPoint(w, h*.5);
			case 'topcenter': new FlxPoint(w*.5, 0);
			case 'bottomcenter': new FlxPoint(w*.5, h);
			default: new FlxPoint(0, 0);
		}
	}

	public static function convertToTweenType(data:String) {
		return switch(data.toLowerCase()) {
			case 'per': FlxTweenType.PERSIST;
			case 'loop': FlxTweenType.LOOPING;
			case 'pp': FlxTweenType.PINGPONG;
			case 'os': FlxTweenType.ONESHOT;
			case 'bw': FlxTweenType.BACKWARD;
			default: throw 'Missing Tween Type "$data"';
		}
	}

	public static function getLayer(data:String) {
		return switch(data.toLowerCase()) {
			case 'fg': PlayState.instance.storyBoardFG;
			case 'bg': PlayState.instance.storyBoardBG;
			case 'top': PlayState.instance.storyBoardTop;
			case 'fgflw': PlayState.instance.storyBoardFGFlw;
			case 'bgflw': PlayState.instance.storyBoardBGFlw;
			case 'topflw':PlayState.instance.storyBoardTopFlw;
			case 'game': PlayState.instance.camGame;
			case 'hud': PlayState.instance.camHUD;
			default: throw 'Invalid Layer "$data"';
		}
	}

	public static function convertToEase(data:String) {
		return switch(data.toLowerCase()) {
			case 'linear': FlxEase.linear;
			case 'quadin': FlxEase.quadIn;
			case 'quadout': FlxEase.quadOut;
			case 'quadinout': FlxEase.quadInOut;
			case 'cubein': FlxEase.cubeIn;
			case 'cubeout': FlxEase.cubeOut;
			case 'cubeinout': FlxEase.cubeInOut;
			case 'quartin': FlxEase.quartIn;
			case 'quartout': FlxEase.quartOut;
			case 'quartinout': FlxEase.quartInOut;
			case 'quintin': FlxEase.quintIn;
			case 'quintout': FlxEase.quintOut;
			case 'quintinout': FlxEase.quintInOut;
			case 'smoothstepin': FlxEase.smoothStepIn;
			case 'smoothstepout': FlxEase.smoothStepOut;
			case 'smoothstepinout': FlxEase.smoothStepInOut;
			case 'smootherstepin': FlxEase.smootherStepIn;
			case 'smootherstepout': FlxEase.smootherStepOut;
			case 'smootherstepinout': FlxEase.smootherStepInOut;
			case 'sinein': FlxEase.sineIn;
			case 'sineout': FlxEase.sineOut;
			case 'sineinout': FlxEase.sineInOut;
			case 'bouncein': FlxEase.bounceIn;
			case 'bounceout': FlxEase.bounceOut;
			case 'bounceinout': FlxEase.bounceInOut;
			case 'circin': FlxEase.circIn;
			case 'circout': FlxEase.circOut;
			case 'circinout': FlxEase.circInOut;
			case 'expoin': FlxEase.expoIn;
			case 'expoout': FlxEase.expoOut;
			case 'expoinout': FlxEase.expoInOut;
			case 'backin': FlxEase.backIn;
			case 'backout': FlxEase.backOut;
			case 'backinout': FlxEase.backInOut;
			case 'elasticin': FlxEase.elasticIn;
			case 'elasticout': FlxEase.elasticOut;
			case 'elasticinout': FlxEase.elasticInOut;
			default: throw 'Invalid ease type "$data"';
		}
	}
}
