extends Node3D
# Community learning prototype; see the package NOTICE for sharing scope.
# Natural source terrain is unmodified. Build settings are editable below.
const CENTER=Vector3(-9,0,-53)
const RADIUS=10.0
const SPAWN=Vector3(-9,8,-53)
const BLEND=0.18
var calibration=JSON.parse_string(FileAccess.get_file_as_string("res://calibration.json"))
var actors={}
var active_id="tek"
var player:CharacterBody3D
var camera:Camera3D
var status:Label
var help:PanelContainer
var clip="Idle"
var angle=PI
var distance=7.5
var blend_time=1.0
var blend_from=0.0
var blend_to=0.0
var reset_count=0
var results=[]
var evidence_dir=""
var testing=false
var car:Node3D

func _ready():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--evidence="): evidence_dir=arg.trim_prefix("--evidence=")
	for pair in [["left",KEY_A],["right",KEY_D],["forward",KEY_W],["back",KEY_S],["run",KEY_SHIFT],["orbit_left",KEY_Q],["orbit_right",KEY_C]]:
		if not InputMap.has_action(pair[0]): InputMap.add_action(pair[0])
		var ev=InputEventKey.new();ev.physical_keycode=pair[1];InputMap.action_add_event(pair[0],ev)
	make_environment()
	var terrain=get_node("OriginalMistyMountain")
	for mesh in terrain.find_children("*","MeshInstance3D",true,false):
		mesh.create_trimesh_collision()
		for i in mesh.mesh.get_surface_count():
			var mat=mesh.get_active_material(i)
			if mat is StandardMaterial3D:
				mat=mat.duplicate();mat.roughness=0.95;mat.metallic=0;mesh.set_surface_override_material(i,mat)
	make_boundary()
	car=get_node("FZeroCarProp")
	var cb=StaticBody3D.new();cb.name="CarCollision";cb.collision_layer=4;cb.position=car.position;add_child(cb)
	var cs=CollisionShape3D.new();var box=BoxShape3D.new();box.size=Vector3(4,2,3.8);cs.shape=box;cb.add_child(cs)
	spawn("tek");spawn("doge");select_character("tek")
	camera=Camera3D.new();camera.name="FollowCamera";camera.fov=52;camera.far=500;add_child(camera);camera.current=true
	make_ui()
	var demo=preload("res://interactions.gd").new();demo.name="LearningInteractions";add_child(demo)
	if "--verify" in OS.get_cmdline_user_args():
		testing=true;call_deferred("verify",true)

func make_environment():
	var world=WorldEnvironment.new();world.name="Atmosphere";add_child(world)
	var env=Environment.new();world.environment=env
	var sky=Sky.new();var sm=ProceduralSkyMaterial.new()
	sm.sky_top_color=Color("587fae");sm.sky_horizon_color=Color("c2d8df");sm.ground_horizon_color=Color("c2d8df");sm.ground_bottom_color=Color("566c75");sky.sky_material=sm
	env.background_mode=Environment.BG_SKY;env.sky=sky;env.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;env.ambient_light_color=Color("d4e5fa");env.ambient_light_energy=0.52
	env.tonemap_mode=Environment.TONE_MAPPER_LINEAR;env.fog_enabled=true;env.fog_light_color=Color("b5d0df");env.fog_density=0.001
	var sun=DirectionalLight3D.new();sun.name="LateAfternoonSun";sun.rotation_degrees=Vector3(-42,-28,0);sun.light_color=Color("fff0d8");sun.light_energy=0.65;sun.shadow_enabled=true;sun.directional_shadow_max_distance=100;add_child(sun)
	var clouds=MeshInstance3D.new();clouds.name="PROVISIONAL_CloudLayer_NotHistorical";var plane=PlaneMesh.new();plane.size=Vector2(480,480);clouds.mesh=plane;clouds.position.y=65
	var mat=ShaderMaterial.new();mat.shader=load("res://clouds.gdshader");clouds.material_override=mat;clouds.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(clouds)

func ground_y(x:float,z:float)->float:
	var query=PhysicsRayQueryParameters3D.create(Vector3(x,80,z),Vector3(x,-50,z),1)
	var hit=get_world_3d().direct_space_state.intersect_ray(query)
	return hit.position.y if not hit.is_empty() else -10.0

func make_boundary():
	# Physical perimeter: invisible tall walls, with low timber markers on real terrain.
	var boundary=Node3D.new();boundary.name="SafeMeadowBoundary";add_child(boundary)
	var timber=StandardMaterial3D.new();timber.albedo_color=Color("746548");timber.roughness=1
	for i in 48:
		var a=TAU*float(i)/48.0;var b=TAU*float(i+1)/48.0
		var p=CENTER+Vector3(sin(a)*RADIUS,0,cos(a)*RADIUS)
		var q=CENTER+Vector3(sin(b)*RADIUS,0,cos(b)*RADIUS)
		var wall=StaticBody3D.new();wall.name="Edge_%02d"%i;wall.collision_layer=8;wall.position=(p+q)*0.5;wall.position.y=10;wall.rotation.y=atan2((q-p).x,(q-p).z);boundary.add_child(wall)
		var shape=BoxShape3D.new();shape.size=Vector3(0.3,60,p.distance_to(q)+0.2);var collider=CollisionShape3D.new();collider.shape=shape;wall.add_child(collider)
	# Ground markers are placed after physics has synchronized terrain.
	call_deferred("place_markers",boundary,timber)

func place_markers(boundary:Node3D,timber:Material):
	await get_tree().physics_frame
	await get_tree().physics_frame
	car.position.y=ground_y(car.position.x,car.position.z)+0.75
	get_node("CarCollision").position.y=car.position.y
	for i in 48:
		var a=TAU*float(i)/48.0;var p=CENTER+Vector3(sin(a)*(RADIUS-0.5),0,cos(a)*(RADIUS-0.5));p.y=ground_y(p.x,p.z)
		var mesh=MeshInstance3D.new();var cylinder=CylinderMesh.new();cylinder.top_radius=0.08;cylinder.bottom_radius=0.10;cylinder.height=0.9;mesh.mesh=cylinder;mesh.material_override=timber;mesh.position=p+Vector3.UP*0.45;boundary.add_child(mesh)

func spawn(id:String):
	var body=CharacterBody3D.new();body.name=id;body.floor_snap_length=0.7;body.floor_max_angle=deg_to_rad(50);body.collision_layer=2;body.collision_mask=13;add_child(body)
	var shape=CapsuleShape3D.new();shape.radius=0.28;shape.height=1.5;var collider=CollisionShape3D.new();collider.shape=shape;collider.position.y=0.75;body.add_child(collider)
	var yaw=Node3D.new();body.add_child(yaw);var anchor=Node3D.new();yaw.add_child(anchor);anchor.scale=Vector3.ONE*calibration[id].scale
	var model=load("res://assets/"+id+".glb").instantiate();anchor.add_child(model)
	for mesh in model.find_children("*","MeshInstance3D",true,false):
		for i in mesh.mesh.get_surface_count():
			var mat=mesh.get_active_material(i)
			if mat is StandardMaterial3D:
				mat=mat.duplicate();mat.metallic=0;mat.roughness=0.85;mat.emission_enabled=false;mesh.set_surface_override_material(i,mat)
	var ap:AnimationPlayer=model.find_children("*","AnimationPlayer",true,false)[0]
	for name in ap.get_animation_library_list():
		var library=ap.get_animation_library(name).duplicate(true);ap.remove_animation_library(name);ap.add_animation_library(name,library)
	for name in ["Idle","Walk","Run"]: ap.get_animation(name).loop_mode=Animation.LOOP_LINEAR
	actors[id]={"body":body,"yaw":yaw,"anchor":anchor,"model":model,"ap":ap}

func select_character(id:String):
	var where=SPAWN if player==null else player.position
	active_id=id;player=actors[id].body
	for name in actors:
		actors[name].body.visible=name==id
		actors[name].body.process_mode=Node.PROCESS_MODE_INHERIT if name==id else Node.PROCESS_MODE_DISABLED
		actors[name].body.position=where if name==id else Vector3(0,-100,0)
	player.velocity=Vector3.ZERO;clip="Idle";actors[id].ap.play("Idle");blend_to=calibration[id].offsets.Idle;blend_from=blend_to;blend_time=1;actors[id].anchor.position.y=blend_to

func make_ui():
	var canvas=CanvasLayer.new();add_child(canvas)
	var title=Label.new();title.position=Vector2(24,16);title.text="MISTY MOUNTAIN  /  PROTOTYPE";title.add_theme_font_size_override("font_size",22);canvas.add_child(title)
	status=Label.new();status.position=Vector2(24,46);canvas.add_child(status)
	var footer=Label.new();footer.position=Vector2(24,676);footer.text="WASD move | Shift run | 1/2 character | Q/C orbit | Wheel zoom | E interact | R respawn | F restart | H help";canvas.add_child(footer)
	help=PanelContainer.new();help.position=Vector2(24,88);canvas.add_child(help)
	var text=Label.new();text.text="  COMMUNITY LEARNING PROTOTYPE  \n  1 Teknium   /   2 Doge Man\n  Walk inside the timber-marked meadow. No jump or driving.\n  Source mountain + source rigs; new provisional cloud layer.\n  E near token / beacon / gun to interact. Q/C orbits.\n  R respawns; F clears token and checkpoint. No saved progress.\n  H hides this panel • Esc quits.  ";help.add_child(text)
	help.visible=false
	for label in canvas.find_children("*","Label",true,false):
		label.add_theme_color_override("font_outline_color",Color(0.06,0.09,0.12,0.95))
		label.add_theme_constant_override("outline_size",5)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:get_tree().quit()
			KEY_R:reset_player()
			KEY_1:select_character("tek")
			KEY_2:select_character("doge")
			KEY_H:help.visible=not help.visible
	if event is InputEventMouseButton and event.pressed:
		if event.button_index==MOUSE_BUTTON_WHEEL_UP:distance=maxf(4,distance-1)
		if event.button_index==MOUSE_BUTTON_WHEEL_DOWN:distance=minf(18,distance+1)

func reset_player():
	var demo=get_node_or_null("LearningInteractions")
	player.position=demo.respawn_position if demo and demo.checkpoint_active else SPAWN
	player.velocity=Vector3.ZERO;reset_count+=1

func _physics_process(dt):
	if player==null:return
	angle+=(Input.get_action_strength("orbit_right")-Input.get_action_strength("orbit_left"))*dt*1.4
	var input=Input.get_vector("left","right","forward","back")
	var direction=Vector3(input.x,0,input.y).rotated(Vector3.UP,angle)
	var next="Idle" if direction.length()<0.01 else ("Run" if Input.is_action_pressed("run") else "Walk")
	if next!=clip:
		clip=next;actors[active_id].ap.play(clip,BLEND);blend_from=actors[active_id].anchor.position.y;blend_to=calibration[active_id].offsets[clip];blend_time=0
	blend_time+=dt;actors[active_id].anchor.position.y=lerpf(blend_from,blend_to,minf(blend_time/BLEND,1.0))
	var speed=3.8 if clip=="Run" else 1.8
	player.velocity.x=direction.x*speed;player.velocity.z=direction.z*speed
	if player.is_on_floor():player.velocity.y=-0.5
	else:player.velocity.y-=18*dt
	player.move_and_slide()
	if direction.length()>0.01:actors[active_id].yaw.rotation.y=lerp_angle(actors[active_id].yaw.rotation.y,atan2(direction.x,direction.z),minf(14*dt,1))
	if player.position.y < -15 or Vector2(player.position.x-CENTER.x,player.position.z-CENTER.z).length()>RADIUS+1:reset_player()
	if camera:
		var target=player.position+Vector3(0,1.0,0)
		var desired=target+Vector3(0,distance*0.28,distance).rotated(Vector3.UP,angle)
		var ray=PhysicsRayQueryParameters3D.create(target,desired,5)
		ray.hit_back_faces=true
		var obstruction=get_world_3d().direct_space_state.intersect_ray(ray)
		camera.position=desired if obstruction.is_empty() else obstruction.position+(target-desired).normalized()*0.3
		camera.look_at(target)
	if status:status.text=("Teknium" if active_id=="tek" else "Doge Man")+"  •  "+clip+"   |   H: prototype notes"

func keys(codes:Array,pressed:bool):
	for code in codes:
		var event=InputEventKey.new();event.physical_keycode=code;event.keycode=code;event.pressed=pressed;Input.parse_input_event(event)
func frames(n:int):
	for i in n:await get_tree().physics_frame
func check(ok:bool,label:String):
	results.append({"pass":ok,"test":label})
	print("PASS " if ok else "FAIL ",label)
func shot(name:String):
	if evidence_dir.is_empty():return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(evidence_dir+"/"+name+".png")
func verify(graphical:bool=true):
	testing=true
	await frames(100)
	check(player.is_on_floor(),"spawn on actual terrain collision")
	check(get_node("SafeMeadowBoundary").get_child_count()==96,"48 physical edge sections and 48 visible markers")
	check(absf(car.position.y-ground_y(car.position.x,car.position.z)-0.75)<0.01,"car placed on terrain, not floating above meadow")
	for i in 8:
		angle=float(i)*TAU/8.0;await frames(3)
		var sight=PhysicsRayQueryParameters3D.create(player.position+Vector3.UP,camera.position,5);sight.hit_back_faces=true
		check(get_world_3d().direct_space_state.intersect_ray(sight).is_empty(),"camera unobstructed orbit "+str(i))
	angle=PI
	for id in ["tek","doge"]:
		keys([KEY_1 if id=="tek" else KEY_2],true);await frames(2);keys([KEY_1 if id=="tek" else KEY_2],false)
		check(active_id==id,id+" ordinary number-key selection")
		keys([KEY_R],true);await frames(2);keys([KEY_R],false);await frames(100)
		var sk:Skeleton3D=actors[id].model.find_children("*","Skeleton3D",true,false)[0]
		check(sk.get_bone_count()==24,id+" native 24-bone rig")
		for anim in ["Idle","Walk","Run"]:
			var ap:AnimationPlayer=actors[id].ap;var a=ap.get_animation(anim);var resolved=0
			for t in a.get_track_count():
				var path=a.track_get_path(t);var node=ap.get_node(ap.root_node).get_node_or_null(NodePath(str(path).split(":")[0]))
				if node!=null:
					if path.get_subname_count()==0 or not node is Skeleton3D or node.find_bone(str(path.get_subname(0)))>=0:resolved+=1
			check(a.length>0.1 and a.get_track_count()>20 and resolved==a.get_track_count(),id+" "+anim+" animated tracks resolve")
		if graphical:await shot(id+"_idle")
		var before=player.position
		keys([KEY_S],true);await frames(70)
		check(clip=="Walk" and player.position.distance_to(before)>1.5,id+" ordinary S walking")
		check(player.is_on_floor(),id+" walking terrain contact")
		var pose=sk.get_bone_pose_rotation(5);await frames(15)
		check(pose.angle_to(sk.get_bone_pose_rotation(5))>0.001,id+" live skeletal pose changes")
		if graphical:await shot(id+"_walk")
		keys([KEY_SHIFT],true);before=player.position;await frames(50)
		check(clip=="Run" and player.position.distance_to(before)>2.4,id+" Shift run")
		if graphical:await shot(id+"_run")
		keys([KEY_SHIFT,KEY_S],false);await frames(30)
		check(clip=="Idle",id+" release restores idle")
		keys([KEY_R],true);await frames(2);keys([KEY_R],false);await frames(90)
		check(Vector2(player.position.x-SPAWN.x,player.position.z-SPAWN.z).length()<0.1 and player.is_on_floor(),id+" ordinary R reset")
	# Four ordinary sustained cardinal runs must stay within collision perimeter.
	for code in [KEY_W,KEY_A,KEY_S,KEY_D]:
		reset_player();await frames(90);var resets=reset_count
		keys([code,KEY_SHIFT],true);await frames(500);keys([code,KEY_SHIFT],false);await frames(15)
		var radius=Vector2(player.position.x-CENTER.x,player.position.z-CENTER.z).length()
		print("EDGE radius=",radius," position=",player.position)
		check(radius<RADIUS and reset_count==resets,"safe edge "+str(code)+" no fall/reset")
		check(radius>RADIUS-1.0,"reached actual perimeter "+str(code))
		check(player.is_on_floor(),"edge terrain contact "+str(code))
	if graphical:await shot("boundary")
	# Approach the placed prop through the same movement controller.
	player.position=Vector3(car.position.x-5,ground_y(car.position.x-5,car.position.z)+2,car.position.z)
	await frames(90)
	keys([KEY_A,KEY_SHIFT],true);await frames(120)
	check(player.position.x<car.position.x-2.1 and player.get_slide_collision_count()>0,"car prop blocks ordinary walking")
	keys([KEY_A,KEY_SHIFT],false)
	var before_reset=reset_count;player.position.y=-50;await frames(3)
	check(reset_count==before_reset+1,"fall failsafe restores safe spawn")
	reset_player();await frames(90)
	var original=angle;keys([KEY_C],true);await frames(30);keys([KEY_C],false);check(angle>original+0.5,"ordinary C camera orbit")
	await preload("res://interaction_tests.gd").run(self,graphical)
	var failures=results.filter(func(r):return not r.pass)
	if not evidence_dir.is_empty():FileAccess.open(evidence_dir+"/results.json",FileAccess.WRITE).store_string(JSON.stringify(results,"\t"))
	print("STARTER_VERIFY ",results.size()," assertions failures=",failures.size())
	get_tree().quit(0 if failures.is_empty() else 1)
