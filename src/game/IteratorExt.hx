package game;

using game.IteratorExt;

class IteratorExt {
	public static inline function flatMap<A, B>(source:Iterator<A>,
			map:(A) -> Iterable<B>):Iterator<B> {
		return new FlatMapIterator(source, map);
	}

	public static inline function filter<A>(source:Iterator<A>,
			predicate:(A) -> Bool):Iterator<A> {
		return new FilterIterator(source, predicate);
	}
}

private class FlatMapIterator<A, B> {
	public inline function new(source:Iterator<A>, map:(A) -> Iterable<B>) {
		this.map = map;
		this.source = source;
	}

	final map:(A) -> Iterable<B>;
	final source:Iterator<A>;
	var current:Iterator<B>;

	public inline function hasNext() {
		while (current == null || !current.hasNext()) {
			if (!source.hasNext()) {
				break;
			} else {
				current = map(source.next())
					.iterator();
			}
		}
		return current.hasNext();
	}

	public inline function next() {
		return current.next();
	}
}

private class FilterIterator<A> {
	public inline function new(source:Iterator<A>, predicate:(A) -> Bool) {
		this.source = source;
		this.predicate = predicate;
	}

	final source:Iterator<A>;
	final predicate:A->Bool;
	var nextItem:Null<A>;

	public inline function hasNext():Bool {
		for (item in source) {
			if (predicate(item)) {
				nextItem = item;
				break;
			}
		}
		return nextItem != null;
	}

	public inline function next():A {
		final item = nextItem;
		nextItem = null;
		return item;
	}
}
