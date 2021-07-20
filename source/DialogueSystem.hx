package;

import openfl.Assets;
import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueSystem extends FlxSpriteGroup
{
	public var box:FlxSprite;

	public var swagDialogue:FlxTypeText;
	public var swagDialogueColor:Int = 0xFF3F2021;
	public var swagDialogueSounds:Array<FlxSound>;

	// Dropshadow
	public var dropText:FlxText;
	public var dropTextColor:Int = 0xFFD89494;
	public var dropTextVisible:Bool = true;

	public var background:FlxSprite;

	public var finishThing:Void->Void;

	public var pixelTextFX:FlxSound;

	public var playingMusic:Array<FlxSound>;

	public var portraits = new Map<String, FlxSprite>();
	public var cachedPortraits = new Map<String, FlxSprite>();
	public var offsets = new Map<String, Array<Float>>();
	var portraitsToAdd:Array<String> = [];

	public var bgFade:FlxSprite;
	public var handSelect:FlxSprite;

	public var textDelay:Float = 0.04;
	public var doClickFX:Bool = true;
	public var isPixel:Bool = false;
	public var boxScale:Float = 0.9;

	public var allowKeyPresses:Bool = true;

	public var dialogueTimer:FlxTimer;
	public var dialogueTime:Float = 1;

	public var defaultFont:String = "";
	public var fontSize:Int = 32;
	public var defaultPortraitColor:Int = FlxColor.WHITE;

	public var clickFX:String = 'clickText';

	public var changedBox:Bool = false;
	public var shouldFlipBox:Bool = true;
	public var isFlipped:Bool = false;

	public var curVoice:FlxSound;
	public var isFadingMusic:Bool = false;
	public var fadeOutMusicDuration:Float = 2.2;

	public function new(?dialogueList:Array<String>, ?parsedList:Array<DialogueEvent>, ?cachedPortraits:Map<String, FlxSprite>)
	{
		super();

		if(cachedPortraits != null) {
			this.cachedPortraits = cachedPortraits;
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if(bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		box = new FlxSprite(-20, 45);

		background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		background.antialiasing = true;
		background.visible = false;
		add(background);

		var song = PlayState.songName;
		var hasDialog = false;
		switch(song)
		{
			case 'senpai':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('dialogue/dialogueBox-pixel');
			case 'roses':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('dialogue/dialogueBox-senpaiMad');
			case 'thorns':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('dialogue/dialogueBox-evil');
		}

		if(parsedList != null) {
			dialogueEvents = parsedList;
		} else {
			dialogueEvents = parseDialog(dialogueList);
		}

		for(item in dialogueEvents) {
			item.system = this;

			if(Std.isOfType(item, Dialogue)) {
				var item = cast (item, Dialogue);
				if(!portraitsToAdd.contains(item.character)) {
					portraitsToAdd.push(item.character);
				}
			}
		}

		if (!hasDialog) {
			if(parsedList == null && dialogueList.length == 0) return;

			box.frames = Paths.getSparrowAtlas('dialogue/speech_bubble_talking');
		}

		if(!changedBox) {
			box.animation.addByPrefix('appear', 'appear', 24, false);
			box.animation.addByPrefix('normal', 'normal', 24, true);
		}

		pixelTextFX = FlxG.sound.load(Paths.sound('pixelText'), 0.6);
		swagDialogueSounds = [pixelTextFX];

		defaultFont = Assets.getFont(Paths.fontLib("pixel.otf")).fontName;
		dialogueTimer = new FlxTimer().start(dialogueTime);

		progressDialogue(false);

		if(isPixel) {
			boxScale = PlayState.daPixelZoom * 0.9;
		} else {
			box.antialiasing = true;
			box.y = FlxG.height - 45;
		}

		box.setGraphicSize(Std.int(box.width * boxScale));
		if(box.animation.curAnim == null) {
			box.animation.play('appear');
		}
		box.y += box.offset.y;
		var xOffset = box.offset.x;
		box.updateHitbox();
		box.screenCenter(X);
		box.x += xOffset;

		if(!isPixel) {
			box.y -= box.height;
			box.y += 20;
			box.x += 40;
		}

		for(character in portraitsToAdd) {
			addPortrait(character);
		}

		add(box);

		if(isPixel) {
			handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('pixelUI/hand_textbox'));
			add(handSelect);
		} else {
			var file = Paths.image('dialogue/hand_textbox');
			if(Paths.exists(file, IMAGE)) {
				handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(file);
				handSelect.antialiasing = true;
				add(handSelect);
			}
		}

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", fontSize);
		dropText.font = defaultFont;
		dropText.color = dropTextColor;
		dropText.visible = dropTextVisible;
		dropText.alpha = dropTextVisible ? 1 : 0;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", fontSize);
		swagDialogue.font = defaultFont;
		swagDialogue.color = swagDialogueColor;
		swagDialogue.sounds = swagDialogueSounds;
		add(swagDialogue);
	}

	public var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	var isEnding:Bool = false;
	var forceProgress:Bool = false;

	override function update(elapsed:Float)
	{
		dropText.text = swagDialogue.text;

		if(box.animation.curAnim != null)
		{
			if(box.animation.curAnim.name == 'appear' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if(dialogueOpened && !dialogueStarted)
		{
			progressDialogue();
			dialogueStarted = true;
		}

		var shouldProgressDialogue:Bool;

		if(allowKeyPresses) {
			shouldProgressDialogue = FlxG.keys.justPressed.ANY;
		} else {
			shouldProgressDialogue = dialogueTimer.finished;
			if(dialogueTimer.finished) {
				dialogueTimer.reset(dialogueTime);
			}
		}

		if(forceProgress || (shouldProgressDialogue && dialogueStarted))
		{
			if(!forceProgress && allowKeyPresses && doClickFX) FlxG.sound.play(Paths.sound(clickFX), 0.8);
			forceProgress = false;

			if(dialogueEvents.length == 0)
			{
				if(!isEnding)
				{
					isEnding = true;

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						hidePortraits();
						swagDialogue.alpha -= 1 / 5;
						dropText.alpha = swagDialogue.alpha;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						if(finishThing != null) finishThing();
						removeSounds();
						kill();
					});

					new FlxTimer().start(fadeOutMusicDuration, function(tmr:FlxTimer)
					{
						if(isFadingMusic) removeBGM();
					});
				}
			}
			else
			{
				if(!allowKeyPresses && doClickFX) FlxG.sound.play(Paths.sound(clickFX), 0.8);
				progressDialogue();
			}
		}

		super.update(elapsed);
	}

	function removeBGM() {
		if(PlayState.alternativeMusic != null) {
			FlxG.sound.list.remove(PlayState.alternativeMusic);
			PlayState.alternativeMusic.stop();
			PlayState.alternativeMusic = null;
		}
	}

	public function removeSounds() {
		if(!isFadingMusic) removeBGM();
		if(curVoice != null) {
			FlxG.sound.list.remove(curVoice);
			curVoice.stop();
			curVoice = null;
		}
	}

	var dialogueEvents:Array<DialogueEvent> = [];

	function progressDialogue(shouldDoText:Bool = true) {
		var currentEvent = dialogueEvents[0];

		if(!shouldDoText && Std.isOfType(currentEvent, Dialogue)) return;

		while(dialogueEvents.length != 0) {
			currentEvent = dialogueEvents[0];
			var shouldBreak = false;

			if(Std.isOfType(currentEvent, Dialogue)) {
				if(!shouldDoText) break;
				shouldBreak = true;
			}

			currentEvent = dialogueEvents.shift();

			nextDialogue(currentEvent);

			if(shouldBreak) break;
		}

		if(dialogueEvents.length == 0 && !Std.isOfType(currentEvent, Dialogue)) {
			forceProgress = true;
		}
	}

	function hidePortraits() {
		for(portrait in portraits) {
			portrait.visible = false;
			portrait.active = false;
		}
	}

	public function setPortraitsColors(color:Int) {
		defaultPortraitColor = color;
		for(portrait in portraits) {
			portrait.color = color;
		}
	}

	public static function cachePortrait(character:String) {
		var portrait = new FlxSprite(0, 40);
		var path = 'dialogue/portraits/$character';

		if(Paths.exists(Paths.file('images/$path.xml')) && !Paths.exists(Paths.file('images/$path.noanim'))) {
			portrait.frames = Paths.getSparrowAtlas(path);
			portrait.animation.addByPrefix('enter', 'portrait enter', 24, false);
		} else {
			portrait.loadGraphic(Paths.image(path));
		}
		return portrait;
	}

	var portraitOffsets = new Map<String, Array<Float>>();
	var centeredPortraits:Array<String> = [];

	function addPortrait(character:String) {
		var portrait:FlxSprite;
		var path = 'dialogue/portraits/$character';

		if(this.cachedPortraits != null && this.cachedPortraits.exists(character)) {
			portrait = this.cachedPortraits.get(character);
		} else {
			portrait = cachePortrait(character);
		}

		if(Paths.exists(Paths.file('images/$path.xml')) && !Paths.exists(Paths.file('images/$path.noanim'))) {
			if(!isPixel) {
				portrait.y += 45;
			}
		} else {
			portrait.x = box.x;
		}

		portraitOffsets[character] = [0.0, 0.0];

		var shouldCenterX = false;

		var offsetFilePath = Paths.file('images/$path.offset');
		if(Paths.exists(offsetFilePath)) {
			var data:String = Assets.getText(offsetFilePath).trim().split("\n")[0];

			if(data.toLowerCase() == "center") {
				shouldCenterX = true;
			} else {
				var info = data.split(",");
				var x = Std.parseFloat(info[0]);
				var y = Std.parseFloat(info[1]);
				portrait.x += x;
				portrait.y += y;
				portraitOffsets[character] = [x, y];
			}
		}

		portrait.setGraphicSize(Std.int(portrait.width * boxScale));
		portrait.updateHitbox();
		if(Paths.exists(Paths.file('images/$path.flip'))) {
			portrait.scale.x *= -1;
		}
		portrait.scrollFactor.set();
		portrait.visible = false;
		portrait.active = false;
		portrait.antialiasing = !isPixel;
		portrait.color = defaultPortraitColor;
		if(shouldCenterX) {
			portrait.screenCenter(X);
			centeredPortraits.push(character);
		}
		add(portrait);

		portraits[character] = portrait;
	}

	function nextDialogue(currentEvent:DialogueEvent):Void
	{
		if(Std.isOfType(currentEvent, Dialogue)) {
			var currentEvent = cast (currentEvent, Dialogue);
			var text = currentEvent.text;
			var curCharacter = currentEvent.character;

			swagDialogue.resetText(text);
			swagDialogue.start(textDelay, true);

			var currentPortrait = portraits[curCharacter];
			var isCurPortraitVisible = currentPortrait.visible;

			hidePortraits();

			currentPortrait.visible = true;
			currentPortrait.active = true;

			var enterAnim = currentPortrait.animation.getByName('enter');

			if(!isCurPortraitVisible) {
				if(enterAnim != null) {
					currentPortrait.animation.play('enter');
				}
			}

			if(enterAnim == null) { // Single image
				var modifyX = true;
				if(centeredPortraits.contains(curCharacter)) modifyX = false;

				currentPortrait.flipX = !isFlipped;
				if(modifyX) currentPortrait.x = box.x;

				currentPortrait.y = box.y + 100;
				currentPortrait.y -= currentPortrait.height;

				var offset = portraitOffsets[curCharacter];

				if(modifyX) currentPortrait.x += offset[0];
				currentPortrait.y += offset[1];

				if(modifyX) {
					if(isFlipped) {
						//currentPortrait.x += 100;
						//currentPortrait.x += 30;
					} else {
						currentPortrait.x += box.width;
						currentPortrait.x -= currentPortrait.width;
						currentPortrait.x -= 100;
					}
				}
			}
		} else {
			currentEvent.runEvent();
		}
	}

	public static function parseDialog(lines:Array<String>):Array<DialogueEvent>
	{
		var dialogueEvents:Array<DialogueEvent> = [];

		for(line in lines)
		{
			if(line.trim() == "") continue;

			if(line.startsWith(">")) {
				var eventTagIndex = line.indexOf("<");
				var event = line.substr(1, eventTagIndex - 1).trim().toLowerCase();
				var data = line.substr(eventTagIndex + 1).trim();

				var dialogueEvent:DialogueEvent = switch(event) {
					case 'bgm' | 'bgmusic': new BGMusic(data);
					case 'stopbgm' | 'stopbgmusic': new StopBGMusic();
					case 'fadeoutbgm' | 'fadeoutbgmusic': new FadeOutBGMusic(data);
					case 'sample': new Sample(data);
					case 'changeclickfx': new ChangeClickFX(data);
					case 'changetextfx': new ChangeTextFX(data);
					case 'toggleclickfx': new ToggleClickFX();
					case 'toggletextfx': new ToggleTextFX();
					case 'toggledroptext': new ToggleDropText();
					case 'toggleboxflip': new ToggleBoxFlip();
					case 'ispixel': new EnablePixel();
					case 'togglebgfade': new ToggleBGFade();
					case 'textdelay': new TextDelay(Std.parseFloat(data));
					case 'image': new MakeImage(data);
					case 'changebox': new ChangeBox(data);
					case 'flip': new FlipBox();
					case 'movebox' | 'moveboxrel': new MoveBox(data, event == "moveboxrel");
					case 'font' | 'setfont': new SetFont(data);
					case 'fontcolor' | 'setfontcolor': new SetFontColor(data);
					case 'fontsize' | 'setfontsize': new SetFontSize(Std.parseInt(data));
					case 'boxanim': new PlayBoxAnim(data);
					case 'timer': new SetTimer(Std.parseFloat(data));
					case 'portraitcolors': new SetPortraitColors(Std.parseInt(data));
					case 'boxscale': new SetBoxScale(Std.parseFloat(data));
					case 'background' | 'bg': new SetBackground(data);
					case 'hidebackground' | 'hidebg': new HideBackground();
					case 'voice': new PlayVoice(data);
					case 'stopvoice': new StopVoice();

					default: null;
				}

				if(dialogueEvent != null) {
					dialogueEvents.push(dialogueEvent);
				}
			} else {
				var splitInfo:Array<String> = line.split(":");
				var curCharacter = splitInfo[1];
				var text = line.substr(curCharacter.length + 2).trim();

				var dialogue = new Dialogue(curCharacter, text);
				dialogueEvents.push(dialogue);
			}
		}

		return dialogueEvents;
	}
}

class DialogueEvent {
	public var system:DialogueSystem;

	public function new() {}
	public function runEvent() throw "stub!";
}

class Dialogue extends DialogueEvent {
	public var character:String;
	public var text:String;

	public function new(character:String, text:String) {
		super();
		this.character = character;
		this.text = text;
	}
}

class BGMusic extends DialogueEvent {
	public var filename:String;

	public function new(filename:String) {
		super();
		this.filename = filename;
	}

	override public function runEvent() {
		if(PlayState.alternativeMusic == null) {
			PlayState.alternativeMusic = new FlxSound();
			FlxG.sound.list.add(PlayState.alternativeMusic);
		}
		system.isFadingMusic = false;
		var bgmusic = PlayState.alternativeMusic;
		if (bgmusic.active) bgmusic.stop();

		bgmusic.loadEmbedded(Paths.music(filename), true);
		bgmusic.volume = 0;
		bgmusic.persist = true;
		bgmusic.play();
		bgmusic.fadeIn(1, 0, 0.8);
	}
}

class Sample extends DialogueEvent {
	public var filename:String;

	public function new(filename:String) {
		super();
		this.filename = filename;
	}

	override public function runEvent() {
		FlxG.sound.play(Paths.sound(filename));
	}
}

class StopBGMusic extends DialogueEvent {
	override public function runEvent() {
		if(PlayState.alternativeMusic != null) PlayState.alternativeMusic.stop();
		system.isFadingMusic = false;
	}
}

class FadeOutBGMusic extends DialogueEvent {
	public var duration:Float = 2.2;

	public function new(data:String) {
		super();
		if(data != "") {
			this.duration = Std.parseFloat(data);
		}
	}

	override public function runEvent() {
		system.fadeOutMusicDuration = duration;
		if(PlayState.alternativeMusic != null) PlayState.alternativeMusic.fadeOut(duration, 0);
		system.isFadingMusic = true;
	}
}

class ToggleClickFX extends DialogueEvent {
	override public function runEvent() {
		system.doClickFX = !system.doClickFX;
	}
}

class ToggleTextFX extends DialogueEvent {
	override public function runEvent() {
		if(system.swagDialogueSounds == null) {
			system.swagDialogueSounds = [system.pixelTextFX];
		} else {
			system.swagDialogueSounds = null;
		}

		if(system.swagDialogue != null) {
			system.swagDialogue.sounds = system.swagDialogueSounds;
		}
	}
}

class ChangeTextFX extends DialogueEvent {
	public var filename:String;
	public var textFX:FlxSound;

	public function new(filename:String) {
		super();
		this.filename = filename;
		textFX = FlxG.sound.load(Paths.sound(filename), 0.6);
	}

	override public function runEvent() {
		system.swagDialogueSounds = [textFX];

		if(system.swagDialogue != null) {
			system.swagDialogue.sounds = system.swagDialogueSounds;
		}
	}
}

class ChangeClickFX extends DialogueEvent {
	public var filename:String;

	public function new(filename:String) {
		super();
		this.filename = filename;
	}

	override public function runEvent() {
		system.clickFX = filename;
	}
}

class ToggleBoxFlip extends DialogueEvent {
	override public function runEvent() {
		system.shouldFlipBox = !system.shouldFlipBox;

		if(system.shouldFlipBox) {
			system.box.flipX = system.isFlipped;
		}
	}
}

class ToggleDropText extends DialogueEvent {
	override public function runEvent() {
		system.dropTextVisible = !system.dropTextVisible;

		if(system.dropText != null) {
			if(system.dropTextVisible) {
				system.dropText.visible = true;
				system.dropText.alpha = 1;
			} else {
				system.dropText.visible = false;
				system.dropText.alpha = 0;
			}
		}
	}
}

class PlayVoice extends DialogueEvent {
	public var filename:String;
	public var voice:FlxSound;

	public function new(filename:String) {
		super();
		this.filename = Paths.sound(filename);
		voice = new FlxSound().loadEmbedded(this.filename);
	}

	override public function runEvent() {
		var wasNull = system.curVoice == null;
		if(system.curVoice != null && system.curVoice.playing) system.curVoice.stop();

		system.curVoice = voice;
		if(wasNull) FlxG.sound.list.add(system.curVoice);
		system.curVoice.play();
	}
}

class StopVoice extends DialogueEvent {
	override public function runEvent() {
		if(system.curVoice != null && system.curVoice.playing)
			system.curVoice.stop();
	}
}

class EnablePixel extends DialogueEvent {
	override public function runEvent() {
		system.isPixel = true;
	}
}

class ToggleBGFade extends DialogueEvent {
	override public function runEvent() {
		system.bgFade.visible = !system.bgFade.visible;
	}
}

class TextDelay extends DialogueEvent {
	public var delay:Float;

	public function new(delay:Float) {
		super();
		this.delay = delay;
	}

	override public function runEvent() {
		system.textDelay = delay;
	}
}

class MakeImage extends DialogueEvent {
	public var x:Float;
	public var y:Float;
	public var filename:String;
	public var scale:Float;

	public function new(data:String) {
		super();
		var info:Array<String> = data.split(",");

		this.x = Std.parseFloat(info[0]);
		this.y = Std.parseFloat(info[1]);
		this.filename = info[2];
		this.scale = info.length > 3 ? Std.parseFloat(info[3]) : 1;
	}

	override public function runEvent() {
		var sprite = new FlxSprite(x, y).loadGraphic(Paths.image(filename));
		if(scale != 1) {
			sprite.setGraphicSize(Std.int(sprite.width * scale));
		}
		system.add(sprite);
	}
}

class ChangeBox extends DialogueEvent {
	public var filename:String;
	public var fps:Int;
	public var startAnim:String;

	public function new(data:String) {
		super();
		var info:Array<String> = data.split(",");

		this.filename = info[0];
		this.fps = info.length > 1 ? Std.parseInt(info[1]) : 24;
		this.startAnim = info.length > 2 ? info[2] : "";
	}

	override public function runEvent() {
		system.box.frames = Paths.getSparrowAtlas(filename);
		system.box.animation.addByPrefix('appear', 'appear', fps, false);
		system.box.animation.addByPrefix('normal', 'normal', fps, true);
		if(startAnim != "") {
			system.box.animation.play(startAnim);
		}
		system.changedBox = true;
		system.box.offset.set(0, 0);

		if(system.dialogueOpened) {
			system.box.y = FlxG.height - 45;

			system.box.setGraphicSize(Std.int(system.box.width * system.boxScale));
			system.box.updateHitbox();

			system.box.y -= system.box.height;
			system.box.y += 20;

			system.box.screenCenter(X);
		}
	}
}

class FlipBox extends DialogueEvent {
	override public function runEvent() {
		system.isFlipped = !system.isFlipped;

		if(system.shouldFlipBox) {
			system.box.flipX = system.isFlipped;
		}
	}
}

class MoveBox extends DialogueEvent {
	public var x:Float;
	public var y:Float;
	public var relative:Bool;

	public function new(data:String, relative:Bool = false) {
		super();
		var info:Array<String> = data.split(",");

		this.x = Std.parseFloat(info[0]);
		this.y = Std.parseFloat(info[1]);
		this.relative = relative;
	}

	override public function runEvent() {
		if(system.dialogueOpened) {
			if(relative) {
				system.box.x += x;
				system.box.y += y;
			} else {
				system.box.x = x;
				system.box.y = y;
			}
		} else {
			if(relative) {
				system.box.offset.add(x, y);
				//system.box.offset.x += x;
				//system.box.offset.y += y;
			} else {
				system.box.offset.set(x, y);
			}
		}
	}
}

class SetFont extends DialogueEvent {
	public var filename:String;

	public function new(filename:String) {
		super();
		this.filename = filename;
	}

	override public function runEvent() {
		var font = Assets.getFont(Paths.fontLib(filename)).fontName;
		system.defaultFont = font;

		if(system.swagDialogue != null) {
			system.swagDialogue.font = font;
			system.dropText.font = font;
		}
	}
}

class SetFontColor extends DialogueEvent {
	public var color:Int;
	public var dropColor:Int;

	public function new(data:String) {
		super();
		var info:Array<String> = data.split(",");

		this.color = Std.parseInt(info[0]);
		this.dropColor = info.length > 1 ? Std.parseInt(info[1]) : -1;
	}

	override public function runEvent() {
		if(system.swagDialogue == null) {
			system.swagDialogueColor = color;
		} else {
			system.swagDialogue.color = color;
		}

		if(dropColor != -1) {
			if(system.dropText == null) {
				system.dropTextColor = dropColor;
			} else {
				system.dropText.color = dropColor;
			}
		}
	}
}

class SetFontSize extends DialogueEvent {
	public var size:Int;

	public function new(size:Int) {
		super();
		this.size = size;
	}

	override public function runEvent() {
		system.fontSize = size;

		if(system.swagDialogue != null) {
			system.swagDialogue.size = size;
			system.dropText.size = size;
		}
	}
}

class SetBoxScale extends DialogueEvent {
	public var scale:Float;

	public function new(scale:Float) {
		super();
		this.scale = scale;
	}

	override public function runEvent() {
		system.boxScale = scale;
	}
}

class PlayBoxAnim extends DialogueEvent {
	public var animation:String;

	public function new(animation:String) {
		super();
		this.animation = animation;
	}

	override public function runEvent() {
		system.box.animation.play(animation);
	}
}

class SetTimer extends DialogueEvent {
	public var time:Float;

	public function new(time:Float) {
		super();
		this.time = time;
	}

	override public function runEvent() {
		system.dialogueTime = time;
		system.dialogueTimer.reset(time);
	}
}

class SetPortraitColors extends DialogueEvent {
	public var color:Int;

	public function new(color:Int) {
		super();
		this.color = color;
	}

	override public function runEvent() {
		system.setPortraitsColors(color);
	}
}

class SetBackground extends DialogueEvent {
	public var filename:String;

	public function new(data:String) {
		super();
		filename = Paths.image(data);
	}

	override public function runEvent() {
		if(Paths.exists(filename, IMAGE)) {
			system.background.loadGraphic(filename);
		} else {
			trace('Could not find file named $filename');
		}
		system.background.visible = true;
	}
}

class HideBackground extends DialogueEvent {
	override public function runEvent() {
		system.background.visible = false;
	}
}