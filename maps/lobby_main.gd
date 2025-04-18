extends Node3D

@export var audio_manager : AudioStreamPlayer
@export var player : Player
@export var references : FuncGodotMap

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
  music_transition_to_next()


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
  music_transition_to_next()


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
  player.teleport_in_relation_to(references.get_node("rectangle_room_flipped"), references.get_node("square_room"))

  music_transition_to_next()

func teleport_to_rectangle_room():
  print("teleport_to_rectangle_room")
  player.teleport_in_relation_to(references.get_node("square_room"), references.get_node("rectangle_room_flipped"))
  music_transition_to_next()

func teleport_to_infinite_square_room_trap(_body : Node3D):
  print("teleport_to_infinite_square_room_trap")
  if player.global_position.x >  $"TeleportToInfiniteSquareRoomTrap".global_position.x:
    $"TeleportToInfiniteSquareRoom".body_exited.connect(on_infinite_square_room_trap_body_exited_lt_x, CONNECT_ONE_SHOT)
  else:
    $"TeleportToInfiniteSquareRoom".body_exited.connect(on_infinite_square_room_trap_body_exited_gt_x, CONNECT_ONE_SHOT)
  player.teleport_in_relation_to(references.get_node("infinite_square_room"), references.get_node("infinite_square_room_trap"))
  music_transition_to_next()

func teleport_to_infinite_square_room(_body : Node3D):
  print("teleport_to_infinite_square_room")
  player.teleport_in_relation_to(references.get_node("infinite_square_room_trap"), references.get_node("infinite_square_room"))
  $"TeleportToInfiniteSquareRoomTrap".body_exited.connect(func(_b):
    $"TeleportToInfiniteSquareRoomTrap".body_exited.connect(teleport_to_infinite_square_room_trap, CONNECT_ONE_SHOT)
  , CONNECT_ONE_SHOT)
  music_transition_to_next()

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

func teleport_to_atrium():
  player.teleport_in_relation_to(references.get_node("lobby_to_atrium"), references.get_node("atrium_to_lobby"))

func music_transition_to_next():
  if get_current_audio_clip() == &"01-opening":
    pass
  elif get_current_audio_clip() == &"01-loop1":
    pass
  elif get_current_audio_clip() == &"01-ending":
    pass
  elif get_current_audio_clip() == &"02-loop1":
    audio_manager.get_stream_playback().switch_to_clip_by_name(&"02-loop2")
  elif get_current_audio_clip() == &"02-loop2":
    pass
  elif get_current_audio_clip() == &"03-opening":
    pass
  elif get_current_audio_clip() == &"03-loop1":
    audio_manager.get_stream_playback().switch_to_clip_by_name(&"03-loop2")
  elif get_current_audio_clip() == &"03-loop2":
    pass

func music_transition_to_02():
  audio_manager.get_stream_playback().switch_to_clip_by_name(&"01-ending")


func music_transition_to_03():
  audio_manager.get_stream_playback().switch_to_clip_by_name(&"03-opening")

func music_transition_to_03_loop2():
  audio_manager.get_stream_playback().switch_to_clip_by_name(&"03-loop2")

func get_current_audio_clip():
  return audio_manager.stream.get_clip_name(audio_manager.get_stream_playback().get_current_clip_index())