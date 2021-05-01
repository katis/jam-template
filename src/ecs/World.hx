package ecs;

import js.lib.Set;

class World {
	public function new() {}

	final groups:Array<Entities<Dynamic>> = [];
	final systems:Array<(Float) -> Void> = [];

	public function processAdded() {
		for (group in groups) {
			group.processAdded();
		}
	}

	public function processRemoved() {
		for (group in groups) {
			group.processRemoved();
		}
	}

	public function update(delta:Float) {
		for (execute in systems) {
			execute(delta);
		}
	}

	@:allow(ecs.Entities)
	function executeSystem(execute:(Float) -> Void) {
		systems.push(execute);
	}

	@:allow(ecs.Entities)
	public function addEntities<E>(entities:Entities<E>) {
		groups.push(entities);
	}
}

class Entities<E> {
	public function new(world:World, entitySets:Array<EntitySet<E>>) {
		this.world = world;
		world.addEntities(this);
		this.entitySets = entitySets;
		for (set in entitySets) {
			set.addOwner(this);
		}
	}

	final world:World;
	final entitySets:Array<EntitySet<E>>;
	final addListeners:Array<Listener<E>> = [];
	final removeListeners:Array<Listener<E>> = [];

	public function onAdd(listener:Listener<E>):Entities<E> {
		addListeners.push(listener);
		return this;
	}

	public function onRemove(listener:Listener<E>):Entities<E> {
		removeListeners.push(listener);
		return this;
	}

	@:allow(ecs.EntitySet)
	function added(entity:E) {
		for (listeners in addListeners) {
			listeners(entity);
		}
	}

	@:allow(ecs.EntitySet)
	function removed(entity:E) {
		for (listeners in removeListeners) {
			listeners(entity);
		}
	}

	public function run(system:System<E>):Entities<E> {
		world.executeSystem((delta) -> {
			system(this, delta);
		});
		return this;
	}

	@:allow(ecs.World)
	function processAdded() {
		for (entities in entitySets) {
			entities.processAdded();
		}
	}

	@:allow(ecs.World)
	function processRemoved() {
		for (entities in entitySets) {
			entities.processRemoved();
		}
	}

	public function forEach(cb:(E) -> Void) {
		for (entities in entitySets) {
			entities.forEach(cb);
		}
	}

	public inline function iterator():Iterator<E> {
		return new EntitySetsIterator(entitySets);
	}
}

class EntitySetsIterator<T> {
	final array:Array<EntitySet<T>>;
	var i = 0;
	var iter:Iterator<T>;

	public inline function new(array:Array<EntitySet<T>>) {
		this.array = array;
	}

	public inline function hasNext():Bool {
		if (iter == null) {
			if (i >= array.length - 1) {
				return false;
			}

			iter = array[i].iterator();
			i++;
			return hasNext();
		}
		final has = iter.hasNext();
		if (!has) {
			iter = null;
			return hasNext();
		}
		return true;
	}

	public inline function next():T {
		return iter.next();
	}
}

typedef System<E> = (Entities<E>, Float) -> Void;
typedef Listener<E> = (E) -> Void;

@:allow(ecs.Entities)
class EntitySet<E> {
	public function new() {}

	final entities = new Set<E>();
	final added = new Array<E>();
	final removed = new Array<E>();
	final owners = new Array<Entities<E>>();

	function processAdded() {
		for (entity in added) {
			entities.add(entity);
			for (owner in owners) {
				owner.added(entity);
			}
		}
		added.resize(0);
	}

	function processRemoved() {
		for (entity in removed) {
			if (entities.delete(entity)) {
				for (owner in owners) {
					owner.removed(entity);
				}
			}
		}
		removed.resize(0);
	}

	@:allow(ecs.Entities)
	function addOwner(owner:Entities<E>) {
		owners.push(owner);
	}

	public function add(entity:E) {
		added.push(entity);
	}

	public function remove(entity:E) {
		removed.push(entity);
	}

	public function forEach(cb:(E) -> Void):Void {
		entities.forEach((entity, _, _) -> cb(entity));
	}

	public inline function iterator() {
		return entities.iterator();
	}
}
