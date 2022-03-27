#### OCS Fast Lib v.0.01
#### One Cat Studio (C) 2022
#### OCS Fast Lib's purpose is to simplify math, geometry and other commonly faced routines.
###################################################################################################
#### Instructions:
#### Register it as an autoload in your project and refer to it by the node name.

extends Node

#Checks if a Vector2 is inside some boundaries (start is left-uppermost and end is right-bottommost)
func isVectorInBounds(vector:Vector2, start:Vector2, end:Vector2) -> bool:
	return vector.x >= start.x && vector.y >= start.y && vector.x <= start.x+end.x && vector.y <= start.y+end.y


#Euristic formula to get quickest turn direction
func shortAngleDistance(from, to) -> float:
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference
