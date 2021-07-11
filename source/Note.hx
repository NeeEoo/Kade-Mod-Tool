package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import PlayState;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;
	public var noteSpeed:Float = 0;
	public var altAnim:Bool = false;
	public var noteData:Int = 0;
	public var sustainLength:Float = 0;

	public var rawNoteData:Int = 0;

	public var mustPress:Bool = false;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var isSustainNote:Bool = false;

	// public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;

	public var rating:String = "shit";

	public function new(strumTime:Float, noteData:Int, noteSpeed:Null<Float>, ?prevNote:Note, ?sustainNote:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		if (this.strumTime < 0)
			this.strumTime = 0;

		if (noteSpeed == null)
			noteSpeed = PlayState.SONG.speed;

		this.noteData = noteData;
		this.noteSpeed = noteSpeed;

		switch (PlayState.SONG.noteStyle)
		{
			case 'pixel':
				if (isSustainNote) {
					loadGraphic(Paths.image('pixelUI/arrowEnds'), true, 7, 6);

					animation.add('purplehold', [0]);
					animation.add('bluehold', [1]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);

					animation.add('purpleholdend', [4]);
					animation.add('blueholdend', [5]);
					animation.add('greenholdend', [6]);
					animation.add('redholdend', [7]);
				} else {
					loadGraphic(Paths.image('pixelUI/arrows-pixels'), true, 17, 17);
					animation.add('purpleScroll', [4]);
					animation.add('blueScroll', [5]);
					animation.add('greenScroll', [6]);
					animation.add('redScroll', [7]);
				}

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();

			// "normal" goes here also
			default:
				frames = Paths.getSparrowAtlas('NOTE_assets');

				if(isSustainNote) {
					animation.addByPrefix('purpleholdend', 'pruple end hold');
					animation.addByPrefix('greenholdend', 'green hold end');
					animation.addByPrefix('redholdend', 'red hold end');
					animation.addByPrefix('blueholdend', 'blue hold end');
	
					animation.addByPrefix('purplehold', 'purple hold piece');
					animation.addByPrefix('greenhold', 'green hold piece');
					animation.addByPrefix('redhold', 'red hold piece');
					animation.addByPrefix('bluehold', 'blue hold piece');
				} else {
					animation.addByPrefix('greenScroll', 'green0');
					animation.addByPrefix('redScroll', 'red0');
					animation.addByPrefix('blueScroll', 'blue0');
					animation.addByPrefix('purpleScroll', 'purple0');
				}

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = true;
		}

		x += swagWidth * noteData;

		if(!isSustainNote) {
			switch (noteData)
			{
				case 0: animation.play('purpleScroll');
				case 1: animation.play('blueScroll');
				case 2: animation.play('greenScroll');
				case 3: animation.play('redScroll');
			}
		}

		// trace(prevNote);

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		if (FlxG.save.data.downscroll && sustainNote)
			flipY = true;

		if (isSustainNote && prevNote != null)
		{
			// noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			switch (noteData)
			{
				case 0: animation.play('purpleholdend');
				case 1: animation.play('blueholdend');
				case 2: animation.play('greenholdend');
				case 3: animation.play('redholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school'))
				x += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0: prevNote.animation.play('purplehold');
					case 1: prevNote.animation.play('bluehold');
					case 2: prevNote.animation.play('greenhold');
					case 3: prevNote.animation.play('redhold');
				}

				if(FlxG.save.data.scrollSpeed != 1)
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * FlxG.save.data.scrollSpeed;
				else
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * noteSpeed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// The * 0.5 is so that it's easier to hit them too late, instead of too early
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
