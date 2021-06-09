package;

import openfl.Lib;

#if web
typedef Handler = VideoHandler;
#else
typedef Handler = WebmHandler;
#end

class GlobalVideo
{
	private static var handler:Handler;
	public inline static var daAlpha1:Float = 0.2;
	public inline static var daAlpha2:Float = 1;

	public inline static function setHandler(vid:Handler):Void
	{
		handler = vid;
	}

	public inline static function get():Handler
	{
		return handler;
	}

	public static function calc(ind:Int):Float
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		var width:Float = GameDimensions.width;
		var height:Float = GameDimensions.height;

		var ratioX:Float = height / width;
		var ratioY:Float = width / height;
		var appliedWidth:Float = stageHeight * ratioY;
		var appliedHeight:Float = stageWidth * ratioX;

		var remainingX:Float = (stageWidth - appliedWidth)/2;
		var remainingY:Float = (stageHeight - appliedHeight)/2;

		appliedWidth = Std.int(appliedWidth);
		appliedHeight = Std.int(appliedHeight);

		if (appliedHeight > stageHeight)
		{
			remainingY = 0;
			appliedHeight = stageHeight;
		}

		if (appliedWidth > stageWidth)
		{
			remainingX = 0;
			appliedWidth = stageWidth;
		}

		return switch(ind)
		{
			case 0: remainingX;
			case 1: remainingY;
			case 2: appliedWidth;
			case 3: appliedHeight;
			default: throw "Invalid Calc Index";
		}
	}
}