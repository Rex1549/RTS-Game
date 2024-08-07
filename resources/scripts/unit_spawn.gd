extends RefCounted

class_name UnitSpawn

var unit: Resource
var target_coords: Vector3

func initialise(unit: Resource, target: Vector3):
	self.unit = unit
	self.target_coords = target

func _init(unit: Resource, target: Vector3):
	self.unit = unit
	self.target_coords = target
