/*
The idea here is to have a generic initialization function init(args []Object),
which then can be used in a generic Object Pool. Pool manages the number of instaces.
IActor can be initialized this way.
GameObject sum type is used for casting Objects around.
*/

/* 
Chewing Bever — Today at 9:20 PM
so indeed moving the contents of create_actors<T> to the main function & removing the type parameter entirely allows the code to compile
I've yet to find the actual cause for the error though, it's very strange
*/

module main

interface IActor {
mut:
  exists bool
  init([]GameObject)
  print_info()
}

interface ILuminousActor {
  IActor
mut:
  draw_luminous()
}

pub struct ActorParam1 {
pub mut:
  some_int int = 9000
}

pub struct ActorParam2 {
pub mut:
  some_float f32 = f32(0.1)
}

pub type GameObject = ActorParam1 | ActorParam2

pub struct Actor1 {
pub mut:
  exists bool
  name string = "Actor1"
  param1 ActorParam1
}

pub struct Actor2 {
pub mut:
  exists bool
  name string = "Actor2"
  param2 ActorParam2
}

pub struct LuminousActor {
pub mut:
  exists bool
  name string = "LuminousActor"
  param1 ActorParam1
}

pub fn (mut a Actor1) init(args []GameObject) {
  for i in 0..args.len {
    match args[i] {
      ActorParam1 { 
        a.param1 = args[i] as ActorParam1 
      }
      else {}
    }
  }
}

pub fn (mut a Actor2) init(args []GameObject) {
  for i in 0..args.len {
    match args[i] {
      ActorParam2 { 
        a.param2 = args[i] as ActorParam2
      }
      else {}
    }
  }
}

pub fn (mut a LuminousActor) init(args []GameObject) {
  for i in 0..args.len {
    match args[i] {
      ActorParam1 { 
        a.param1 = args[i] as ActorParam1
      }
      else {}
    }
  }
}

pub fn (a Actor1) print_info() {
  println("Name: $a.name Param: $a.param1.some_int Exists: $a.exists")
}

pub fn (a Actor2) print_info() {
  println("Name: $a.name Param: $a.param2.some_float Exists: $a.exists")
}

pub fn (a LuminousActor) print_info() {
  println("Name: $a.name Param: $a.param1.some_int Exists: $a.exists")
}

pub fn (a LuminousActor) draw_luminous() {
  println("Drawing Luminous Actor")
}

pub  struct Game {
pub mut:
  actor1 Actor1
  actor2 Actor2
}

/*
  Actor Pool manages initialization and number of Game Objects
*/
pub struct ActorPool<T> {
mut:
  actor_idx int
pub mut:
  actors []T
}

pub fn (mut ap ActorPool<T>) new<T>(n int, args []GameObject) {
  ap.create_actors<T>(n, args)
}

pub fn (mut ap ActorPool<T>) create_actors<T>(n int, args []GameObject) {
  ap.actors = []T{len: n}
  for i in 0..ap.actors.len {
    ap.actors[i] = T{}
    ap.actors[i].init(args)
  }
  ap.actor_idx = 0
}

pub fn (mut ap ActorPool<T>) get_instance() ?T {
  for _ in 0..ap.actors.len {
    ap.actor_idx--
    if ap.actor_idx < 0 {
      ap.actor_idx = ap.actors.len - 1
    }
    if !ap.actors[ap.actor_idx].exists {
      return ap.actors[ap.actor_idx]
    }
  }
  return none
}

pub fn (mut ap ActorPool<T>) clear() {
  for i in 0..ap.actors.len {
    ap.actors[i].exists = false
  }
  ap.actor_idx = 0
}

/*
  Test implementation
*/
pub fn main() {
  mut game := Game{}
  println("PRE INIT")
  game.actor1.print_info()
  game.actor2.print_info()
  mut args1 := []GameObject{}
  mut args2 := []GameObject{}
  args1_param := ActorParam1{ some_int: 9001 }
  args2_param := ActorParam2{ some_float: f32(0.2) }
  args1 << args1_param
  args2 << args2_param
  game.actor1.init(args1)
  game.actor2.init(args2)
  println("POST INIT")
  game.actor1.print_info()
  game.actor2.print_info()

  mut pool1 := ActorPool<Actor1>{}
  mut pool2 := ActorPool<Actor2>{}
  mut pool3 := ActorPool<LuminousActor>{}
  mut new_args1 := [args1[0] as ActorParam1]
  mut new_args2 := [args2[0] as ActorParam2]
  mut new_args3 := [args1[0] as ActorParam1]
  new_args1[0].some_int = 9002
  new_new_args1 := [GameObject(new_args1[0])]
  new_args2[0].some_float = f32(0.3)
  new_new_args2 := [GameObject(new_args2[0])]
  new_args3[0].some_int = 111
  new_new_args3 := [GameObject(new_args3[0])]
  pool1.new<Actor1>(1, new_new_args1) //I'd like to use []GameObject(new_args1) instead, or better no cast at all
  pool2.new<Actor2>(1, new_new_args2)
  pool3.new<LuminousActor>(1, new_new_args3)
  
  mut created_actor1 := pool1.get_instance() or { panic("Couldn't get an instance of Actor1, where exists = false.") }
  mut created_actor2 := pool2.get_instance() or { panic("Couldn't get an instance of Actor2, where exists = false.") }
  mut created_actor3 := pool3.get_instance() or { panic("Couldn't get an instance of LuminousActor, where exists = false.") }

  println("ACTOR POOL INSTANCE")
  created_actor1.print_info()
  created_actor2.print_info()
  created_actor3.print_info()
  created_actor1.exists = true
  created_actor2.exists = true
  created_actor3.exists = true
  println("PRE CLEAR")
  created_actor1.print_info()
  created_actor2.print_info()
  created_actor3.print_info()
  pool1.clear<IActor>()
  pool2.clear<IActor>()
  pool3.clear<ILuminousActor>()
  created_actor1 = pool1.get_instance() or { panic("Couldn't get an instance of Actor1, where exists = false.") }
  created_actor2 = pool2.get_instance() or { panic("Couldn't get an instance of Actor2, where exists = false.") }
  created_actor3 = pool3.get_instance() or { panic("Couldn't get an instance of LuminousActor, where exists = false.") }
  println("AFTER CLEAR")
  created_actor1.print_info()
  created_actor2.print_info()
  created_actor3.print_info()
}