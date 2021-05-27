package;

import flixel.FlxG;

class Highscore
{
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, Int> = new Map();
	#else
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	#end

	public static function saveScore(mod:String, song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(mod + "__" + song, diff);

		#if (!switch && ng)
		NGio.postScore(score, song + ' for mod "' + mod + '"');
		#end

		// trace("Saving: " + daSong);

		if (songScores.exists(daSong))
		{
			var oldScore = songScores.get(daSong);
			if (oldScore < score) {
				trace('New Highscore on song: $song on mod $mod. Old was $oldScore. New is $score. Went up ${score - oldScore}');
				setScore(daSong, score);
			}
		}
		else {
			trace('New Highscore on song: $song on mod $mod. Old was 0. New is $score. Went up ${score}');
			setScore(daSong, score);
		}
	}

	public static function saveWeekScore(mod:String, week:Int = 1, score:Int = 0, ?diff:Int = 0):Void
	{
		#if (!switch && ng)
		NGio.postScore(score, "Week " + week + ' for mod "' + mod + '"');
		#end

		var daWeek:String = formatSong(mod + "__" + 'week' + week, diff);

		if (songScores.exists(daWeek))
		{
			var oldScore = songScores.get(daWeek);
			if (oldScore < score) {
				trace('New Highscore on week: $week on mod $mod. Old was $oldScore. New is $score. Went up ${score - oldScore}');
				setScore(daWeek, score);
			}
		}
		else {
			trace('New Highscore on week: $week on mod $mod. Old was 0. New is $score. Went up ${score}');
			setScore(daWeek, score);
		}
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	@:deprecated
	public static function formatSong(song:String, diff:Int):String
	{
		return Song.getSongFilename(song, diff);
	}

	public static function getScore(mod:String, song:String, diff:Int):Int
	{
		var daSong = formatSong(mod + "__" + song, diff);

		// trace("Getting: " + daSong);

		if (!songScores.exists(daSong))
			setScore(daSong, 0);

		return songScores.get(daSong);
	}

	public static function getWeekScore(mod:String, week:Int, diff:Int):Int
	{
		var daSong = formatSong(mod + "__" + 'week' + week, diff);

		if (!songScores.exists(daSong))
			setScore(daSong, 0);

		return songScores.get(daSong);
	}

	public static function load():Void
	{
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;

			// Convert old scores with uppercase to lowercase
			/*for(score in songScores.keys()) {
				trace(score + " -> " + score.toLowerCase() + " | " + songScores.get(score));
				setScore(score.toLowerCase(), songScores.get(score));
			}*/
		}
	}
}
