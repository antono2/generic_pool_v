/*
The idea here is to have a generic parameter initialization function init(args []Object)
for each game actor, which then can be used in a generic Object Pool.
Pool manages the number of instaces.
IActor or the inheriting ILuminousActor can be initialized and used in a pool this way.
GameObject sum type needs to contain all init parameters.
Another sum type DrawParam is used for the generic draw([]DrawParam),
where in order to draw some objects they need some specific parameters;
maybe one draw requires the Screen resolution, where others need to draw letters.
This is an example implementation with only the most basic operations for IActor.
You could imagine any number of awesome functions working with IActor. HF.
*/


module main

interface IActor {
mut:
  exists bool
  init([]GameObject)
  print_info()
  draw([]DrawParam)
}

// This interface is never used, but shows support for
// Interface Inheritance
interface ILuminousActor {
  IActor
mut:
  special_luminous_function()
}

pub struct ActorParam1 {
pub mut:
  some_int int
}

pub struct ActorParam2 {
pub mut:
  some_float f32
}

pub type GameObject = ActorParam1 | ActorParam2

pub struct Screen {
pub mut:
  number_of_screens int = 2
}

pub struct FloatLetter {
pub mut:
  letters_str string = "So many floating Letters!"
}

pub type DrawParam = Screen | FloatLetter

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

pub fn (a LuminousActor) special_luminous_function() {
  println("The special Luminous Actor function was called.")
}

pub fn (a Actor1) draw(params []DrawParam) {
  for param in params {
    // Besides `match` you can also use `if` to check the param type
    if param is Screen {
      println("Drawing Actor1 with Screen Param")
      //my_screen := param as Screen
    }
  } 
}

pub fn (a Actor2) draw(params []DrawParam) {
  for param in params {
    if param is FloatLetter {
      println("Drawing Actor2 with FloatLetter Param")
      //my_float_letter := param as FloatLetter
    }
  } 
}

pub fn (a LuminousActor) draw(params []DrawParam) {
  for param in params {
    if param is Screen {
      println("Drawing LuminousActor with Screen Param")
      //my_screen := param as Screen
    }
  } 
}

// You can use structs before they are defined,
// as long as they are defined somewhere.
pub  struct Game {
pub mut:
  actor_pool1 ActorPool[Actor1]
  actor_pool2 ActorPool[Actor2]
  luminous_actor_pool ActorPool[LuminousActor]
}

/*
  Actor Pool manages initialization and number of Game Objects
*/
pub struct ActorPool[T] {
mut:
  actor_idx int
pub mut:
  actors []T
}

pub fn (mut ap ActorPool[T]) new[T](n int, args []GameObject) {
  ap.create_actors[T](n, args)
}

pub fn (mut ap ActorPool[T]) create_actors[T](n int, args []GameObject) {
  ap.actors = []T{len: n}
  for i in 0..ap.actors.len {
    ap.actors[i] = T{}
    ap.actors[i].init(args)
  }
  ap.actor_idx = 0
}

pub fn (mut ap ActorPool[T]) get_instance() ?&T {
  for _ in 0..ap.actors.len {
    ap.actor_idx--
    if ap.actor_idx < 0 {
      ap.actor_idx = ap.actors.len - 1
    }
    if !ap.actors[ap.actor_idx].exists {
      return &ap.actors[ap.actor_idx]
    }
  }
  return none
}

pub fn (mut ap ActorPool[T]) draw(params []DrawParam) {
  for i in 0..ap.actors.len {
    if ap.actors[i].exists {
      ap.actors[i].draw(params)
    }
  }
}

pub fn (mut ap ActorPool[T]) print_info() {
  for i in 0..ap.actors.len {
    ap.actors[i].print_info()
  }
}

pub fn (mut ap ActorPool[T]) clear() {
  for i in 0..ap.actors.len {
    ap.actors[i].exists = false
  }
  ap.actor_idx = 0
}

pub fn (ap ActorPool[LuminousActor]) pool_special_luminous_function() {
  for i in 0..ap.actors.len {
    ap.actors[i].special_luminous_function()
  }
}

/*
  Test implementation
*/
pub fn main() {
  mut game := Game{}
  println("PRE INIT") 
  // As the number of instances of actor is 0,
  // this won't print anything yet.
  game.actor_pool1.print_info()
  game.actor_pool2.print_info()
  game.luminous_actor_pool.print_info()
  println("POST INIT")
  mut args1 := []GameObject{}
  mut args2 := []GameObject{}
  args1_param := ActorParam1{ some_int: 9001 }
  args2_param := ActorParam2{ some_float: f32(0.2) }
  args1 << args1_param
  args2 << args2_param
  // After calling new(..), the actor pool will contain
  // 1 instace of the actor initialized with the given parameters, args.
  game.actor_pool1.new(1, args1)
  game.actor_pool2.new(1, args2)
  game.luminous_actor_pool.new(1, args1)
  // pool.print_info() iterates over all instances and prints their info.
  game.actor_pool1.print_info()
  game.actor_pool2.print_info()
  game.luminous_actor_pool.print_info()
  mut actor1_pool_item := game.actor_pool1.get_instance() or { panic("Couldn't get an instance of Actor1, where exists = false.") }
  mut actor2_pool_item := game.actor_pool2.get_instance() or { panic("Couldn't get an instance of Actor2, where exists = false.") }
  mut actor3_pool_item := game.luminous_actor_pool.get_instance() or { panic("Couldn't get an instance of LuminousActor, where exists = false.") }
  println("ACTOR POOL INSTANCE")
  // The same print out as before,
  // as the pools each only contain 1 actor.
  actor1_pool_item.print_info()
  actor2_pool_item.print_info()
  actor3_pool_item.print_info()
  // Here we simulate the actor being used
  // and somehow existing in the game world.
  actor1_pool_item.exists = true
  actor2_pool_item.exists = true
  actor3_pool_item.exists = true
  println("PRE CLEAR")
  actor1_pool_item.print_info()
  actor2_pool_item.print_info()
  actor3_pool_item.print_info()
  println("DRAW WITH CUSTOMIZED PARAMS")
  // Draw requires the actor to exist (exists=true),
  // so we draw before clear.
  // Also, you can pass parameters directly - other than the example above with args1 -
  // you can wrap the parameter with [DrawParam(param)],
  // which casts the param to sum type DrawParam and puts it in an array.
  game.actor_pool1.draw([DrawParam(Screen{})])
  game.actor_pool2.draw([DrawParam(FloatLetter{})])
  game.luminous_actor_pool.draw([DrawParam(Screen{})])
  // Clear simply sets each actor.exists = false
  game.actor_pool1.clear()
  game.actor_pool2.clear()
  game.luminous_actor_pool.clear()
  println("AFTER CLEAR")
  game.actor_pool1.print_info()
  game.actor_pool2.print_info()
  game.luminous_actor_pool.print_info()
  // To finish, lets call a function which only the Luminous Actor has
  actor3_pool_item.special_luminous_function()
  // Also works from the pool
  game.luminous_actor_pool.pool_special_luminous_function()
}
