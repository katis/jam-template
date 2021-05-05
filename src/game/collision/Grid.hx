package game.collision;

using game.IteratorExt;

class Grid<T> {
	public function new(cellSize:Float, columns:Int, rows:Int) {
		this.columns = columns;
		this.cellSize = cellSize;
		grid = arrayOfLength(columns * rows);
	}

	final cellSize:Float;
	final columns:Int;
	final grid:Array<GridCell<T>> = [];

	public inline function queryRaw(ul:Vec2, lr:Vec2, fn:(T) -> Void) {
		final pa = cellPoint(ul);
		final pb = cellPoint(lr);

		forCellsBetween(pa, pb, (x, y) -> {
			final index = x + y * columns;
			final cell = grid[index];
			if (cell != null) {
				cell.forEach(fn);
			}
		});
	}

	public function move(pos:Vec2, currentCell:GridCell<T>, item:T):GridCell<T> {
		final cell = getCell(pos);
		if (eq(cell, currentCell)) {
			return currentCell;
		}
		currentCell.remove(item);
		cell.add(item);
		return cell;
	}

	public function add(pos:Vec2, item:T):GridCell<T> {
		final cell = getCell(pos);
		cell.add(item);
		return cell;
	}

	public function set(x:Int, y:Int, cell:GridCell<T>) {
		final i = x + columns * y;
		grid[i] = cell;
	}

	inline function cellPoint(pos:Vec2) {
		return {
			x: Math.floor(pos.x / cellSize) - if (pos.x < 0.0) 1 else 0,
			y: Math.floor(pos.y / cellSize) - if (pos.y < 0.0) 1 else 0,
		};
	}

	function getCell(pos:Vec2):GridCell<T> {
		final x = Math.floor(pos.x / cellSize) - if (pos.x < 0.0) 1 else 0;
		final y = Math.floor(pos.y / cellSize) - if (pos.y < 0.0) 1 else 0;

		final i = x + columns * y;
		var cell = grid[i];
		if (cell == null) {
			cell = new GridCell<T>();
			grid[i] = cell;
		}
		return cell;
	}
}

inline function eq<T>(a:T, b:T):Bool {
	return js.Syntax.code("{0} === {1}", a, b);
}

function arrayOfLength<T>(length:Int):Array<T> {
	return js.Syntax.code("Array.from({ length: {0} })", length);
}

typedef CellPos = {x:Int, y:Int};

class GridCell<T> {
	var dirty = false;

	public final items = new Array<T>();

	public function new() {}

	public function add(item:T) {
		dirty = true;
		items.push(item);
	}

	public function remove(value:T) {
		if (items.remove(value)) {
			dirty = true;
		}
	}

	public function forEach(fn:(T) -> Void) {
		for (item in items) {
			fn(item);
		}
	}

	public function resetDirty() {
		dirty = false;
	}
}

inline function forCellsBetween(ul:CellPos, lr:CellPos, fn:(Int, Int) -> Void) {
	var x = ul.x;
	var y = ul.y;
	while (y < lr.y) {
		fn(x, y);
		x += 1;
		if (x == lr.x) {
			x = ul.x;
			y += 1;
		}
	}
}
