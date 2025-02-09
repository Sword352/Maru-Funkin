package;

import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

class InitState extends FlxState {
    override function create() {
        super.create();

		//Load Settings / Mods
        SaveData.init();
		Controls.setupBindings();
		Preferences.setupPrefs();
        Conductor.init();
		CoolUtil.init();
		Highscore.load();
		#if DISCORD_ALLOWED
		DiscordClient.initialize();
		lime.app.Application.current.onExit.add (function (exitCode) DiscordClient.shutdown());
        #end

        if (FlxG.save.data.askedPreload) {
            FlxG.switchState(new funkin.Preloader());
			return;
        }

		FlxG.save.data.askedPreload = true;
		FlxG.save.flush();

        final txt = new FlxFunkText();
        txt.text =
        "Hey there big boy, do you want to turn on preloading?" + "\n" +
        "It is recommended on most PCs " + "\n" +
		"and will make loading silky smooth."  + "\n" +
        "Turn off if you have a toaster tho." + "\n\n" +
        "Press ACCEPT to turn ON or BACK to turn OFF!!";
        
        txt.alignment = "center";
		txt.size = 32;
		txt.y = FlxG.height * 0.5 - 32 * 3;
        add(txt);
    }

	var selected:Bool = false;

	override function update(elapsed:Float) {
		super.update(elapsed);
		final accept = Controls.getKey('ACCEPT-P');
		final back = Controls.getKey('BACK-P');

		if (accept || back && !selected) {
			selected = true;
			CoolUtil.playSound("confirmMenu");
			FlxG.camera.fade(FlxColor.BLACK, 1, false, function() {
				Preferences.setPref("preload", accept);
				FlxG.switchState(new funkin.Preloader());
			});
		}
	}
}

class Main extends Sprite
{
	var game = {
		width: 1280, 					// Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
		height: 720, 					// Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
		initialState: InitState,		// The FlxState the game starts with.
		zoom: -1.0, 					// If -1, zoom is automatically calculated to fit the window dimensions.
		framerate: 60, 					// How many frames per second the game should run at.
		skipSplash: true, 				// Whether to skip the flixel splash screen that appears in release mode.
		startFullscreen: false 			// Whether to start the game in fullscreen on desktop targets
	};

	public static var fpsCounter:FPS_Mem; //The FPS display child
	public static var console:ScriptConsole;
	public static var transition:Transition;
	public static var engineVersion(default, never):String = "1.0.0-b.1"; //The engine version, if its not the same as the github one itll open OutdatedSubState

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, errorMsg);
		#if cpp
		untyped __global__.__hxcpp_set_critical_error_handler(errorMsg);
		#end
	}

	static function errorMsg(error:Dynamic) {
		#if desktop
		Application.current.window.alert(Std.string(error is UncaughtErrorEvent ? error.error : error), "Uncaught Error");
		DiscordClient.shutdown();
		Sys.exit(1);
		#end
	}

	public function new()
	{
		super();
		stage != null ? init() : addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(?E:Event):Void
	{
		#if mac throw("no."); #end
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
	}

	private function setupGame():Void
	{
		final stageWidth:Int = Lib.current.stage.stageWidth;
		final stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0)
		{
			final ratioX:Float = stageWidth / game.width;
			final ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}

		addChild(new FlxFunkGame(game.width, game.height, game.initialState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
	}
}