package funkin.objects.note;

class SplashGroup extends FlxTypedGroup<NoteSplash> {
    public function new(startCache:Int = 4) {
        super();
        for (i in 0...startCache) spawnSplash();
        clearGroup();
    }

    public function clearGroup() {
        for (i in this) i.kill();
    }

	public function spawnSplash(?note:Note) {
		final splash:NoteSplash = recycle(NoteSplash);
		if (note != null) splash.setupNoteSplash(note.x, note.y, note.noteData, note);
		add(splash);
        return splash;
	}
}

class NoteSplash extends FlxSpriteExt implements INoteData {
    public var noteData:Int = 0;
    public var curSkin:String = '';

	public function new(x:Float, y:Float, noteData:Int = 0):Void {
		super(x,y);
        this.noteData = noteData;
        loadSkin();
        alpha = 0.6;
        setupNoteSplash(x,y,noteData);
        moves = false;
	}

	public function setupNoteSplash(X:Float, Y:Float, noteData:Int = 0, ?note:Note):Void {
        if (note != null) {
            if (note.skin != curSkin) {
                loadSkin(note.skin);
            }
            updateHitbox();
            X = note.x + NoteUtil.swagWidth * 0.5;
            Y = note.y + NoteUtil.swagHeight * 0.5;
            noteData = note.noteData;
        }
        this.noteData = noteData;
        setPosition(X,Y);
        playAnim('splash${CoolUtil.directionArray[noteData]}');
        active = true;
		x -= width * 0.5;
		y -= height * 0.5;
	}

    public function loadSkin(?skin:String):Void {
		skin = skin ?? SkinUtil.curSkin;
		if (curSkin != skin) {
            final useSkin = Preferences.getPref('vanilla-ui') ? 'default' : skin;
            final skinData = SkinUtil.getSkinData(useSkin);
            if (skinData.splashData != null) {
                animOffsets = new Map<String, FlxPoint>();
                curSkin = useSkin;
                loadJsonInput(SkinUtil.getSkinData(curSkin).splashData, 'skins/$curSkin', false, Preferences.getPref('vanilla-ui') ? 'skins/$curSkin/splashAssets-vanilla' : null);
            }
		}
	}

	override public function update(elapsed:Float):Void {
        super.update(elapsed);
        if (animation.curAnim != null) {
            if (animation.curAnim.finished) {
                kill();
                active = false;
            }
        }
	}
}