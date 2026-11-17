extends Node3D
const NAMES = ["Stojak", "Rygiel", "Stężenie", "Podest", "Podstawka", "Drabina", "Poręcz", "Schody"]
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
var stock := [12,12,6,6,8,4,6,4]
const PRICES = [35,25,30,50,15,55,35,80]
var contract := 0
var career_keys := {}
var walking := false
var eye := Vector3(3,1.7,5)
var yaw := 0.0
var pitch := -0.25
var menu: PanelContainer
var menu_label: Label
var language := false
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
 box(self,Vector3(30,0.2,30),Vector3(0,-0.15,0), Color("555c62"))
 for i in range(-14,15):
  box(self,Vector3(0.025,0.012,28),Vector3(i,-0.04,0),Color("87929b"))
  box(self,Vector3(28,0.012,0.025),Vector3(0,-0.04,i),Color("87929b"))
 box(self,Vector3(5,10,5),Vector3(-7,5,-3),Color("a4a19a"))
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
 var mesh := box(parent,Vector3(0.065,a.distance_to(b),0.065),(a+b)/2,color)
 mesh.quaternion = Quaternion(Vector3.UP,(b-a).normalized())
func make_piece(kind: int, preview: bool) -> Node3D:
 var n := Node3D.new()
 var c := Color("39e6ae") if preview else Color("b2c1cb")
 match kind:
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
 hud.text = "SCAFFOLDING SIMULATOR 2.0 | %s | Elementy: %d\n1–8: wybór (%s) | R: obrót | Enter: montaż | Delete: demontaż\nWASD: pozycja | Q/E: wysokość | strzałki: kamera | F5: zapis | F9: wczytaj\nPozycja: %s | %s" % [message,pieces.size(),NAMES[selected],str(cursor),"Podgląd zielony"]
 hud.text += "\nTab: centrum firmy | V: widok FPS | LPM/PPM: montaż/demontaż (FPS) | Esc: uwolnij mysz\n"
 hud.text += ("CAREER" if career else "CREATIVE") + " | PLN %d | Magazyn: %d | Kontrakt %d" % [money,stock[selected],contract+1]
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
 if key >= KEY_1 and key <= KEY_8: selected = key-KEY_1
 else:
  match key:
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
 cursor = Vector3i(clampi(cursor.x,-14,14),clampi(cursor.y,0,30),clampi(cursor.z,-14,14))
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
  if k>=0 and k<8 and r>=0 and r<4: place(Vector3i(int(a[0]),int(a[1]),int(a[2])),k,r)
 message = "Wczytano"

func setup_menu(layer: CanvasLayer):
 menu = PanelContainer.new()
 menu.position = Vector2(18,180)
 layer.add_child(menu)
 var v := VBoxContainer.new()
 menu.add_child(v)
 menu_label = Label.new()
 v.add_child(menu_label)
 for pair in [["Tryb kreatywny / kariera",toggle_mode],["Kup wybrany element +1",buy],["Odbierz nagrodę za kontrakt",claim],["Zmień widok kamery",toggle_view],["Cienie ON/OFF",toggle_shadows],["PL / EN (panel)",toggle_language],["Zamknij / Close",close_menu]]:
  var b := Button.new()
  b.text = pair[0]
  b.pressed.connect(pair[1])
  v.add_child(b)
 menu.visible = false
 update_menu()
func update_menu():
 var target := 8 + contract*4
 var counts := [0,0,0,0,0,0,0,0]
 for id in career_keys:
  if pieces.has(id):
   var a = id.split(",")
   counts[int(a[3])] += 1
 menu_label.text = ("COMPANY CENTER / Warehouse" if language else "CENTRUM FIRMY / MAGAZYN") + "\nPLN %d | %s\n" % [money,"CAREER" if career else "CREATIVE"]
 for i in range(8):
  menu_label.text += "%s: %d | PLN %d\n" % [NAMES[i],stock[i],PRICES[i]]
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
  if int(a[3]) == 0: standards += 1
  if int(a[3]) == 3: decks += 1
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
 if f: f.store_string(JSON.stringify({"money":money,"stock":stock,"contract":contract,"keys":career_keys.keys(),"career":career}))
func load_career():
 if not FileAccess.file_exists("user://career.json"): return
 var d = JSON.parse_string(FileAccess.get_file_as_string("user://career.json"))
 if not d is Dictionary: return
 money = int(d.get("money",1000))
 contract = int(d.get("contract",0))
 career = bool(d.get("career",false))
 var saved = d.get("stock",[])
 if saved is Array and saved.size()==8:
  for i in range(8): stock[i] = int(saved[i])
 career_keys.clear()
 for id in d.get("keys",[]):
  if pieces.has(id): career_keys[id] = true
func _process(delta):
 if not walking or menu.visible or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: return
 var move := Vector3.ZERO
 var forward := Vector3(-sin(yaw),0,-cos(yaw))
 var right := Vector3(cos(yaw),0,-sin(yaw))
 if Input.is_physical_key_pressed(KEY_W): move += forward
 if Input.is_physical_key_pressed(KEY_S): move -= forward
 if Input.is_physical_key_pressed(KEY_D): move += right
 if Input.is_physical_key_pressed(KEY_A): move -= right
 eye += move.normalized()*delta*5.0
 eye.x = clampf(eye.x,-14,14)
 eye.z = clampf(eye.z,-14,14)
 cam.position = eye
 cam.rotation = Vector3(pitch,yaw,0)
 var point := eye - cam.global_transform.basis.z*4.0
 if pitch < -0.1:
  var t := (float(cursor.y)-eye.y)/(-cam.global_transform.basis.z.y)
  if t > 0 and t < 12: point = eye-cam.global_transform.basis.z*t
 var next := Vector3i(clampi(roundi(point.x),-14,14),cursor.y,clampi(roundi(point.z),-14,14))
 if next != cursor:
  cursor = next
  refresh()
func _unhandled_input(event):
 if not walking or menu.visible: return
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
