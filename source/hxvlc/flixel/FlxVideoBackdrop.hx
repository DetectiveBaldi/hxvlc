package hxvlc.flixel;

#if flixel
#if !flixel_addons
#error 'Your project must use flixel-addons in order to use this class.'
#end
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import hxvlc.openfl.Video;
import sys.FileSystem;

/**
 * `FlxVideoBackdrop` is made for showing infinitely scrolling video backgrounds using FlxBackdrop.
 */
class FlxVideoBackdrop extends FlxBackdrop
{
	/**
	 * The video bitmap.
	 */
	public var bitmap(default, null):Video;

	/**
	 * Creates an instance of the `FlxVideoBackdrop` class, used to create infinitely scrolling video backgrounds.
	 *
	 * @param repeatAxes The axes on which to repeat. The default, `XY` will tile the entire camera.
	 * @param spacingX Amount of spacing between tiles on the X axis.
	 * @param spacingY Amount of spacing between tiles on the Y axis.
	 */
	#if (flixel_addons >= "3.2.1")
	public function new(repeatAxes = XY, spacingX = 0.0, spacingY = 0.0):Void
	#else
	public function new(repeatAxes = XY, spacingX = 0, spacingY = 0):Void
	#end
	{
		super(repeatAxes, spacingX, spacingY);

		makeGraphic(1, 1, FlxColor.TRANSPARENT);

		bitmap = new Video(false);
		bitmap.alpha = 0;
		#if FLX_SOUND_SYSTEM
		bitmap.onOpening.add(function()
		{
			bitmap.volume = Math.floor(FlxG.sound.volume * 100);
			bitmap.mute = FlxG.sound.muted;
		});
		#end
		bitmap.onFormatSetup.add(() -> loadGraphic(bitmap.bitmapData));

		FlxG.game.addChild(bitmap);
	}

	/**
	 * Call this function to play a video.
	 *
	 * @param location The local filesystem path or the media location url.
	 * @param repeat The number of times the video should repeat itself.
	 *
	 * @return `true` if the video started playing or `false` if there's an error.
	 */
	public function play(location:String, repeat:Int = 0):Bool
	{
		if (bitmap == null)
			return false;

		if (FlxG.autoPause)
		{
			if (!FlxG.signals.focusGained.has(resume))
				FlxG.signals.focusGained.add(resume);

			if (!FlxG.signals.focusLost.has(pause))
				FlxG.signals.focusLost.add(pause);
		}

		if (FileSystem.exists(Sys.getCwd() + location))
			return bitmap.play(Sys.getCwd() + location, repeat);

		return bitmap.play(location, repeat);
	}

	/**
	 * Call this function to stop the video.
	 */
	public function stop():Void
	{
		if (bitmap != null)
			bitmap.stop();
	}

	/**
	 * Call this function to pause the video.
	 */
	public function pause():Void
	{
		if (bitmap != null)
			bitmap.pause();
	}

	/**
	 * Call this function to resume the video.
	 */
	public function resume():Void
	{
		if (bitmap != null)
			bitmap.resume();
	}

	/**
	 * Call this function to toggle the pause of the video.
	 */
	public function togglePaused():Void
	{
		if (bitmap != null)
			bitmap.togglePaused();
	}

	// Overrides
	public override function destroy():Void
	{
		if (FlxG.autoPause)
		{
			if (FlxG.signals.focusGained.has(resume))
				FlxG.signals.focusGained.remove(resume);

			if (FlxG.signals.focusLost.has(pause))
				FlxG.signals.focusLost.remove(pause);
		}

		super.destroy();

		if (bitmap != null)
		{
			bitmap.dispose();

			if (FlxG.game.contains(bitmap))
				FlxG.game.removeChild(bitmap);

			bitmap = null;
		}
	}

	public override function kill():Void
	{
		if (bitmap != null)
			bitmap.pause();

		super.kill();
	}

	public override function revive():Void
	{
		super.revive();

		if (bitmap != null)
			bitmap.resume();
	}

	public override function update(elapsed:Float):Void
	{
		#if FLX_SOUND_SYSTEM
		bitmap.volume = Math.floor(FlxG.sound.volume * 100);
		bitmap.mute = FlxG.sound.muted;
		#end

		super.update(elapsed);
	}
}
#end