package game;

class Random {
	public static function between(min:Float, max:Float):Float {
		return hxd.Math.random(max - min) + min;
	}

	public static function vec2(minX:Float, maxX:Float, minY:Float, maxY:Float) {
		return new Vec2(between(minX, maxX), between(minY, maxY));
	}
}
