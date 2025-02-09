package funkin.objects.funkui;

import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import haxe.ds.Vector;

/*
 * Like FlxBar but less cringe
**/
class FunkBar extends FlxSpriteExt {
    public var colors:Vector<Int>;
    public var percent:Float = 50.0;
    var max:Float;

    // Adds a rectangle on top of the graphic instead of coloring the graphic
    public var legacyMode:{active:Bool, outline:Float, inFront:Bool, sprite:FlxSprite} = null;
    
    public function new(X:Float, Y:Float, imagePath:String, max:Float = 2.0) {
        super(X, Y);
        scrollFactor.set();
        this.max = max;
        loadImage(imagePath);
        colors = new Vector(2);
        createFilledBar(0xFFFF0000, 0xFF66FF33);
        updateBar(1.0);

        // Turned off but with the default funkin healthbar variables
        legacyMode = {
            active: false,
            outline: 4.0,
            inFront: true,
            sprite: new FlxSprite().makeGraphic(cast width, cast height)
        }
    }

    override function destroy() {
        super.destroy();
        barPoint = FlxDestroyUtil.put(barPoint);
        legacyMode.sprite.destroy();
        colors = null;
        legacyMode = null;
    }

    public inline function createColoredEmptyBar(color:Int) {
        colors[0] = color;
    }

    public inline function createColoredFilledBar(color:Int) {
        colors[1] = color;
    }

    public inline function createFilledBar(color1:Int, color2:Int) {
        createColoredEmptyBar(color1);
        createColoredFilledBar(color2);
    }

    public inline function updateBar(value:Float) {
        percent = value / max * 100.0;
    }

    public var barPoint:FlxPoint = FlxPoint.get();

    override function drawComplex(camera:FlxCamera) {
        _frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);

		if (bakedRotationAngle <= 0) {
			updateTrig();
			if (angle != 0) _matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		getScreenPosition(_point, camera).subtractPoint(offset);
		_point.add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);

		if (isPixelPerfectRender(camera)) {
			_matrix.tx = Math.floor(_matrix.tx);
			_matrix.ty = Math.floor(_matrix.ty);
		}

        /*
         * This isn't pretty too look at but shhhhhh it works
        **/
        
        final _pos = width * percent * 0.01;
        final _sub = width - _pos;
        
        if (legacyMode.active) {
            final _mX = _matrix.tx;
            final _mY = _matrix.ty;
            if (legacyMode.inFront) camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
            
            final _spr = legacyMode.sprite;
            final __frame = _spr.frame;
            final _out = legacyMode.outline * 2;

            _matrix.translate(legacyMode.outline * (_cosAngle - _sinAngle), legacyMode.outline * (_cosAngle + _sinAngle));
            __frame.frame.height = height - _out;

            if (percent != 100) {
                _spr.color = colors[0];
                __frame.frame.width = width - _out;
                camera.drawPixels(__frame, _spr.framePixels, _matrix, _spr.colorTransform, blend, antialiasing, shader);
            }

            _matrix.translate(_sub * _cosAngle, _sub * _sinAngle);

            if (percent != 0) {
                _spr.color = colors[1];
                __frame.frame.width = _pos - _out;
                camera.drawPixels(__frame, _spr.framePixels, _matrix, _spr.colorTransform, blend, antialiasing, shader);
            }

            final _center = height * 0.5;
            barPoint.set(_matrix.tx + (_center * -_sinAngle), _matrix.ty + (_center * _cosAngle));

            if (!legacyMode.inFront) {
                _matrix.tx = _mX;
                _matrix.ty = _mY;
                camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
            }
        }
        else {
            if (percent != 100) {
                color = colors[0];
                _frame.frame.x = 0;
                _frame.frame.width = _sub;
                camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
            }
    
            _matrix.translate(_sub * _cosAngle, _sub * _sinAngle);

            if (percent != 0) {
                color = colors[1];
                _frame.frame.x = _sub;
                _frame.frame.width = _pos;
                camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
            }

            final _center = height * 0.5;
            barPoint.set(_matrix.tx + (_center * -_sinAngle), _matrix.ty + (_center * _cosAngle));
        }
    }
}