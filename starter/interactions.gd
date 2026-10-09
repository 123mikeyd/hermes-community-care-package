extends Node3D
# Small original teaching example; no combat, inventory, save file or driving.
const REACH=1.6
var host
var token:Node3D
var collected=false
var pickup_count=0
var message=""
var prompt:Label
var checkpoint:Node3D
var display:Node3D
var checkpoint_active=false
var respawn_position:Vector3
var checkpoint_material:StandardMaterial3D

func _ready():
	host=get_parent()
	prompt=Label.new();prompt.position=Vector2(24,78)
	prompt.add_theme_color_override("font_outline_color",Color.BLACK)
	prompt.add_theme_constant_override("outline_size",5)
	var canvas=CanvasLayer.new();add_child(canvas);canvas.add_child(prompt)
	await host.frames(3)
	token=Node3D.new();token.name="OriginalNousToken";add_child(token)
	token.position=host.CENTER+Vector3(-2,0,-2)
	token.position.y=host.ground_y(token.position.x,token.position.z)
	var mesh=MeshInstance3D.new();var shape=CylinderMesh.new()
	shape.top_radius=0.32;shape.bottom_radius=0.32;shape.height=0.10
	mesh.mesh=shape;mesh.rotation.x=PI/2;mesh.position.y=0.95;token.add_child(mesh)
	var mat=StandardMaterial3D.new();mat.albedo_color=Color("42e0ce");mat.metallic=0.2;mesh.material_override=mat
	var label=Label3D.new();label.text="NOUS";label.font_size=46;label.pixel_size=0.008;label.position=Vector3(0,1.5,0);label.billboard=BaseMaterial3D.BILLBOARD_ENABLED;token.add_child(label)
	checkpoint=Node3D.new();checkpoint.name="CheckpointBeacon";add_child(checkpoint)
	checkpoint.position=host.CENTER+Vector3(2,0,-2);checkpoint.position.y=host.ground_y(checkpoint.position.x,checkpoint.position.z)
	var beacon=MeshInstance3D.new();var pillar=CylinderMesh.new();pillar.top_radius=0.12;pillar.bottom_radius=0.3;pillar.height=1.2
	beacon.mesh=pillar;beacon.position.y=0.6;checkpoint.add_child(beacon)
	checkpoint_material=StandardMaterial3D.new();checkpoint_material.albedo_color=Color("f2b454");beacon.material_override=checkpoint_material
	var cp_label=Label3D.new();cp_label.text="CHECKPOINT";cp_label.font_size=32;cp_label.position.y=1.65;cp_label.billboard=BaseMaterial3D.BILLBOARD_ENABLED;checkpoint.add_child(cp_label)
	display=load("res://assets/teknium/laser/laser_gun.tscn").instantiate();display.name="TekniumGunDisplay";add_child(display)
	display.position=host.CENTER+Vector3(-4,0,1);display.position.y=host.ground_y(display.position.x,display.position.z)
	# The installed scene's original hand mount uses centimetre-scale transforms.
	# Display its actual mesh at native mesh scale, not the fighter's attachment transform.
	var gun:MeshInstance3D=display.get_node("GunMesh");gun.transform=Transform3D.IDENTITY;gun.position.y=1.2
	for i in gun.mesh.get_surface_count():
		var gun_mat=gun.get_active_material(i).duplicate();gun_mat.metallic=0.15;gun_mat.roughness=0.6;gun.set_surface_override_material(i,gun_mat)
	var gun_label=Label3D.new();gun_label.text="TEKNIUM LASER GUN / DISPLAY ONLY";gun_label.font_size=26;gun_label.position.y=2.5;gun_label.billboard=BaseMaterial3D.BILLBOARD_ENABLED;display.add_child(gun_label)
	respawn_position=host.SPAWN

func nearest()->String:
	var best=REACH;var result=""
	for pair in [["token",token],["checkpoint",checkpoint],["display",display]]:
		if pair[1]==null or (pair[0]=="token" and collected):continue
		var distance:float=host.player.position.distance_to(pair[1].position)
		if distance<=best:best=distance;result=pair[0]
	return result

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_F:restart()
		if event.keycode==KEY_E:
			match nearest():
				"token":
					collected=true;pickup_count+=1;token.visible=false;message="Nous token collected (1 / 1)."
				"checkpoint":
					checkpoint_active=true;respawn_position=checkpoint.position;checkpoint_material.albedo_color=Color("56eea0");message="Checkpoint set. R returns here; F restarts everything."
				"display":message="Teknium laser gun: recovered display prop. No firing or combat."

func restart():
	collected=false;pickup_count=0;checkpoint_active=false;message=""
	if token:token.visible=true
	if checkpoint_material:checkpoint_material.albedo_color=Color("f2b454")
	respawn_position=host.SPAWN;host.reset_player()

func _process(_dt):
	if token:
		var target=nearest()
		var hints={"token":"E: collect Nous token", "checkpoint":"E: set checkpoint", "display":"E: inspect laser gun", "":message}
		prompt.text=hints[target]+("\n"+message if target!="" and not message.is_empty() else "")
		prompt.visible=not host.help.visible
