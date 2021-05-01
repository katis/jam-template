package game;

class FunctionExt {
	public static inline function pipe<A, B>(a:A, fn:(A) -> B):Pipe<B> {
		return new Pipe(a)
			.pipe(fn);
	}
}

abstract Pipe<A>(A) to A {
	public inline function new(a:A) {
		this = a;
	}

	public inline function pipe<B>(fn:(A) -> B):Pipe<B> {
		return new Pipe(fn(this));
	}
}
