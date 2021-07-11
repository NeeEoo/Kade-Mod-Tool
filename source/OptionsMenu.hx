package;

import Options;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

class OptionsMenu extends MusicBeatState
{
	// var selector:FlxText;
	var curSelected:Int = 0;

	var options:Array<OptionCategory> = [
		new OptionCategory("Gameplay", [
			new DFJKOption(controls),
			new Judgement("Customize your Hit Timings (LEFT or RIGHT)"),
			#if desktop
			new FPSCapOption("Cap your FPS (Left for -10, Right for +10. SHIFT to go faster)"),
			#end
			new ScrollSpeedOption("Change your scroll speed (Left for -0.1, right for +0.1. If its at 1, it will be chart dependent)"),
			new AccuracyDOption("Change how accuracy is calculated. (Accurate = Simple, Complex = Milisecond Based)"),
			// new OffsetMenu("Get a note offset based off of your inputs!"),
			new CustomizeGameplay("Drag'n'Drop Gameplay Modules around to your preference")
		]),
		new OptionCategory("Appearence", [
			new SongPositionOption("Show the songs current position (as a bar)"),
			new DownscrollOption("Change the layout of the strumline."),
			#if desktop
			new RainbowFPSOption("Make the FPS Counter Rainbow (Only works with the FPS Counter toggeled on)"),
			#end
			new AccuracyOption("Display accuracy information."),
			new NPSDisplayOption("Shows your current Notes Per Second.")
		]),

		new OptionCategory("Misc", [
			#if desktop
			new FPSOption("Toggle the FPS Counter"),
			new ReplayOption("View replays"),
			#end
			new WatermarkOption("Turn off all watermarks from the engine.")
		])
	];

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<Alphabet>;
	public static var versionShit:FlxText;

	var currentSelectedCat:OptionCategory;

	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		menuBG.color = 0xFFea71fd; //0xFFe62c2c;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		currentDescription = "none";

		versionShit = new FlxText(5, FlxG.height - 18, 0, "", 12);
		updateOffsetText();
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		super.create();
	}

	var isCat:Bool = false;

	function updateOffsetText() {
		versionShit.text = "Offset (Left, Right, Shift for slow): " + truncateFloat(FlxG.save.data.offset, 2) + " - Description - " + currentDescription;
	}

	public static function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.BACK && !isCat)
			FlxG.switchState(new MainMenuState());
		else if (controls.BACK)
		{
			isCat = false;
			grpControls.clear();
			for (i in 0...options.length)
			{
				var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].getName(), true, false);
				controlLabel.isMenuItem = true;
				controlLabel.targetY = i;
				grpControls.add(controlLabel);
				// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			}
			curSelected = 0;
		}
		if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);

		if (isCat)
		{
			var currentCategoryOption = currentSelectedCat.getOptions()[curSelected];

			if (currentCategoryOption.getAccept())
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.pressed.RIGHT)
						currentCategoryOption.right();
					if (FlxG.keys.pressed.LEFT)
						currentCategoryOption.left();
				}
				else
				{
					if (FlxG.keys.justPressed.RIGHT)
						currentCategoryOption.right();
					if (FlxG.keys.justPressed.LEFT)
						currentCategoryOption.left();
				}
			}
			else
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.justPressed.RIGHT)
						FlxG.save.data.offset += 0.1;
					else if (FlxG.keys.justPressed.LEFT)
						FlxG.save.data.offset -= 0.1;
				}
				else if (FlxG.keys.pressed.RIGHT)
					FlxG.save.data.offset += 0.1;
				else if (FlxG.keys.pressed.LEFT)
					FlxG.save.data.offset -= 0.1;

				updateOffsetText();
			}
		}
		else
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.justPressed.RIGHT)
					FlxG.save.data.offset += 0.1;
				else if (FlxG.keys.justPressed.LEFT)
					FlxG.save.data.offset -= 0.1;
			}
			else if (FlxG.keys.pressed.RIGHT)
				FlxG.save.data.offset += 0.1;
			else if (FlxG.keys.pressed.LEFT)
				FlxG.save.data.offset -= 0.1;

			updateOffsetText();
		}

		if (controls.RESET)
			FlxG.save.data.offset = 0;

		if (controls.ACCEPT)
		{
			if (isCat)
			{
				if (currentSelectedCat.getOptions()[curSelected].press()) {
					grpControls.remove(grpControls.members[curSelected]);
					var ctrl:Alphabet = new Alphabet(0, (70 * curSelected) + 30, currentSelectedCat.getOptions()[curSelected].getDisplay(), true, false);
					ctrl.isMenuItem = true;
					grpControls.add(ctrl);
				}
			}
			else
			{
				currentSelectedCat = options[curSelected];
				isCat = true;
				grpControls.clear();
				for (i in 0...currentSelectedCat.getOptions().length)
				{
					var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].getDisplay(), true, false);
					controlLabel.isMenuItem = true;
					controlLabel.targetY = i;
					grpControls.add(controlLabel);
					// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
				}
				curSelected = 0;
			}
		}
		FlxG.save.flush();
	}

	// var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		else if (curSelected >= grpControls.length)
			curSelected = 0;

		if (isCat)
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();
		else
			currentDescription = "Please select a category";
		updateOffsetText();

		// selector.y = (70 * curSelected) + 30;

		var i:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = i - curSelected;
			i++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
