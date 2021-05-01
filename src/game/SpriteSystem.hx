package game;

import ecs.World;
import h2d.SpriteBatch;
import game.BasicComponents;

class SpriteSystem {
	public function new(parent:h2d.Object) {
		this.parent = parent;
	}

	final parent:h2d.Object;
	final batches = new js.lib.Map<h3d.mat.Texture, SpriteBatch>();

	public function addSprite(entity:Sprite) {
		final tile = entity.sprite.t;
		final tex = tile.getTexture();
		final batch = switch batches.get(tex) {
			case null:
				final batch = new SpriteBatch(tile, parent);
				batch.hasRotationScale = true;
				batches.set(tex, batch);
				batch;
			case b: b;
		};
		batch.add(entity.sprite);
	}

	public function removeSprite(entity:Sprite) {
		entity.sprite.remove();
	}

	public function syncSprites(entities:Entities<Sprite>, delta:Float) {
		entities.forEach(syncEntity);
	}

	function syncEntity(entity:Sprite) {
		entity.sprite.sync(entity.transform);
	}
}

typedef Sprite = {
	> Transform,
	sprite:SpriteElement,
}

class SpriteElement extends h2d.BatchElement {
	public function sync(tx:TransformData) {
		this.x = tx.position.x;
		this.y = tx.position.y;
		this.scaleX = tx.scale.x;
		this.scaleY = tx.scale.y;
		this.rotation = tx.rotation;
	}
}
