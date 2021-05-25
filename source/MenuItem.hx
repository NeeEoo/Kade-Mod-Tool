package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

class MenuItem extends FlxSpriteGroup
{
	public var targetY:Float = 0;
	public var week:FlxSprite;
	public var flashingInt:Int = 0;
	public var isCategory:Bool = false;

	public function new(x:Float, y:Float, weekNum:Int = 0, ?text:String, ?isCategory:Bool = false)
	{
		super(x, y);
		this.isCategory = isCategory;

		// TODO: Make it default to the base game images
		// week = new FlxSprite().loadGraphic(Paths.image('storymenu/week' + weekNum));
		week = makeText(weekNum, text, isCategory);

		add(week);
	}

	public static function makeText(weekNum:Int = 0, ?text:String, ?isCategory:Bool = false) {
		var week:FlxSprite;
		var assetKey = 'week' + weekNum + '/week';
		if(isCategory) {
			assetKey = "modImage";
		}

		if(Paths.doesWeekTextImage(assetKey)) {
			week = new FlxSprite().loadGraphic(Paths.weekTextImage(assetKey));
		} else {
			if(text == null) {
				if(isCategory) {
					text = "MODNAME MISSING";
				} else {
					text = "Week " + weekNum;
				}
			}
			week = new Alphabet(0, 0, text, true, false, !isCategory);
		}
		return week;
	}

	private var isFlashing:Bool = false;

	public function startFlashing():Void
	{
		isFlashing = true;
	}

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol
	var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		y = FlxMath.lerp(y, (targetY * 120) + 480, 0.17 * (60 / FlxG.save.data.fpsCap));

		if (isFlashing)
			flashingInt += 1;

		if (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2))
			week.color = 0xFF33ffff;
		else
			week.color = FlxColor.WHITE;
	}
}
