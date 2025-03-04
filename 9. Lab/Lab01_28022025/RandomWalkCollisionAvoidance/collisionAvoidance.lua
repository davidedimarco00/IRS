
function init()
    robot.wheels.set_velocity(0, 0)
end

function step()
    light = robot.light
    left_speed, right_speed = 0, 0
    max_light = 0
    
    for i = 1, 24 do
        if light[i].value > max_light then
            max_light = light[i].value
            sensor_index = i
        end
    end
    
	angle = light[sensor_index].angle
	log("Angle: ",math.deg(angle))
	
	if math.deg(angle) < -15 then
		left_speed = 5
		right_speed = 2
	elseif math.deg(angle) > 15 then
		left_speed = 2
		right_speed = 5
	else
		left_speed = 5
		right_speed = 5
	end
    
    robot.wheels.set_velocity(left_speed, right_speed)
end

function reset()
    robot.wheels.set_velocity(0, 0)
end

function destroy()
end
