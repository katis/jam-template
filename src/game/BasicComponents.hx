package game;

import ecs.World.Entities;

typedef Velocity = {
	velocity:VelocityData,
}

typedef VelocityData = {
	force:Vec2,
	rotation:Float,
}

typedef Transform = {
	transform:TransformData,
}

typedef TransformData = {
	position:Vec2,
	scale:Vec2,
	rotation:Float,
}

function applyVelocity(entities:Entities<{ > Transform, > Velocity,}>, delta:Float) {
	entities.forEach((entity) -> {
		final tx = entity.transform;
		final velocity = entity.velocity;
		tx.position += velocity.force * delta;
		tx.rotation += velocity.rotation * delta;
	});
}
