extends Node3D
const NAMES = ["Stojak","Rygiel","Stężenie","Podest","Podstawka","Drabina","Poręcz","Schody","Rama","Stojak 2 m","Stojak 3 m","Stojak 4 m","Rygiel 2 m","Rygiel 3 m","Rygiel 4 m","Stężenie 2x2","Stężenie 3x2","Stężenie 3x3","Podest 2 m","Podest 3 m","Podest szeroki","Podstawka wysoka","Drabina 2 m","Drabina 3 m","Poręcz 2 m","Poręcz 3 m","Schody 2 m","Rama 2 m","Rama szeroka","Rama przemysłowa","Podest mostowy","Stężenie długie","Rygiel krótki"]
const BASES = [0,1,2,3,4,5,6,7,8,0,0,0,1,1,1,2,2,2,3,3,3,4,5,5,6,6,7,8,8,8,3,2,1]
const SCALES = [Vector3.ONE,Vector3.ONE,Vector3.ONE,Vector3.ONE,Vector3.ONE,Vector3.ONE,Vector3.ONE,Vector3.ONE,Vector3.ONE,Vector3(1,2,1),Vector3(1,3,1),Vector3(1,4,1),Vector3(2,1,1),Vector3(3,1,1),Vector3(4,1,1),Vector3(2,2,1),Vector3(3,2,1),Vector3(3,3,1),Vector3(2,1,1),Vector3(3,1,1),Vector3(1,1,2),Vector3(1,2,1),Vector3(1,2,1),Vector3(1,3,1),Vector3(2,1,1),Vector3(3,1,1),Vector3(1,2,2),Vector3(1,2,1),Vector3(2,1,1),Vector3(2,2,1),Vector3(4,1,2),Vector3(4,3,1),Vector3(0.5,1,1)]
var selected := 0
var cursor := Vector3i.ZERO
var rotation_step := 0
var pieces := {}
var cam: Camera3D
var hud: Label
var ghost: Node3D
var angle := 0.7
var distance := 15.0
var message := "Tryb kreatywny"
var career := false
var money := 1000
var stock := [12,12,6,6,8,4,6,4,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3]
const PRICES = [35,25,30,50,15,55,35,80,100,70,105,140,50,75,100,60,90,90,100,150,100,30,110,165,70,105,160,200,200,200,200,120,25]
var contract := 0
var career_keys := {}
var walking := false
var eye := Vector3(3,1.7,5)
var yaw := 0.0
var pitch := -0.25
var menu: PanelContainer
var menu_label: Label
var language := false
var player: CharacterBody3D
var fall_speed := 0.0
var health := 100
var jump_locked := false
var snap_enabled := true
var crosshair: Label
var start_panel: PanelContainer
var catalog: ItemList
var stability_on := false
var unsupported := 0
var inspection_clock := 0.0
var crane_hook: Node3D
var crane_pos := Vector3(20,12,15)
var cargo := false
var deliveries := 0
var delivery_panel: Label
func _ready():
 var env := WorldEnvironment.new()
 env.environment = Environment.new()
 env.environment.background_mode = Environment.BG_COLOR
 env.environment.background_color = Color("9bb7ce")
 env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
 env.environment.ambient_light_color = Color.WHITE
 env.environment.ambient_light_energy = 0.65
 add_child(env)
 var sun := DirectionalLight3D.new()
 sun.rotation_degrees = Vector3(-55,-35,0)
 sun.shadow_enabled = true
 add_child(sun)
 solid(box(self,Vector3(50,0.2,50),Vector3(0,-0.15,0), Color("555c62")))
 for i in range(-24,25):
  box(self,Vector3(0.025,0.012,48),Vector3(i,-0.04,0),Color("87929b"))
  box(self,Vector3(48,0.012,0.025),Vector3(0,-0.04,i),Color("87929b"))
 solid(box(self,Vector3(5,10,5),Vector3(-7,5,-3),Color("a4a19a")))
 solid(box(self,Vector3(8,14,6),Vector3(15,7,-12),Color("838d98")))
 for x in range(12,19,2):
  for y in range(2,14,3):
   box(self,Vector3(1.1,1.5,0.06),Vector3(x,y,-8.97),Color("304957"))
 build_industrial_site()
 player = CharacterBody3D.new()
 player.position = Vector3(3,0.05,5)
 player.floor_snap_length = 0.25
 var capsule := CapsuleShape3D.new()
 capsule.radius = 0.25
 capsule.height = 1.7
 var collider := CollisionShape3D.new()
 collider.shape = capsule
 collider.position.y = 0.85
 player.add_child(collider)
 add_child(player)
 cam = Camera3D.new()
 add_child(cam)
 cam.current = true
 var layer := CanvasLayer.new()
 add_child(layer)
 hud = Label.new()
 hud.position = Vector2(18,18)
 hud.add_theme_font_size_override("font_size",20)
 hud.add_theme_color_override("font_shadow_color",Color.BLACK)
 hud.add_theme_constant_override("shadow_offset_x",2)
 hud.add_theme_constant_override("shadow_offset_y",2)
 layer.add_child(hud)
 setup_menu(layer)
 setup_start(layer)
 refresh()
func box(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
 var mesh := MeshInstance3D.new()
 var shape := BoxMesh.new()
 shape.size = size
 mesh.mesh = shape
 var mat := StandardMaterial3D.new()
 mat.albedo_color = color
 mat.metallic = 0.55
 mat.roughness = 0.45
 mesh.material_override = mat
 mesh.position = pos
 parent.add_child(mesh)
 return mesh
func bar(parent: Node3D, a: Vector3, b: Vector3, color: Color):
 var mesh := MeshInstance3D.new()
 var tube := CylinderMesh.new()
 tube.top_radius = 0.0325
 tube.bottom_radius = 0.0325
 tube.height = a.distance_to(b)
 tube.radial_segments = 12
 mesh.mesh = tube
 var mat := StandardMaterial3D.new()
 mat.albedo_color = color
 mat.metallic = 0.7
 mat.roughness = 0.35
 mesh.material_override = mat
 mesh.position = (a+b)/2
 mesh.quaternion = Quaternion(Vector3.UP,(b-a).normalized())
 parent.add_child(mesh)
func make_piece(kind: int, preview: bool) -> Node3D:
 var n := Node3D.new()
 var c := Color("39e6ae") if preview else Color("b2c1cb")
 var model_kind: int = BASES[kind]
 match model_kind:
  0:
   bar(n,Vector3.ZERO,Vector3(0,1,0),c)
   for y in [0.1,0.5,0.9]: box(n,Vector3(0.16,0.04,0.16),Vector3(0,y,0),c)
  1: bar(n,Vector3.ZERO,Vector3(1,0,0),c)
  2: bar(n,Vector3.ZERO,Vector3(1,1,0),c)
  3:
   for i in range(5): box(n,Vector3(1,0.06,0.18),Vector3(0.5,0.03,i*0.2-0.4),c)
  4:
   box(n,Vector3(0.3,0.05,0.3),Vector3(0,0.025,0),c)
   bar(n,Vector3.ZERO,Vector3(0,0.3,0),c)
  5:
   for x in [-0.2,0.2]: bar(n,Vector3(x,0,0),Vector3(x,1,0),c)
   for i in range(5): bar(n,Vector3(-0.2,i*0.2+0.1,0),Vector3(0.2,i*0.2+0.1,0),c)
  6:
   for y in [0.1,0.5]: bar(n,Vector3(0,y,0),Vector3(1,y,0),c)
  7:
   for i in range(5): box(n,Vector3(0.45,0.08,0.2),Vector3(0,i*0.2+0.04,i*0.2),c)
  8:
   for x in [0.0,1.0]: bar(n,Vector3(x,0,0),Vector3(x,1,0),c)
   for y in [0.2,0.95]: bar(n,Vector3(0,y,0),Vector3(1,y,0),c)
   bar(n,Vector3.ZERO,Vector3(1,1,0),c)
 if not preview:
  for child in n.get_children():
   if child is MeshInstance3D and model_kind != 5: solid(child)
 n.scale = SCALES[kind]
 return n
func key_for(p: Vector3i, k: int, r: int) -> String:
 return "%d,%d,%d,%d,%d" % [p.x,p.y,p.z,k,r]
func refresh():
 if is_instance_valid(ghost): ghost.queue_free()
 ghost = make_piece(selected,true)
 add_child(ghost)
 ghost.position = Vector3(cursor)
 ghost.rotation.y = rotation_step*PI/2
 var target := Vector3(cursor)+Vector3(0,1,0)
 if not walking:
  cam.position = target + Vector3(cos(angle)*distance,distance*0.65,sin(angle)*distance)
  cam.look_at(target)
 hud.text = "SCAFFOLDING SIMULATOR 4.0 | %s | Elementy: %d\n1–9: wybór (%s) | R: obrót | Enter: montaż | Delete: demontaż\nWASD: pozycja | Q/E: wysokość | strzałki: kamera | F5: zapis | F9: wczytaj\nPozycja: %s | %s" % [message,pieces.size(),NAMES[selected],str(cursor),"Podgląd zielony"]
 hud.text += "\nTab: centrum firmy | V: widok FPS | LPM/PPM: montaż/demontaż (FPS) | Esc: uwolnij mysz\n"
 hud.text += ("CAREER" if career else "CREATIVE") + " | PLN %d | Magazyn: %d | Kontrakt %d" % [money,stock[selected],contract+1]
 hud.text += "\nF7: stabilność | F8: inspekcja | C: transport dźwigiem | [ / ]: wybór | niestabilne: %d" % unsupported
 hud.text += "\nSPACJA: skok/wspinanie | CTRL: zejście | B: przyciąganie | HP: %d | SNAP: %s" % [health,"ON" if snap_enabled else "OFF"]
 if is_instance_valid(crosshair): crosshair.visible = walking and not menu.visible and not start_panel.visible
 if is_instance_valid(menu_label): update_menu()
func place(p: Vector3i,k: int,r: int):
 var key := key_for(p,k,r)
 if pieces.has(key): return
 var n := make_piece(k,false)
 add_child(n)
 n.position = Vector3(p)
 n.rotation.y = r*PI/2
 pieces[key] = n
func _unhandled_key_input(event):
 if not event.pressed or event.echo: return
 var key: int = event.keycode
 if start_panel.visible: return
 if key == KEY_F7:
  toggle_stability()
  return
 if key == KEY_F8:
  inspect_structure(true)
  refresh()
  return
 if key == KEY_C:
  crane_action()
  refresh()
  return
 if key == KEY_B:
  snap_enabled = not snap_enabled
  refresh()
  return
 if key == KEY_TAB:
  menu.visible = not menu.visible
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if menu.visible or not walking else Input.MOUSE_MODE_CAPTURED
  update_menu()
  return
 if key == KEY_V:
  walking = not walking
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if walking and not menu.visible else Input.MOUSE_MODE_VISIBLE
  refresh()
  return
 if key == KEY_ESCAPE:
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  return
 if menu.visible: return
 if walking and key in [KEY_W,KEY_A,KEY_S,KEY_D]: return
 if key >= KEY_1 and key <= KEY_9: selected = key-KEY_1
 else:
  match key:
   KEY_BRACKETLEFT: selected = posmod(selected-1,NAMES.size())
   KEY_BRACKETRIGHT: selected = posmod(selected+1,NAMES.size())
   KEY_W: cursor.z -= 1
   KEY_S: cursor.z += 1
   KEY_A: cursor.x -= 1
   KEY_D: cursor.x += 1
   KEY_Q: cursor.y -= 1
   KEY_E: cursor.y += 1
   KEY_R: rotation_step = (rotation_step+1)%4
   KEY_LEFT: angle -= 0.15
   KEY_RIGHT: angle += 0.15
   KEY_UP: distance = maxf(4,distance-1)
   KEY_DOWN: distance = minf(35,distance+1)
   KEY_ENTER: build_selected()
   KEY_DELETE:
    remove_selected()
   KEY_F5:
    var f := FileAccess.open("user://construction.json",FileAccess.WRITE)
    if f: f.store_string(JSON.stringify(pieces.keys())); message = "Zapisano"
    save_career()
   KEY_F9:
    load_world()
    load_career()
 cursor = Vector3i(clampi(cursor.x,-24,24),clampi(cursor.y,0,45),clampi(cursor.z,-24,24))
 refresh()
func load_world():
 if not FileAccess.file_exists("user://construction.json"): return
 var data = JSON.parse_string(FileAccess.get_file_as_string("user://construction.json"))
 if not data is Array: return
 for n in pieces.values(): n.queue_free()
 pieces.clear()
 for item in data:
  if not item is String: continue
  var a = item.split(",")
  if a.size()!=5: continue
  var k := int(a[3])
  var r := int(a[4])
  if k>=0 and k<NAMES.size() and r>=0 and r<4: place(Vector3i(int(a[0]),int(a[1]),int(a[2])),k,r)
 message = "Wczytano"

func setup_menu(layer: CanvasLayer):
 menu = PanelContainer.new()
 menu.position = Vector2(18,180)
 layer.add_child(menu)
 var v := VBoxContainer.new()
 menu.add_child(v)
 menu_label = Label.new()
 v.add_child(menu_label)
 catalog = ItemList.new()
 catalog.custom_minimum_size = Vector2(390,180)
 for item in NAMES: catalog.add_item(item)
 catalog.item_selected.connect(select_material)
 v.add_child(catalog)
 for pair in [["Tryb kreatywny / kariera",toggle_mode],["Kup wybrany element +1",buy],["Odbierz nagrodę za kontrakt",claim],["Zmień widok kamery",toggle_view],["Cienie ON/OFF",toggle_shadows],["PL / EN (panel)",toggle_language],["Stabilność ON/OFF",toggle_stability],["Zamów dostawę +10",order_delivery],["Zamknij / Close",close_menu]]:
  var b := Button.new()
  b.text = pair[0]
  b.pressed.connect(pair[1])
  v.add_child(b)
 menu.visible = false
 update_menu()
func update_menu():
 var target := 8 + contract*4
 var counts := [0,0,0,0,0,0,0,0,0]
 for id in career_keys:
  if pieces.has(id):
   var a = id.split(",")
   counts[BASES[int(a[3])]] += 1
 menu_label.text = ("COMPANY CENTER / Warehouse" if language else "CENTRUM FIRMY / MAGAZYN") + "\nPLN %d | %s\n" % [money,"CAREER" if career else "CREATIVE"]
 menu_label.text += "Wybrano: %s | magazyn %d | PLN %d\n" % [NAMES[selected],stock[selected],PRICES[selected]]
 if is_instance_valid(catalog):
  for i in range(NAMES.size()): catalog.set_item_text(i,"%s | %d szt. | %d PLN" % [NAMES[i],stock[i],PRICES[i]])
  catalog.select(selected)
 menu_label.text += "Contract %d: %d/%d | Stojaki/standards %d/2 | Podesty/decks %d/2\n%s" % [contract+1,career_keys.size(),target,counts[0],counts[3],message]
func toggle_mode():
 career = not career
 message = "Kariera / Career" if career else "Kreatywny / Creative"
 refresh()
func buy():
 if money < PRICES[selected]:
  message = "Brak środków"
 else:
  money -= PRICES[selected]
  stock[selected] += 1
  message = "Kupiono / Purchased"
 refresh()
func claim():
 var standards := 0
 var decks := 0
 for id in career_keys:
  var a = id.split(",")
  if BASES[int(a[3])] == 0: standards += 1
  if BASES[int(a[3])] == 3: decks += 1
 if career and career_keys.size() >= 8+contract*4 and standards >= 2 and decks >= 2:
  money += 600+contract*250
  contract += 1
  career_keys.clear()
  message = "Kontrakt ukończony!"
 else: message = "Wymagania kontraktu nie zostały spełnione"
 refresh()
func toggle_view():
 walking = not walking
 refresh()
func toggle_shadows():
 for child in get_children():
  if child is DirectionalLight3D: child.shadow_enabled = not child.shadow_enabled
func toggle_language():
 language = not language
 update_menu()
func close_menu():
 menu.hide()
 Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if walking else Input.MOUSE_MODE_VISIBLE
func build_selected():
 var id := key_for(cursor,selected,rotation_step)
 if pieces.has(id): return
 if career:
  if stock[selected] <= 0:
   message = "Brak materiałów"
   return
  stock[selected] -= 1
  career_keys[id] = true
 place(cursor,selected,rotation_step)
func remove_selected():
 var id := key_for(cursor,selected,rotation_step)
 if pieces.has(id):
  pieces[id].queue_free()
  pieces.erase(id)
  if career_keys.has(id):
   stock[selected] += 1
   career_keys.erase(id)
func save_career():
 var f := FileAccess.open("user://career.json",FileAccess.WRITE)
 if f: f.store_string(JSON.stringify({"money":money,"stock":stock,"contract":contract,"keys":career_keys.keys(),"career":career,"stability":stability_on,"deliveries":deliveries,"cargo":cargo}))
func load_career():
 if not FileAccess.file_exists("user://career.json"): return
 var d = JSON.parse_string(FileAccess.get_file_as_string("user://career.json"))
 if not d is Dictionary: return
 money = int(d.get("money",1000))
 contract = int(d.get("contract",0))
 career = bool(d.get("career",false))
 stability_on = bool(d.get("stability",false))
 deliveries = int(d.get("deliveries",0))
 cargo = bool(d.get("cargo",false))
 var saved = d.get("stock",[])
 if saved is Array and saved.size()>=8:
  for i in range(mini(NAMES.size(),saved.size())): stock[i] = int(saved[i])
 career_keys.clear()
 for id in d.get("keys",[]):
  if pieces.has(id): career_keys[id] = true
func _physics_process(delta):
 if start_panel.visible: return
 inspection_clock += delta
 if inspection_clock >= 2.0:
  inspection_clock = 0.0
  if stability_on: inspect_structure(false)
 if not walking: return
 var active := not menu.visible and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
 var move := Vector3.ZERO
 var forward := Vector3(-sin(yaw),0,-cos(yaw))
 var right := Vector3(cos(yaw),0,-sin(yaw))
 if Input.is_physical_key_pressed(KEY_W): move += forward
 if Input.is_physical_key_pressed(KEY_S): move -= forward
 if Input.is_physical_key_pressed(KEY_D): move += right
 if Input.is_physical_key_pressed(KEY_A): move -= right
 if not active: move = Vector3.ZERO
 var speed := 5.0 if not Input.is_physical_key_pressed(KEY_SHIFT) else 7.0
 player.velocity.x = move.normalized().x*speed
 player.velocity.z = move.normalized().z*speed
 var jump := active and Input.is_physical_key_pressed(KEY_SPACE)
 var climbing := near_ladder()
 if climbing and active:
  player.velocity.y = 2.8 if jump else (-2.8 if Input.is_physical_key_pressed(KEY_CTRL) else 0.0)
 else:
  if not player.is_on_floor(): player.velocity.y -= 14.0*delta
  elif jump and not jump_locked: player.velocity.y = 5.5
  else: player.velocity.y = 0.0
 jump_locked = jump
 fall_speed = maxf(0.0,-player.velocity.y)
 player.move_and_slide()
 if player.is_on_floor() and fall_speed > 9.0:
  health = maxi(0,health-int((fall_speed-8.0)*5.0))
  message = "Upadek z wysokości!"
  refresh()
 if player.position.y < -8.0 or health <= 0:
  player.position = Vector3(3,0.1,5)
  player.velocity = Vector3.ZERO
  health = 100
  message = "Powrót na plac budowy"
  refresh()
 player.position.x = clampf(player.position.x,-24.5,24.5)
 player.position.z = clampf(player.position.z,-24.5,24.5)
 eye = player.position + Vector3(0,1.6,0)
 cam.position = eye
 cam.rotation = Vector3(pitch,yaw,0)
 var point := eye - cam.global_transform.basis.z*4.0
 if pitch < -0.1:
  var t := (float(cursor.y)-eye.y)/(-cam.global_transform.basis.z.y)
  if t > 0 and t < 12: point = eye-cam.global_transform.basis.z*t
 var next := Vector3i(clampi(roundi(point.x),-24,24),cursor.y,clampi(roundi(point.z),-24,24))
 if snap_enabled: next = snap_point(next,point)
 if active and next != cursor:
  cursor = next
  refresh()
func _unhandled_input(event):
 if not walking or menu.visible or start_panel.visible: return
 if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
  yaw -= event.relative.x*0.003
  pitch = clampf(pitch-event.relative.y*0.003,-1.4,1.4)
 if event is InputEventMouseButton and event.pressed:
  if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
   Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
   return
  if event.button_index == MOUSE_BUTTON_LEFT: build_selected()
  if event.button_index == MOUSE_BUTTON_RIGHT: remove_selected()
  refresh()

func solid(mesh: MeshInstance3D):
 var body := StaticBody3D.new()
 var shape := CollisionShape3D.new()
 shape.shape = mesh.mesh.create_trimesh_shape()
 body.add_child(shape)
 mesh.add_child(body)
func near_ladder() -> bool:
 for id in pieces:
  var fields = id.split(",")
  if BASES[int(fields[3])] != 5: continue
  var p: Vector3 = pieces[id].position
  var diff := player.position-p
  if Vector2(diff.x,diff.z).length()<0.75 and diff.y >= -0.4 and diff.y <= SCALES[int(fields[3])].y+0.25: return true
 return false
func snap_point(p: Vector3i, aim: Vector3) -> Vector3i:
 var best := p
 var best_dist := 0.65
 for id in pieces:
  var fields = id.split(",")
  var kind := int(fields[3])
  var k: int = BASES[kind]
  if k not in [0,1,2,8]: continue
  var n: Node3D = pieces[id]
  var ends := [Vector3.ZERO,Vector3.UP] if k == 0 else [Vector3.ZERO,Vector3.RIGHT]
  if k == 2: ends = [Vector3.ZERO,Vector3(1,1,0)]
  if k == 8: ends = [Vector3.ZERO,Vector3.UP,Vector3.RIGHT,Vector3(1,1,0)]
  for local in ends:
   var world: Vector3 = n.to_global(local)
   var d := world.distance_to(aim)
   if d < best_dist and absi(roundi(world.y)-p.y)<=1:
    best_dist = d
    best = Vector3i(roundi(world.x),roundi(world.y),roundi(world.z))
 return best
func setup_start(layer: CanvasLayer):
 crosshair = Label.new()
 crosshair.text = "+"
 crosshair.add_theme_font_size_override("font_size",30)
 crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
 crosshair.position = get_viewport().get_visible_rect().size/2-Vector2(10,20)
 crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
 layer.add_child(crosshair)
 start_panel = PanelContainer.new()
 start_panel.position = Vector2(360,160)
 start_panel.custom_minimum_size = Vector2(500,300)
 layer.add_child(start_panel)
 var v := VBoxContainer.new()
 v.add_theme_constant_override("separation",12)
 start_panel.add_child(v)
 var heading := Label.new()
 heading.text = "SCAFFOLDING SIMULATOR 4.0\nINDUSTRIAL WORLD"
 heading.add_theme_font_size_override("font_size",26)
 v.add_child(heading)
 for entry in [["TRYB KREATYWNY",start_creative],["KARIERA",start_career],["WCZYTAJ ZAPIS",start_saved],["WYJŚCIE",quit_game]]:
  var button := Button.new()
  button.custom_minimum_size.y = 40
  button.text = entry[0]
  button.pressed.connect(entry[1])
  v.add_child(button)
func start_creative():
 career = false
 start_panel.hide()
 refresh()
func start_career():
 career = true
 start_panel.hide()
 refresh()
func start_saved():
 load_world()
 load_career()
 start_panel.hide()
 refresh()
func quit_game():
 get_tree().quit()

func select_material(index: int):
 selected = index
 refresh()
func toggle_stability():
 stability_on = not stability_on
 message = "Stabilność symulacyjna: " + ("ON" if stability_on else "OFF")
 refresh()
func inspect_structure(report_only: bool):
 var cells := {}
 var supported := {}
 var queue: Array = []
 for id in pieces:
  var n: Node3D = pieces[id]
  var p := Vector3i(n.position.round())
  if not cells.has(p): cells[p] = []
  cells[p].append(id)
  if p.y == 0:
   supported[id] = true
   queue.append(id)
 # Approximate connectivity of occupied grid cells, including long element endpoints.
 for id in pieces:
  var f = id.split(",")
  var kind := int(f[3])
  var node: Node3D = pieces[id]
  var base: int = BASES[kind]
  var endpoints := [Vector3.ZERO]
  if base in [0,4,5,8]: endpoints.append(Vector3.UP)
  if base in [1,2,3,6,8]: endpoints.append(Vector3.RIGHT)
  if base in [2,8]: endpoints.append(Vector3(1,1,0))
  if base == 7: endpoints.append(Vector3(0,1,1))
  for e in endpoints:
   var cell := Vector3i(node.to_global(e).round())
   if not cells.has(cell): cells[cell] = []
   if not id in cells[cell]: cells[cell].append(id)
 var lookup := {}
 for cell in cells:
  for id in cells[cell]:
   if not lookup.has(id): lookup[id] = []
   lookup[id].append(cell)
 var idx := 0
 while idx < queue.size():
  var id = queue[idx]
  idx += 1
  for p in lookup.get(id,[]):
   for offset in [Vector3i.ZERO,Vector3i.UP,Vector3i.DOWN,Vector3i.LEFT,Vector3i.RIGHT,Vector3i(0,0,1),Vector3i(0,0,-1)]:
    for other in cells.get(p+offset,[]):
     if not supported.has(other):
      supported[other] = true
      queue.append(other)
 var falling: Array = []
 for id in pieces:
  if not supported.has(id): falling.append(id)
 unsupported = falling.size()
 if report_only:
  message = "Inspekcja: %d elementów bez połączenia z gruntem" % unsupported
  return
 if not stability_on or falling.is_empty(): return
 for id in falling:
  var n: Node3D = pieces[id]
  pieces.erase(id)
  career_keys.erase(id)
  for mesh in n.get_children():
   for body in mesh.get_children():
    if body is StaticBody3D: body.queue_free()
  var tween := create_tween()
  tween.tween_property(n,"position:y",-2.0,0.65)
  tween.tween_callback(n.queue_free)
 message = "Zawalenie: %d elementów" % unsupported
 refresh()
func build_industrial_site():
 var steel := Color("697a84")
 var concrete := Color("92918b")
 # Refinery tanks and pipe rack
 for x in [-19,-13]:
  var tank := MeshInstance3D.new()
  var cylinder := CylinderMesh.new()
  cylinder.top_radius = 2.4
  cylinder.bottom_radius = 2.4
  cylinder.height = 7
  tank.mesh = cylinder
  var mat := StandardMaterial3D.new()
  mat.albedo_color = steel
  mat.metallic = 0.65
  tank.material_override = mat
  tank.position = Vector3(x,3.5,-17)
  add_child(tank)
  solid(tank)
 for x in range(-20,-9,3):
  solid(box(self,Vector3(0.35,4,0.35),Vector3(x,2,-11),steel))
 solid(box(self,Vector3(12,0.55,0.8),Vector3(-15,4,-11),steel))
 # Factory and bridge training zone
 solid(box(self,Vector3(9,6,8),Vector3(-17,3,13),concrete))
 for i in range(4):
  solid(box(self,Vector3(1.2,3,1.2),Vector3(-6+i*4,1.5,20),concrete))
 solid(box(self,Vector3(15,0.6,3),Vector3(0,3.3,20),steel))
 # Tower crane and movable hook
 var yellow := Color("e9b43b")
 for x in [19.5,20.5]:
  for z in [14.5,15.5]: bar(self,Vector3(x,0,z),Vector3(x,14,z),yellow)
 for y in range(1,14,2):
  bar(self,Vector3(19.5,y,14.5),Vector3(20.5,y+1,14.5),yellow)
 solid(box(self,Vector3(14,0.4,0.5),Vector3(14,14,15),yellow))
 crane_hook = Node3D.new()
 add_child(crane_hook)
 crane_hook.position = crane_pos
 box(crane_hook,Vector3(0.18,0.6,0.18),Vector3.ZERO,steel)
func order_delivery():
 if cargo:
  message = "Dostawa już oczekuje na rozładunek"
 elif not career:
  message = "Włącz karierę"
 elif money < PRICES[selected]*8:
  message = "Brak środków"
 else:
  money -= PRICES[selected]*8
  cargo = true
  deliveries = selected+1
  message = "Dostawa 10 szt. czeka: C rozładuj dźwigiem"
 refresh()
func crane_action():
 if not cargo:
  message = "Zamów dostawę w centrum firmy"
  return
 var kind := deliveries-1
 if kind < 0 or kind >= NAMES.size(): return
 cargo = false
 deliveries = 0
 stock[kind] += 10
 var tween := create_tween()
 tween.tween_property(crane_hook,"position",Vector3(9,3,15),1.0)
 tween.tween_property(crane_hook,"position",crane_pos,1.0)
 message = "Dźwig rozładował 10 szt."
