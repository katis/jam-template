package game.collision;

import game.collision.CollisionSystem;

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
