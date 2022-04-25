# generic_pool_v
The idea here is to have a generic parameter initialization function init(args []Object)
for each game actor, which then can be used in a generic Object Pool.
Pool manages the number of instaces.
IActor or the inheriting ILuminousActor can be initialized and used in a pool this way.
GameObject sum type needs to contain all init parameters.
