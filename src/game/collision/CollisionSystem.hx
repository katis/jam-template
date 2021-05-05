package game.collision;

import game.collision.Shape.overlaps;
import ecs.World.Entities;
import game.collision.Grid.GridCell;
import game.BasicComponents;

typedef Collidable = Transform & Collider;

typedef Collider = {
	collider:ColliderData,
}

class ColliderData {
	public function new(shape:Shape) {
		this.shape = shape;
	}

	public var shape:Shape;
	public final collisions:Array<Collidable> = [];
	public var cell:Null<GridCell<Collidable>> = null;

	public function resetCollisions() {
		collisions.resize(0);
	}
}

class CollisionSystem {
	public function new(parent:h2d.Object, cellSize:Float, columns:Int, rows:Int) {
		grid = new Grid(cellSize, columns, rows);
		debug = new h2d.Graphics(parent);
		this.cellSize = cellSize;
		this.columns = columns;
		this.rows = rows;

		debug.lineStyle(1, 0x00aa00);
		for (c in 0...columns) {
			for (r in 0...rows) {
				final x = c * cellSize;
				final y = r * cellSize;
				debug.drawRect(x, y, cellSize, cellSize);
			}
		}
	}

	final cellSize:Float;
	final columns:Int;
	final rows:Int;
	final grid:Grid<Collidable>;
	final debug:h2d.Graphics;

	public function addEntity(entity:Collidable) {
		final cell = grid.add(entity.transform.position, entity);
		entity.collider.cell = cell;
	}

	public function removeEntity(entity:Collidable) {
		entity.collider.cell.remove(entity);
		entity.collider.cell = null;
	}

	public function sync(entities:Entities<Collidable>, _:Float) {
		entities.forEach((entity) -> {
			entity.collider.cell = grid.move(entity.transform.position, entity.collider.cell,
				entity);
		});
	}

	public function updateCollisions(entities:Entities<Collidable>, _:Float) {
		entities.forEach(entity -> {
			queryAround(entity.transform.position, 128, other -> {
				if (other != entity && overlaps(entity, other)) {
					entity.collider.collisions.push(other);
				}
			});
		});
	}

	function queryAround(pos:Vec2, radius:Float, fn:(Collidable) -> Void) {
		final ul = new Vec2(pos.x - radius, pos.y - radius);
		final lr = new Vec2(pos.x + radius, pos.y + radius);

		final radius2 = radius * radius;

		return grid.queryRaw(ul, lr, entity -> {
			final v = entity.transform.position - pos;
			if (v.lengthSq() < radius2) {
				fn(entity);
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
