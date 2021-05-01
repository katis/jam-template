package game;

import h2d.filter.Outline;
import ecs.World;
import game.BasicComponents;
import hxd.Math;
import h2d.Object;
import h2d.Tile;
import h2d.SpriteBatch;

typedef Ring = {
	> Transform,
	> Velocity,
	ring:RingData,
}

typedef RingData = {
	circle:Circle,
	batch:SpriteBatch,
}

class RingSystem {
	public function new(tile:Tile, parent:Object) {
		this.tile = tile;
		this.parent = parent;
	}

	final tile:Tile;
	final parent:Object;

	public function addRing(entity:Ring) {
		final tx = entity.transform;
		final circle = entity.ring.circle;

		final batch = new h2d.SpriteBatch(tile, parent);
		batch.filter = new Outline(3, 0xccff00);
		batch.hasRotationScale = true;
		batch.x = tx.position.x;
		batch.y = tx.position.y;

		final segments = Math.floor(circle.circumference() / tile.width);

		for (seg in 0...segments) {
			final angle = TAU * (seg / segments);
			final pos = circle.pointOn(angle);
			final el = batch.alloc(tile);
			el.x = pos.x;
			el.y = pos.y;
			el.rotation = if (entity.velocity.rotation > 0) angle - Math.PI else angle;
		}

		entity.ring.batch = batch;
	}

	public function update(entities:Entities<Ring>, delta:Float) {
		entities.forEach(updateRing);
	}

	function updateRing(entity:Ring) {
		entity.ring.batch.rotation = entity.transform.rotation;
	}

	public function removeRing(entity:Ring) {
		entity.ring.batch.clear();
		entity.ring.batch = null;
	}
}

abstract Circle(Float) {
	public inline function new(radius:Float) {
		this = radius;
	}

	public inline function circumference():Float {
		return this * TAU;
	}

	public inline function radius():Float {
		return this;
	}

	public inline function pointOn(angleRad:Float) {
		return new Vec2(this * hxd.Math.cos(angleRad), this * hxd.Math.sin(angleRad));
	}
}

final TAU = Math.PI * 2.0;
