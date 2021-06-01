abstract AbstractNote(Array<Dynamic>) {
	public var strumTime(get, set):Float;

	public var noteData(get, set):Int;

	public var holdLength(get, set):Float;

	public var altAnim(get, set):Null<Int>;

	public var noteSpeed(get, set):Null<Float>;

	public inline function new(info:Array<Dynamic>)
	{
		this = info;
	}

	@:noCompletion private inline function get_strumTime():Float return this[0];
	@:noCompletion private inline function set_strumTime(value:Float):Float return this[0] = value;

	@:noCompletion private inline function get_noteData():Int return this[1];
	@:noCompletion private inline function set_noteData(value:Int):Int return this[1] = value;

	@:noCompletion private inline function get_holdLength():Float return this[2];
	@:noCompletion private inline function set_holdLength(value:Float):Float return this[2] = value;

	@:noCompletion private inline function get_altAnim():Null<Int> {
		if(this.length < 3) return 0;
		return this[3];
	}
	@:noCompletion private inline function set_altAnim(value:Int):Null<Int> return this[3] = value;

	@:noCompletion private inline function get_noteSpeed():Null<Float>
	{
		if(this.length < 4) return null;
		return this[4];
	}
	@:noCompletion private inline function set_noteSpeed(value:Float):Null<Float> return this[4] = value;
}