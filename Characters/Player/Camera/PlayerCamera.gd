extends Camera2D

func _ready():
	# This script is used to set the remote path of the player's RemoteTransform2D
	# so that the player's position is synced across the nodes.
	var playerRemoteTransform2d = get_tree().current_scene.get_node("Player/RemoteTransform2D");
	playerRemoteTransform2d.remote_path = get_path();
