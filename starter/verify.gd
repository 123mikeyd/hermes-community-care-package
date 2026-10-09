extends SceneTree
func _initialize():
	if not FileAccess.file_exists("res://Main.tscn"):
		print("RED: missing playable scene")
		quit(1)
		return
	var scene=load("res://Main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	if not scene.has_method("verify"):
		print("FAIL: missing runtime contract")
		quit(1)
		return
	await scene.verify(false)
