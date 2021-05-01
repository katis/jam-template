package game;

import js.html.Console;
import ecs.World.Entities;
import game.BasicComponents.Transform;

using game.IteratorExt;

typedef Collidable = {
	> Transform,
	> Collider,
}

typedef Collider = {
	collider:ColliderData,
}

@:allow(game.Grid)
class ColliderData {
	public function new(shape:Shape) {
		this.shape = shape;
	}

	public var shape:Shape;
	public final collisions:Array<Collidable> = [];

	var cellPosition:Null<CellPosition>;
	var cellIndex:Null<CellIndex>;

	public function resetCollisions() {
		collisions.resize(0);
	}
}

enum Shape {
	Circle(radius:Float);
}

function overlaps(a:Collidable, b:Collidable) {
	switch [a.collider.shape, b.collider.shape] {
		case [Circle(ar), Circle(br)]:
			final maxDistance = ar + br;
			return
				a.transform.position.distanceSq(b.transform.position) < (maxDistance * maxDistance);
	}
}

class CollisionSystem {
	public function new(cellSize:Float) {
		grid = new Grid(cellSize);
	}

	final grid:Grid;

	public function addEntity(entity:Collidable) {
		grid.add(entity);
	}

	public function removeEntity(entity:Collidable) {
		grid.remove(entity);
	}

	public function sync(entities:Entities<Collidable>, _:Float) {
		entities.forEach(grid.move);
	}

	public function updateCollisions(entities:Entities<Collidable>, _:Float) {
		entities.forEach(entity -> {
			for (other in grid.queryAround(entity.transform.position, 128)) {
				if (other != entity && overlaps(entity, other)) {
					entity.collider.collisions.push(other);
				}
			}
		});
	}

	public function clearCollisions(entities:Entities<Collidable>, _:Float) {
		entities.forEach(clearCollisionArray);
	}

	static function clearCollisionArray(entity:Collidable) {
		entity.collider.resetCollisions();
	}
}

class Grid {
	public function new(cellSize:Float) {
		this.cellSize = cellSize;
		grid = new Map();
	}

	final cellSize:Float;
	final grid:Map<CellPosition, GridCell<Collidable>>;

	public inline function queryRaw(ll:Vec2, ur:Vec2) {
		final pa = cellPoint(ll);
		final pb = cellPoint(ur);

		final empty = [];

		return new GridIterator(pa.x, pa.y, pb.x, pb.y)
			.flatMap(p -> {
				return switch (grid.get(p)) {
					case null: empty;
					case cell: cell.items;
				};
			});
	}

	public inline function queryAround(pos:Vec2, radius:Float):Iterator<Collidable> {
		final ll = new Vec2(pos.x - radius, pos.y - radius);
		final ur = new Vec2(pos.x + radius, pos.y + radius);

		final radius2 = radius * radius;
		return queryRaw(ll, ur)
			.filter(c -> {
				final v = c.transform.position - pos;
				return v.lengthSq() < radius2;
			});
	}

	public inline function get(position:CellPosition) {
		return grid.get(position);
	}

	public function add(collidable:Collidable) {
		final cell = new CellPosition(collidable.transform.position, cellSize);
		addToCell(cell, collidable);
	}

	public function remove(collidable:Collidable) {
		removeFromCell(collidable);
	}

	public function move(collidable:Collidable) {
		final cell = new CellPosition(collidable.transform.position, cellSize);
		removeFromCell(collidable);
		addToCell(cell, collidable);
	}

	function addToCell(pos:CellPosition, collidable:Collidable) {
		final cell = gridCell(pos);
		final idx = cell.add(collidable);
		collidable.collider.cellPosition = pos;
		collidable.collider.cellIndex = idx;
	}

	function removeFromCell(collidable:Collidable) {
		final collider = collidable.collider;
		final cell = grid.get(collider.cellPosition);
		cell.removeAt(collider.cellIndex);
		collider.cellPosition = null;
		collider.cellIndex = null;
	}

	function gridCell(cell:CellPosition):GridCell<Collidable> {
		return switch grid.get(cell) {
			case null:
				final gridCell = new GridCell();
				grid.set(cell, gridCell);
				gridCell;
			case items: items;
		}
	}

	function cellPoint(pos:Vec2) {
		return new IntPoint(Math.floor(pos.x / cellSize) - if (pos.x < 0.0) 1 else 0,
			Math.floor(pos.y / cellSize) - if (pos.y < 0.0) 1 else 0);
	}
}

@:allow(game.Grid)
class GridCell<T> {
	var dirty = false;
	final items:Array<T> = [];

	function new() {}

	function add(value:T) {
		final i = items.push(value) - 1;
		dirty = true;
		return new CellIndex(i);
	}

	function removeAt(position:CellIndex) {
		items.splice(position, 1);
		dirty = true;
	}

	function remove(value:T) {
		if (items.remove(value)) {
			dirty = true;
		}
	}

	function resetDirty() {
		dirty = false;
	}
}

abstract CellIndex(Int) to Int {
	@:allow(game.GridCell)
	inline function new(index:Int) {
		this = index;
	}
}

private abstract CellPosition(Int) {
	public inline function new(pos:Vec2, cellSize:Float) {
		final x = Math.floor(pos.x / cellSize) - if (pos.x < 0.0) 1 else 0;
		final y = Math.floor(pos.y / cellSize) - if (pos.y < 0.0) 1 else 0;

		// hash code
		this = 31 * x + y;
	}
}

@:forward(x, y)
private abstract IntPoint({x:Int, y:Int}) {
	public inline function new(x:Int, y:Int) {
		this = {x: x, y: y};
	}

	public function hashCode() {
		return 31 * this.x + this.y;
	}
}

class GridIterator {
	public inline function new(x1:Int, y1:Int, x2:Int, y2:Int) {
		this.x1 = x1;
		this.x2 = x2 + 1;
		this.y2 = y2 + 1;
		x = x1;
		y = y1;
	}

	final x1:Int;
	final x2:Int;
	final y2:Int;
	var x:Int;
	var y:Int;

	public inline function hasNext() {
		return y < y2;
	}

	public inline function next() {
		final value = cast(31 * x + y, CellPosition);
		x += 1;
		if (x == x2) {
			x = x1;
			y += 1;
		}
		return value;
	}
}
