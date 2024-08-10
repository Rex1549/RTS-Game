extends RefCounted

class_name UnitSpawn

var unit: Resource
var target_coords: Vector3
var unit_team:int

func initialise(unit: Resource, target: Vector3, team:int=0):
	self.unit = unit
	self.target_coords = target
	self.unit_team = team

func _init(unit: Resource, target: Vector3, team:int=0):
	self.unit = unit
	self.target_coords = target
	self.unit_team = team
