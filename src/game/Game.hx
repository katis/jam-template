package game;

import game.CollisionSystem;
import game.RingSystem;
import game.BasicComponents;
import game.Vec2;
import ecs.World;
import game.SpriteSystem;

typedef Ball = Sprite & Velocity & Collidable;

class Game extends hxd.App {
	final world = new World();
	final balls = new EntitySet<Ball>();
	final rings = new EntitySet<Ring>();
	final map = new Grid(128);
	var tf:h2d.Text;

	override public function init() {
		this.tf = new h2d.Text(hxd.res.DefaultFont.get(), s2d);

		// Create systems
		final collisionSystem = new CollisionSystem(256);
		final spriteSystem = new SpriteSystem(s2d);
		final ringSystem = new RingSystem(hxd.Res.images.ringPart
			.toTile()
			.center(), s2d);

		// Entity groups, with add/remove callbacks:
		final movement = new Entities<Transform & Velocity>(world, [balls, rings]);
		final collidable = new Entities<Collidable>(world,
			[balls])
			.onAdd(collisionSystem.addEntity)
			.onRemove(collisionSystem.removeEntity);
		final sprites = new Entities(world,
			[balls])
			.onAdd(spriteSystem.addSprite)
			.onRemove(spriteSystem.removeSprite);
		final rings = new Entities(world,
			[rings])
			.onAdd(ringSystem.addRing)
			.onRemove(ringSystem.removeRing);

		// Run order of system functions:
		collidable.run(collisionSystem.clearCollisions);
		movement.run(applyVelocity);
		collidable.run(collisionSystem.sync);
		collidable.run(collisionSystem.updateCollisions);
		sprites.run(colorizeCollider);
		sprites.run(spriteSystem.syncSprites);
		rings.run(ringSystem.update);

		initEntities();
	}

	function initEntities() {
		final playerTile = hxd.Res.images.player.toTile();
		for (_ in 0...1000) {
			balls.add({
				sprite: new SpriteElement(playerTile),
				transform: {
					position: Random.vec2(100, 900, 100, 900),
					scale: Vec2.one(),
					rotation: 0.0,
				},
				velocity: {
					force: Random.vec2(30, 100, 30, 101),
					rotation: 0.0,
				},
				collider: new ColliderData(Circle(playerTile.width / 2)),
			});
		}

		for (_ in 0...5) {
			rings.add({
				transform: {
					position: Random.vec2(100, 900, 100, 900),
					scale: Vec2.one(),
					rotation: 1.0,
				},
				ring: {
					circle: new Circle(Random.between(150, 240)),
					batch: null,
				},
				velocity: {
					force: Vec2.zero(),
					rotation: Random.between(-1.4, 1.4),
				},
			});
		}
	}

	override function update(delta:Float) {
		final fps = hxd.Math.floor(1.0 / delta);
		tf.text = '$fps';
		world.processAdded();
		world.update(delta);
		world.processRemoved();
	}
}

function colorizeCollider(entities:Entities<Ball>, _:Float) {
	entities.forEach(ball -> {
		final a = if (ball.collider.collisions.length > 0) 0.5 else 1.0;
		ball.sprite.a = a;
	});
}
