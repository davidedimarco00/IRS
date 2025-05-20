
function init()
    robot.wheels.set_velocity(0, 0)
end

function step()
    light_sensors = robot.light
    left_speed, right_speed = 0, 0
    max_light = 0
    angle_threshold = 15
    
    for i = 1, #light_sensors do
        if light_sensors[i].value > max_light then
            max_light = light_sensors[i].value
            sensor_index = i
        end
    end
	angle = light_sensors[sensor_index].angle

	if math.deg(angle) < -angle_threshold then
		left_speed, right_speed = 5, 0
	elseif math.deg(angle) > angle_threshold then
		left_speed,  right_speed = 0, 5
	else
		left_speed, right_speed = 5, 5
	end
    robot.wheels.set_velocity(left_speed, right_speed)
end

function reset()
    robot.wheels.set_velocity(0, 0)
end

function destroy()
end
