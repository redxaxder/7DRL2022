extends Node

class_name LocationService

var constants = preload("res://lib/const.gd").new()

# a map from position to array of Node
var __forward: Dictionary = {}
# a map from Node to position
var __backward: Dictionary = {}

func lookup_backward(n: Node, default = null) -> Vector2:
	return __backward.get(n,default)

func lookup(p: Vector2, group: String = "") -> Array:
	var l = p.floor()
	var results = __forward.get(l,[]).duplicate()
	if group == "":
		return results
	elif results.size() > 0:
		var ret = []
		for res in results:
			if res && res.is_in_group(group):
				ret.append(res)
		return ret
	else:
		return results

func delete_node(n: Node):
	var l = lookup_backward(n)
	if l != null: # delete forward
		var here = __forward.get(l,[])
		if here.size() > 0:
			here.erase(n)
			if here.size() == 0:
				__forward.erase(l)
	__backward.erase(n) # delete backward

func insert(n: Node, p: Vector2):
	var l = p.floor()
	delete_node(n) #delete first
	__backward[n] = l #insert backward
	var here = __forward.get(l,[]) #insert forward
	here.append(n)
	__forward[l] = here
