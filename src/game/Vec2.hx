package game;

@:forward(x, y)
@:nullSafety(Strict)
abstract Vec2({x:Float, y:Float}) from {x:Float, y:Float} {
	inline public function new(x:Float, y:Float) {
		this = {x: x, y: y};
	}

	public static inline function zero():Vec2 {
		return new Vec2(0, 0);
	}

	public static inline function one():Vec2 {
		return new Vec2(1, 1);
	}

	public inline function cross(other:Vec2):Float {
		return this.x * other.y - this.y * other.x;
	}

	public inline function dot(other:Vec2):Float {
		return this.x * other.x + this.y * other.y;
	}

	public inline function distanceSq(other:Vec2):Float {
		final dx = this.x - other.x;
		final dy = this.y - other.y;
		return dx * dx + dy * dy;
	}

	public inline function distance(other:Vec2):Float {
		return hxd.Math.sqrt(distanceSq(other));
	}

	public inline function length():Float {
		return hxd.Math.sqrt(this.x * this.x + this.y * this.y);
	}

	public inline function lengthSq():Float {
		return this.x * this.x + this.y * this.y;
	}

	public inline function normalize() {
		final k = switch lengthSq() {
			case len if (len < hxd.Math.EPSILON): 0;
			case len: hxd.Math.invSqrt(len);
		};
		this.x *= k;
		this.y *= k;
	}

	public inline function normalized() {
		final k = switch lengthSq() {
			case len if (len < hxd.Math.EPSILON): 0;
			case len: hxd.Math.invSqrt(len);
		};
		return new Vec2(this.x * k, this.y * k);
	}

	@:op(A + B)
	public inline function add(other:Vec2) {
		return new Vec2(this.x + other.x, this.y + other.y);
	}

	@:op(A - B)
	public inline function sub(other:Vec2) {
		return new Vec2(this.x - other.x, this.y - other.y);
	}

	@:op(A * B)
	public inline function mul(f:Float) {
		return new Vec2(this.x * f, this.y * f);
	}

	@:op(A > B)
	public inline function gt(other:Vec2) {
		return lengthSq() > other.lengthSq();
	}

	@:op(A >= B)
	public inline function gteq(other:Vec2) {
		return lengthSq() >= other.lengthSq();
	}

	@:op(A < B)
	public inline function lt(other:Vec2) {
		return lengthSq() < other.lengthSq();
	}

	@:op(A <= B)
	public inline function lteq(other:Vec2) {
		return lengthSq() <= other.lengthSq();
	}

	@:op(A == B)
	public inline function equals(other:Vec2) {
		return this.x == other.x && this.y == other.y;
	}

	@:op(A += B)
	public inline function mutAdd(other:Vec2) {
		this.x += other.x;
		this.y += other.y;
	}

	@:op(A -= B)
	public inline function mutSub(other:Vec2) {
		this.x -= other.x;
		this.y -= other.y;
	}

	@:op(A *= B)
	public inline function mutMul(f:Float) {
		this.x *= f;
		this.y *= f;
	}

	@:op(A /= B)
	public inline function mutDiv(f:Float) {
		this.x /= f;
		this.y /= f;
	}

	public inline function hashCode():Int {
		return Math.round(this.x) ^ Math.round(this.y);
	}

	@:to
	public inline function toPoint():h2d.col.Point {
		if (this is h2d.col.Point) {
			return cast this;
		}
		return new h2d.col.Point(this.x, this.y);
	}
}
