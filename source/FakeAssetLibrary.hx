package;

import lime.system.System;
import haxe.io.Path;
import lime.utils.AssetType;
import sys.FileSystem;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import sys.io.File;

using StringTools;

class FakeAssetLibrary {
	public var library:AssetLibrary = null;
	public static var modsFound:Array<String> = [];

	var knownExtensions = [
		"jpg" => IMAGE, "jpeg" => IMAGE, "png" => IMAGE, "gif" => IMAGE, "webp" => IMAGE, "bmp" => IMAGE, "tiff" => IMAGE, "jfif" => IMAGE, "otf" => FONT,
		"ttf" => FONT, "wav" => SOUND, "wave" => SOUND, "mp3" => MUSIC, "mp2" => MUSIC, "exe" => BINARY, "bin" => BINARY, "so" => BINARY, "pch" => BINARY,
		"dll" => BINARY, "zip" => BINARY, "tar" => BINARY, "gz" => BINARY, "fla" => BINARY, "swf" => BINARY, "atf" => BINARY, "psd" => BINARY,
		"awd" => BINARY, "txt" => TEXT, "text" => TEXT, "xml" => TEXT, "java" => TEXT, "hx" => TEXT, "cpp" => TEXT, "c" => TEXT, "h" => TEXT,
		"cs" => TEXT, "js" => TEXT, "mm" => TEXT, "hxml" => TEXT, "html" => TEXT, "json" => TEXT, "css" => TEXT, "gpe" => TEXT, "pbxproj" => TEXT,
		"plist" => TEXT, "properties" => TEXT, "ini" => TEXT, "hxproj" => TEXT, "nmml" => TEXT, "lime" => TEXT, "svg" => TEXT, "bundle" => MANIFEST
	];

	public function new()
	{
	}
	
	public function loadDynamicWeeks()
	{
		var id = "weeks";

		library = new AssetLibrary();

		var weekPath = "assets/weeks";

		recursiveAssetLoop(weekPath);

		// Save the library to the assets
		@:privateAccess
		LimeAssets.libraries.set(id, library);
		library.onChange.add(LimeAssets.onChange.dispatch);

		return this;
	}
	
	private function addFileToAssets(filename:String) {
		var assetType = getAssetType(filename);
		var stat = FileSystem.stat(filename);

		@:privateAccess library.paths.set(filename, library.__cacheBreak(library.__resolvePath(filename)));

		@:privateAccess library.sizes.set(filename, stat.size);
		@:privateAccess library.types.set(filename, assetType);
	}

	private function recursiveAssetLoop(directory:String = null) {
		if(directory == null) throw "Missing Directory";

		if (FileSystem.exists(directory)) {
			for (file in FileSystem.readDirectory(directory)) {
				var path = Path.join([directory, file]);

				if (!FileSystem.isDirectory(path)) {
					if(file == "weeks.json") {
						var checkDirectory = directory;
						if(!checkDirectory.endsWith("/")) {
							checkDirectory += "/";
						}
						var pathSplit = checkDirectory.split("/");

						if(pathSplit.length == 4) { // assets/weeks/modname/
							trace("Found Mod", pathSplit, path);
							modsFound.push(pathSplit[2]);
						}
					}

					addFileToAssets(path);
				} else {
					var directory = Path.addTrailingSlash(path);
					recursiveAssetLoop(directory);
				}
			}
		} else {
			trace('"$directory" does not exist');
		}
	}

	public static function resetCache(library:AssetLibrary) {
		@:privateAccess {
			library.cachedText.clear();
			library.cachedBytes.clear();
			library.cachedFonts.clear();
			library.cachedImages.clear();
			library.cachedAudioBuffers.clear();
		}
	}

	private function getAssetType(filename:String) {
		var extension = Path.extension(filename);
		if (extension != null) extension = extension.toLowerCase();

		if (knownExtensions.exists(extension))
			return knownExtensions.get(extension);
		else
		{
			switch (extension)
			{
				case "bundle":
					return AssetType.MANIFEST;

				case "ogg", "m4a":
					if (FileSystem.exists(filename))
					{
						var stat = FileSystem.stat(filename);

						// if (stat.size > 1024 * 128) {
						if (stat.size > 1024 * 1024)
							return AssetType.MUSIC;
					}

					return AssetType.SOUND;

				default:
					if (filename != "" && isText(filename))
						return AssetType.TEXT;
					else
						return AssetType.BINARY;
			}
		}
	}



	// Code from lime/tools/helpers/FileHelper.hx (File doesn't exist anymore)
	public static function isText(source:String):Bool {
		if (!FileSystem.exists(source)) return false;
		
		var input = File.read(source, true);
		
		var numChars = 0;
		var numBytes = 0;
		var byteHeader = [];
		var zeroBytes = 0;
		
		try {
			while (numBytes < 512) {
				var byte = input.readByte();
				
				if (numBytes < 3) {
					byteHeader.push(byte);
				} else if (byteHeader != null) {
					if (byteHeader[0] == 0xFF && byteHeader[1] == 0xFE) return true; // UCS-2LE or UTF-16LE
					if (byteHeader[0] == 0xFE && byteHeader[1] == 0xFF) return true; // UCS-2BE or UTF-16BE
					if (byteHeader[0] == 0xEF && byteHeader[1] == 0xBB && byteHeader[2] == 0xBF) return true; // UTF-8
					byteHeader = null;
				}
				
				numBytes++;
				
				if (byte == 0) {
					zeroBytes++;
				}
				
				if ((byte > 8 && byte < 16) || (byte > 32 && byte < 256) || byte > 287) {
					numChars++;
				}
				
			}
		} catch (e:Dynamic) {}
		
		input.close();
		
		if (numBytes == 0 || (numChars / numBytes) > 0.9 || ((zeroBytes / numBytes) < 0.015 && (numChars / numBytes) > 0.5)) {
			return true;
		}
		
		return false;
	}
}