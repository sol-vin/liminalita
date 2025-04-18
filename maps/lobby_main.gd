extends Node3D

@export var audio_manager : AudioStreamPlayer

@export var player : Player

func _ready() -> void:
  disable_square_room()
  disable_circle_room()
  enable_square_room()

func enable_square_room():
  print("Enabled Square!")
  $"Inner Square".show()
  $SquareRoomTrigger.set_deferred("monitoring", false)
  for square_child in $"Inner Square".get_children():
    if square_child is StaticBody3D:
      square_child.collision_layer = 1
  if !$"To Atrium Hallway".visible:
    $"Square Arch".show()
  $"TeleportToInfiniteSquareRoom".monitoring = true
  $"TeleportToInfiniteSquareRoomTrap".monitoring = true


func disable_square_room():
  print("Disabled Square!")
  $"Inner Square".hide()
  $SquareRoomTrigger.set_deferred("monitoring", true)
  for square_child in $"Inner Square".get_children():
    if square_child is StaticBody3D:
      square_child.collision_layer = 0
  if !$"To Atrium Hallway".visible:
    $"Square Arch".hide()
  $"TeleportToInfiniteSquareRoom".monitoring = false
  $"TeleportToInfiniteSquareRoomTrap".monitoring = false
  
func enable_circle_room():
  print("Enabled Circle!")
  $"Inner Circle".show()
  $CircleRoomTrigger.set_deferred("monitoring", false)
  for circle_child in $"Inner Circle".get_children():
    if circle_child is StaticBody3D:
      circle_child.collision_layer = 1
  if !$"To Atrium Hallway".visible:
    $"Circle Arch".show()

func disable_circle_room():
  print("Disabled Circle!")
  $"Inner Circle".hide()
  $CircleRoomTrigger.set_deferred("monitoring", true)
  for circle_child in $"Inner Circle".get_children():
    if circle_child is StaticBody3D:
      circle_child.collision_layer = 0
  if !$"To Atrium Hallway".visible:
    $"Circle Arch".hide()

func teleport_to_square_room():
  print("teleport_to_square_room")
  player.teleport_in_relation_to($"References/rectangle_room_flipped", $"References/square_room")
  music_transition_to_02_loop2()

func teleport_to_rectangle_room():
  print("teleport_to_rectangle_room")
  player.teleport_in_relation_to($"References/square_room", $"References/rectangle_room_flipped")
  music_transition_to_02_loop2()

func teleport_to_infinite_square_room_trap(_body : Node3D):
  print("teleport_to_infinite_square_room_trap")
  if player.global_position.x >  $"TeleportToInfiniteSquareRoomTrap".global_position.x:
    $"TeleportToInfiniteSquareRoom".body_exited.connect(on_infinite_square_room_trap_body_exited_lt_x, CONNECT_ONE_SHOT)
  else:
    $"TeleportToInfiniteSquareRoom".body_exited.connect(on_infinite_square_room_trap_body_exited_gt_x, CONNECT_ONE_SHOT)
  player.teleport_in_relation_to($"References/infinite_square_room", $"References/infinite_square_room_trap")
  music_transition_to_02_loop2()

func teleport_to_infinite_square_room(_body : Node3D):
  print("teleport_to_infinite_square_room")
  player.teleport_in_relation_to($"References/infinite_square_room_trap", $"References/infinite_square_room")
  $"TeleportToInfiniteSquareRoomTrap".body_exited.connect(func(_b):
    $"TeleportToInfiniteSquareRoomTrap".body_exited.connect(teleport_to_infinite_square_room_trap, CONNECT_ONE_SHOT)
  , CONNECT_ONE_SHOT)
  music_transition_to_02_loop2()

func on_infinite_square_room_trap_body_exited_lt_x(_body : Node3D):
  print("TeleportToInfiniteSquareRoom.body_exited p<isr")
  if player.global_position.x < $"TeleportToInfiniteSquareRoom".global_position.x:
    teleport_to_infinite_square_room(_body)
  else:
    $"TeleportToInfiniteSquareRoom".body_exited.connect(on_infinite_square_room_trap_body_exited_lt_x, CONNECT_ONE_SHOT)

func on_infinite_square_room_trap_body_exited_gt_x(_body : Node3D):
  print("TeleportToInfiniteSquareRoom.body_exited p>isr")
  if player.global_position.x > $"TeleportToInfiniteSquareRoom".global_position.x:
    teleport_to_infinite_square_room(_body)
  else:
    $"TeleportToInfiniteSquareRoom".body_exited.connect(on_infinite_square_room_trap_body_exited_gt_x, CONNECT_ONE_SHOT)

func music_transition_to_02_loop2():
  if audio_manager.get_stream_playback().get_current_clip_index() == 0:
    audio_manager["parameters/switch_to_clip"] = &"loop2"