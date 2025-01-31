extends Node

var timer: Timer

func generate_burger_order(is_good_customer: bool = true):
	var burger_order = [] # Burger orders will always have a Top Bun
	var good_ingredients = generate_good_burger_ingredients() # Returns 0 - 2 good ingredients
	var bad_ingredients = generate_bad_burger_ingredients() # Returns 1 bad ingredient
	
	if not is_good_customer:
		if randi() % 2 == 0: # 50% for burger to have moldy bun vs normal bun
			burger_order.append("Moldy Top Bun")
		else:
			burger_order.append("Top Bun") # Burger orders will always have a Bottom Bun
	else:
		burger_order.append("Top Bun") # Burger orders will always have a Bottom Bun
	
	burger_order.append_array(good_ingredients)
	if not is_good_customer:
		burger_order.append_array(bad_ingredients) 
	else:
		burger_order.append("Beef Patty") # Only good customers get a normal cooked patty (:
	
	if not is_good_customer:
		if randi() % 2 == 0: # 50% for burger to have moldy bun vs normal bun
			burger_order.append("Moldy Bottom Bun")
		else:
			burger_order.append("Bottom Bun") # Burger orders will always have a Bottom Bun
	else:
		burger_order.append("Bottom Bun") # Burger orders will always have a Bottom Bun
	
	return burger_order

func generate_good_burger_ingredients():
	var good_ingredients = []
	var current_ingredients_on_burger = 3 # Burgers are always have 2 buns and 1 patty

	if randi() % 2 == 0: # 50% for burger to have Tomato
		good_ingredients.append("Tomato")
		current_ingredients_on_burger += 1
	if randi() % 2 == 0: # 50% for burger to have Lettuce
		good_ingredients.append("Lettuce")
		current_ingredients_on_burger += 1
	if randi() % 2 == 0 && current_ingredients_on_burger < 5: # 50% for burger to have Cheese
		good_ingredients.append("Cheese")
		current_ingredients_on_burger += 1
	if randi() % 2 == 0 && current_ingredients_on_burger < 5: # 50% for burger to have Cheese (or extra cheese)
		good_ingredients.append("Cheese")
		current_ingredients_on_burger += 1
		
	return good_ingredients

func generate_bad_burger_ingredients():
	var bad_ingredients = []
	
	# 50% for bad burger to have Ashes (:
	var dice = randi_range(0,2)
	match dice:
		0:
			bad_ingredients.append("Ashes")
		1:
			bad_ingredients.append("Poison Ivy")
		2:
			bad_ingredients.append("Latex glove")
		
	# Bad burgers will have either be raw or burnt
	if randi() % 2 == 0: 
		bad_ingredients.append("Raw Beef Patty")
	else:
		bad_ingredients.append("Burnt Beef Patty")
		
		
	return bad_ingredients

func print_order(order, label_name):
	get_parent().get_node(label_name).text = ""
	for i in order.size():
		get_parent().get_node(label_name).text += order[i]
		get_parent().get_node(label_name).text += "\n"

func _on_serve_button_down(button_pressed: int):
	print("- - -  _on_serve_button_down  - - -")
	
	var path_to_plate = NodePath("Plate"+str(button_pressed))
	var plate = get_parent().get_node(path_to_plate)
	var path_to_label = NodePath("OrderLabel"+str(button_pressed))
	var order_label = get_parent().get_node(path_to_label)
	global.map_data[plate.name].reverse()
	
	print("Burger Order: ", global.map_data[plate.name+"_Order"])
	print("Submitted Items: ", global.map_data[plate.name])
	
	grade_order(global.map_data[plate.name+"_Order"], global.map_data[plate.name])
	plate.find_child("Icon").clear_plate()
	global.map_data[plate.name+"_Order"] = []
	order_label.text = ""
	
	print("- - - - - - - - - - - - - - - - - -")

func _ready():
	_start_initial_timer()

func _start_initial_timer():
	timer = $Timer
	timer.connect("timeout", _on_timer_timeout)
	timer.start(_random_num_in_range(3, 17))

func _random_num_in_range (min, max):
	var rng = RandomNumberGenerator.new()
	var random_number = rng.randi_range(min, max)
	return random_number

func _on_timer_timeout():
	_fill_random_order_label()

func _fill_random_order_label():
	var available_order_labels = [1,2,3,4]
	var path_to_plate
	var plate
	var path_to_label
	var order_label
	var burger_order
	available_order_labels.shuffle()
	while available_order_labels.size() > 0:
		path_to_plate = NodePath("Plate"+str(available_order_labels[0]))
		plate = get_parent().get_node(path_to_plate)
		path_to_label = NodePath("OrderLabel"+str(available_order_labels[0]))
		order_label = get_parent().get_node(path_to_label)
		if order_label.text != "": # Check if plate already has an order
			available_order_labels.remove_at(0)
		else:
			var _is_good: bool = true
			if randi() % 3 == 0: # About a 33% for a burger customer to be bad
				_is_good = false
			burger_order = generate_burger_order(_is_good)
			global.map_data[plate.name+"_Order"] = burger_order
			print_order(burger_order, path_to_label)
			break

func grade_order(items_on_plate, burger_order):
	if (items_on_plate == burger_order) and burger_order != []:
		global.score += 10
	elif (global.score - 5 >= 0)  and burger_order != []:
		global.score -= 5
	update_score_label()

func update_score_label():
	var score_label = get_tree().get_root().find_child("ScoreLabel",true,false)
	score_label.text = "[center]"+str(global.score)+"[/center]"


